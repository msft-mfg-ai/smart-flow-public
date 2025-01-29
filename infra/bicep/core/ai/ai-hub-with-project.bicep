
resource llsfpubhubdev 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: 'llsfpub128-hub-dev'
  location: 'eastus2'
  properties: {
    friendlyName: 'Smart-Flow AI Hub'
    description: 'This is an example AI resource for use in Azure AI Studio.'

    storageAccount: '/subscriptions/a0f86c93-146a-4534-b83e-49090394aa78/resourceGroups/rg-ai-ll-sfpub-128-dev/providers/Microsoft.Storage/storageAccounts/llsfpub128stdev'
    keyVault: '/subscriptions/a0f86c93-146a-4534-b83e-49090394aa78/resourceGroups/rg-ai-ll-sfpub-128-dev/providers/Microsoft.KeyVault/vaults/llsfpub128kvdev'
    applicationInsights: '/subscriptions/a0f86c93-146a-4534-b83e-49090394aa78/resourceGroups/rg-ai-ll-sfpub-128-dev/providers/Microsoft.Insights/components/llsfpub128-appi-dev'
    
    hbiWorkspace: false
    
    managedNetwork: {
      changeableIsolationModes: [
        'AllowInternetOutbound'
        'AllowOnlyApprovedOutbound'
      ]
      isolationMode: 'Disabled'
    }
    
    v1LegacyMode: false
    containerRegistry: '/subscriptions/a0f86c93-146a-4534-b83e-49090394aa78/resourceGroups/rg-ai-ll-sfpub-128-dev/providers/Microsoft.ContainerRegistry/registries/llsfpub128crdev'
    publicNetworkAccess: 'Enabled'
    discoveryUrl: 'https://eastus2.api.azureml.ms/discovery'

    associatedWorkspaces: [
      '/subscriptions/a0f86c93-146a-4534-b83e-49090394aa78/resourceGroups/rg-ai-ll-sfpub-128-dev/providers/Microsoft.MachineLearningServices/workspaces/smart-flow'
    ]

    workspaceHubConfig: {
      defaultWorkspaceResourceGroup: '/subscriptions/a0f86c93-146a-4534-b83e-49090394aa78/resourceGroups/rg-ai-ll-sfpub-128-dev'
    }

    enableDataIsolation: true

  }
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'Hub'
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}
