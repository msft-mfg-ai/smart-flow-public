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
using Assistants.API.Core;
using System.Text.Json;
using System.Net.Http;

namespace Assistant.Hub.Api.Services.Search;

public sealed class ProductMasterRetrievalTools
{
    private readonly HttpClient _httpClient;
    private readonly string _baseUrl;
    public ProductMasterRetrievalTools(HttpClient httpClient, string baseUrl)
    {
        _httpClient = httpClient;
        _baseUrl = baseUrl;
    }

    [KernelFunction("ProductMasterRetrieval"), Description("Retrieve document by key")]
    public async Task SearchRetrievalAsync(KernelArguments arguments)
    {
        var toolDefinition = arguments[ContextVariableOptions.ToolDefinition] as ToolDefinition;
        ArgumentNullException.ThrowIfNull(toolDefinition, "ToolDefinition not set.");
        ArgumentNullException.ThrowIfNull(toolDefinition.RAGSettings, "RAGSettings not set.");
        ArgumentException.ThrowIfNullOrWhiteSpace(toolDefinition.RAGSettings.RetrievalIndexName, "RetrievalIndexName not set");

        var labelProperties = arguments["LabelProperties"] as LabelProperties;
        ArgumentException.ThrowIfNullOrWhiteSpace(labelProperties.product_name, "ProductName not set.");

        var url = $"{_baseUrl}/data/product/{labelProperties.upc}";    
        HttpResponseMessage response = await _httpClient.GetAsync(url);

        string jsonResponse = await response.Content.ReadAsStringAsync();
        var productInfo = JsonSerializer.Deserialize<ProductMasterInformation>(jsonResponse, new JsonSerializerOptions{ PropertyNameCaseInsensitive = true });
        var sb = new StringBuilder();
        foreach (var item in productInfo.Items)
        {
            sb.AppendLine($"{item.Name}: {item.Value}");
        }

        arguments[$"{toolDefinition.Name}Result"] = sb;
    }
}
