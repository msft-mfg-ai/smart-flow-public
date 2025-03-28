// Copyright (c) Microsoft. All rights reserved.

using Assistant.Hub.Api.Core;
using Assistant.Hub.Api.Services.Data;
using Assistant.Hub.Api.Services.Profile;
using Azure.AI.OpenAI;
using Azure.Search.Documents.Models;
using Microsoft.SemanticKernel;
using System.ComponentModel;
using System.Text;
using Azure;
using Assistant.Hub.Api.Assistants;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc;
using MinimalApi.Services;
using System.Diagnostics;

namespace Assistant.Hub.Api.Services.Search;

public sealed class VectorSearchRetrievalPluginTool
{
    private readonly SearchClientFactory _searchClientFactory;
    private readonly AzureOpenAIClient _openAIClient;

    public VectorSearchRetrievalPluginTool(SearchClientFactory searchClientFactory, AzureOpenAIClient openAIClient)
    {
        _searchClientFactory = searchClientFactory;
        _openAIClient = openAIClient;
    }


    [KernelFunction("RetrievalStub"), Description("Search more information")]
    public async Task RetrievalStubV2Async(KernelArguments arguments)
    {
        var toolDefinition = arguments[ContextVariableOptions.ToolDefinition] as ToolDefinition;
        var ragSettings = toolDefinition.RAGSettings;

        ArgumentNullException.ThrowIfNull(toolDefinition, "toolDefinition not set.");
        ArgumentNullException.ThrowIfNull(ragSettings, "RAGSettings not set.");

        var result = ReferenceDataStub.GetByName(ragSettings.DataFileName);

        arguments[$"{toolDefinition.Name}Result"] = result;
    }

    [KernelFunction("SearchRetrieval"), Description("Retrieve document by key")]
    public async Task SearchRetrievalAsync(KernelArguments arguments)
    {
        var toolDefinition = arguments[ContextVariableOptions.ToolDefinition] as ToolDefinition;
        ArgumentNullException.ThrowIfNull(toolDefinition, "ToolDefinition not set.");
        ArgumentNullException.ThrowIfNull(toolDefinition.RAGSettings, "RAGSettings not set.");
        ArgumentException.ThrowIfNullOrWhiteSpace(toolDefinition.RAGSettings.RetrievalIndexName, "RetrievalIndexName not set");

        var labelProperties = arguments["LabelProperties"] as LabelProperties;
        ArgumentException.ThrowIfNullOrWhiteSpace(labelProperties.product_name, "ProductName not set.");

        var key = ResolveKey(labelProperties);
        var searchClient = _searchClientFactory.GetOrCreateClient(toolDefinition.RAGSettings.RetrievalIndexName);

        Debug.WriteLine($"Searching index {toolDefinition.RAGSettings.RetrievalIndexName} for key {key}...");

        //TODO: Handle NotFound 
        Response<ContentSearchResult> response = await searchClient.GetDocumentAsync<ContentSearchResult>(key);

        arguments[$"{toolDefinition.Name}Result"] = response.Value.content;
    }

    [KernelFunction("SearchRetrievalPLG"), Description("Retrieve document by key")]
    public async Task SearchRetrievalPLGAsync(KernelArguments arguments)
    {
        var toolDefinition = arguments[ContextVariableOptions.ToolDefinition] as ToolDefinition;
        ArgumentNullException.ThrowIfNull(toolDefinition, "ToolDefinition not set.");
        ArgumentNullException.ThrowIfNull(toolDefinition.RAGSettings, "RAGSettings not set.");
        ArgumentException.ThrowIfNullOrWhiteSpace(toolDefinition.RAGSettings.RetrievalIndexName, "RetrievalIndexName not set");

        var labelProperties = arguments["LabelProperties"] as LabelProperties;
        ArgumentException.ThrowIfNullOrWhiteSpace(labelProperties.product_name, "ProductName not set.");

        var key = ResolvePLGKey(labelProperties);
        var searchClient = _searchClientFactory.GetOrCreateClient(toolDefinition.RAGSettings.RetrievalIndexName);

        Response<ContentSearchResult> response = await searchClient.GetDocumentAsync<ContentSearchResult>(key);

        arguments[$"{toolDefinition.Name}Result"] = response.Value.content;
    }

    private string ResolveKey(LabelProperties labelProperties)
    {
        if (labelProperties.country == "US")
            return $"EPA-{labelProperties.regulator_number}";

        if (labelProperties.country == "CA")
          return $"PCP-{labelProperties.regulator_number}";

        throw new ArgumentOutOfRangeException("country", labelProperties.country);
    }

    private string ResolvePLGKey(LabelProperties labelProperties)
    {
        if (labelProperties.classification == "Biocidal")
            return $"Biocidal_Required_Label_Elements_Front_Panel";

        throw new ArgumentOutOfRangeException("classification", labelProperties.country);
    }
}
