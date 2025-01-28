//using Azure.Storage.Blobs;
//using Azure.Storage.Blobs.Models;

using Azure.AI.OpenAI;
using Azure;
using Microsoft.SemanticKernel;
using MinimalApi.Services;
using MinimalApi.Services.Skills;
using Assistant.Hub.Api.Core;
using Azure.Identity;
using Assistant.Hub.Api.Services.Search;
using Azure.AI.DocumentIntelligence;
using Azure.Search.Documents.Indexes;
using Microsoft.Azure.Cosmos;
using Azure.Storage.Blobs;
using Assistant.Hub.Api.Services.OCR;


namespace Assistants.API.Core
{
    internal static class ServiceCollectionExtensions
    {
        private static readonly DefaultAzureCredential _defaultAzureCredential = new DefaultAzureCredential();

        internal static IServiceCollection AddAgentLog(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddTransient<AgentLog>(sp =>
            {
                var cosmosClient = sp.GetRequiredService<CosmosClient>();
                return new AgentLog(Guid.NewGuid(), cosmosClient);
            });

            return services;
        }

        internal static IServiceCollection AddAzureServices(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddTransient<ContentService>();
            services.AddTransient<OcrClient>();

            var adiEndpoint = configuration[AppConfigurationSetting.AzureDocumentIntelligenceEndpoint];
            if (!string.IsNullOrEmpty(adiEndpoint))
            {
                services.AddSingleton<DocumentIntelligenceClient>(sp =>
                {
                    var key = configuration[AppConfigurationSetting.AzureDocumentIntelligenceKey];

                    return string.IsNullOrEmpty(key)
                        ? new DocumentIntelligenceClient(new Uri(adiEndpoint), _defaultAzureCredential)
                        : new DocumentIntelligenceClient(new Uri(adiEndpoint), new AzureKeyCredential(key));
                });
            }

            var storageAccountName = configuration[AppConfigurationSetting.StorageAccountName];
            if (!string.IsNullOrEmpty(storageAccountName))
            {
                var blobStorageEndpoint = $"https://{storageAccountName}.blob.core.windows.net";
                services.AddSingleton<BlobServiceClient>(sp =>
                {
                    var blobServiceClient = new BlobServiceClient(new Uri(blobStorageEndpoint), _defaultAzureCredential);
                    return blobServiceClient;
                });
                services.AddSingleton<BlobContainerClient>(sp =>
                {
                    var azureStorageContainer = configuration[AppConfigurationSetting.ContentStorageContainer];
                    return sp.GetRequiredService<BlobServiceClient>().GetBlobContainerClient(azureStorageContainer);
                });
            }

            services.AddSingleton<SearchClientFactory>(sp =>
            {
                var config = sp.GetRequiredService<IConfiguration>();
                var azureAISearchKey = config[AppConfigurationSetting.AzureAISearchKey];

                if (!string.IsNullOrEmpty(azureAISearchKey))
                {
                    return new SearchClientFactory(config, keyCredential: new AzureKeyCredential(azureAISearchKey));
                }

                return new SearchClientFactory(config, _defaultAzureCredential);
            });

            services.AddSingleton<OpenAIClientFacade>(sp =>
            {
                var config = sp.GetRequiredService<IConfiguration>();
                var blobContainerClient = sp.GetRequiredService<BlobContainerClient>();
                var httpClient = sp.GetRequiredService<HttpClient>();

                // Build Kernels
                Kernel dynamicAgentWorkflow = BuildKernel(config);

                // Build Plugins
                var searchClientFactory = sp.GetRequiredService<SearchClientFactory>();
                var openAIClient = BuildAzureOpenAIClient(config);

                dynamicAgentWorkflow.Plugins.AddFromType<AgentModel>(ContextVariableOptions.AgentTools);

                var vectorSearchRetrievalPluginTool = new VectorSearchRetrievalPluginTool(searchClientFactory, openAIClient);
                dynamicAgentWorkflow.ImportPluginFromObject(vectorSearchRetrievalPluginTool, ContextVariableOptions.VectorSearchRetrievalPluginTools);

                var entityExtractionTools = new EntityExtractionTools(blobContainerClient);
                dynamicAgentWorkflow.ImportPluginFromObject(entityExtractionTools, ContextVariableOptions.EntityExtractionTools);
                if (!string.IsNullOrEmpty(adiEndpoint))
                {
                    var documentIntelligenceClient = sp.GetRequiredService<DocumentIntelligenceClient>();

                    var documentIntelligenceExtractionTools = new DocumentIntelligenceExtractionTools(sp.GetRequiredService<OcrClient>(), blobContainerClient, sp.GetRequiredService<ILogger<DocumentIntelligenceExtractionTools>>());
                    // dynamicAgentWorkflow.ImportPluginFromType<DocumentIntelligenceExtractionTools>(ContextVariableOptions.DocumentIntelligenceExtractionTools);
                    dynamicAgentWorkflow.ImportPluginFromObject(documentIntelligenceExtractionTools, ContextVariableOptions.DocumentIntelligenceExtractionTools);
                }

                var facade = new OpenAIClientFacade();
                facade.RegisterKernel(ContextVariableOptions.KernelInstanceDynamicAgents, dynamicAgentWorkflow);
                return facade;
            });

            // Register the SearchIndexClient
            services.AddSingleton<SearchIndexClient>(sp =>
            {
                var azureSearchServiceEndpoint = configuration[AppConfigurationSetting.AzureAISearchEndpoint];
                var azureSearchServiceKey = configuration[AppConfigurationSetting.AzureAISearchKey];

                return string.IsNullOrEmpty(azureSearchServiceKey)
                     ? new SearchIndexClient(new Uri(azureSearchServiceEndpoint), _defaultAzureCredential)
                     : new SearchIndexClient(new Uri(azureSearchServiceEndpoint), new AzureKeyCredential(azureSearchServiceKey));
            });

            var handler = new SocketsHttpHandler();
            handler.PooledConnectionLifetime = TimeSpan.FromMinutes(5);
            services.AddSingleton<SocketsHttpHandler>(handler);

            services.AddSingleton<CosmosClient>(sp =>
            {
                var config = sp.GetRequiredService<IConfiguration>();
                var socketsHandler = sp.GetRequiredService<SocketsHttpHandler>();

                return BuildCosmosClient(config, socketsHandler);
            });

            services.AddTransient<WorkflowManagerAgent>();
            return services;
        }

        private static CosmosClient BuildCosmosClient(IConfiguration config, SocketsHttpHandler handler)
        {
            var cosmosEndpoint = config[AppConfigurationSetting.CosmosDbEndpoint];
            var cosmosKey = config[AppConfigurationSetting.CosmosDbKey];
            ArgumentException.ThrowIfNullOrEmpty(cosmosEndpoint);

            var options = new CosmosClientOptions
            {
                ConnectionMode = ConnectionMode.Gateway,
                HttpClientFactory = () => new HttpClient(handler)
            };

            return string.IsNullOrWhiteSpace(cosmosKey)
                ? new CosmosClient(cosmosEndpoint, _defaultAzureCredential, options)
                : new CosmosClient(cosmosEndpoint, cosmosKey, options);
        }

        private static AzureOpenAIClient BuildAzureOpenAIClient(IConfiguration config)
        {
            var azureOpenAiServiceEndpoint = config[AppConfigurationSetting.AOAIStandardServiceEndpoint];
            ArgumentException.ThrowIfNullOrEmpty(azureOpenAiServiceEndpoint);

            var azureOpenAiServiceKey = config[AppConfigurationSetting.AOAIStandardServiceKey];

            return string.IsNullOrEmpty(azureOpenAiServiceKey)
                 ? new AzureOpenAIClient(new Uri(azureOpenAiServiceEndpoint), _defaultAzureCredential)
                 : new AzureOpenAIClient(new Uri(azureOpenAiServiceEndpoint), new AzureKeyCredential(azureOpenAiServiceKey));
        }

        private static Kernel BuildKernel(IConfiguration config)
        {
            var deployedModelName = config[AppConfigurationSetting.AOAIStandardChatGptDeployment];
            var azureOpenAiServiceEndpoint = config[AppConfigurationSetting.AOAIStandardServiceEndpoint];
            var azureOpenAiServiceKey = config[AppConfigurationSetting.AOAIStandardServiceKey];
            ArgumentException.ThrowIfNullOrEmpty(deployedModelName);
            ArgumentException.ThrowIfNullOrEmpty(azureOpenAiServiceEndpoint);

            var azureAISearchUri = config[AppConfigurationSetting.AzureAISearchEndpoint];
            var azureAISearchKey = config[AppConfigurationSetting.AzureAISearchKey];

            var kernelBuilder = Kernel.CreateBuilder();

            kernelBuilder = string.IsNullOrEmpty(azureOpenAiServiceKey)
                ? kernelBuilder.AddAzureOpenAIChatCompletion(deployedModelName, azureOpenAiServiceEndpoint, _defaultAzureCredential)
                : kernelBuilder.AddAzureOpenAIChatCompletion(deployedModelName, azureOpenAiServiceEndpoint, azureOpenAiServiceKey);

            if (!string.IsNullOrEmpty(azureAISearchUri))
            {
                kernelBuilder = string.IsNullOrEmpty(azureAISearchKey)
                    ? kernelBuilder.AddAzureAISearchVectorStore(new Uri(azureAISearchUri), new DefaultAzureCredential())
                    : kernelBuilder.AddAzureAISearchVectorStore(new Uri(azureAISearchUri), new AzureKeyCredential(azureAISearchKey));
            }

            var kernel = kernelBuilder.Build();
            return kernel;
        }
    }
}
