// Creates an Azure AI Hub resource with proxied endpoints for the Azure AI services provider
// Copied from https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.machinelearningservices/aistudio-entraid-passthrough
// See also https://learn.microsoft.com/en-us/samples/azure-samples/azure-ai-studio-secure-bicep/azure-ai-studio-secure-bicep/

@description('Azure region used for the deployment of the Azure AI Hub.')
param location string

@description('Set of tags to apply to the Azure AI Hub.')
param tags object

@description('Name for the Azure AI Hub resource.')
param aiHubName string

@description('Friendly name for your Azure AI Hub resource, displayed in the Studio UI.')
param aiHubFriendlyName string = aiHubName

@description('Description of your Azure AI Hub resource, displayed in the Studio UI.')
param aiHubDescription string = 'This is an AI Foundry for use with the Smart-Flow application.'

@description('Resource ID of the Azure Application Insights resource for storing diagnostics logs.')
param applicationInsightsId string

@description('Resource ID of the Azure Container Registry resource for storing Docker images for models.')
param containerRegistryId string

@description('Resource ID of the Azure Key Vault resource for storing connection strings.')
param keyVaultId string

@description('Resource ID of the Azure Storage Account resource for storing workspace data.')
param storageAccountId string

@description('Resource ID of the Azure AI Services resource for connecting AI capabilities.')
param aiServicesId string

@description('Target endpoint for the Azure AI Services resource to link to the Azure AI Hub.')
param aiServicesTarget string

// @description('The resource ID of the Microsoft Entra ID identity to use as hub identity. When not provided system assigned identity is used.')
// param hubIdentityResourceId string = ''
@description('The resource ID of the Microsoft Entra ID identity to use as hub identity.')
param managedIdentityId string = ''

@description('Name AI Search resource')
param aiSearchName string

param privateEndpointSubnetId string = ''
param privateEndpointName string = ''

var acsConnectionName = '${aiHubName}-connection-AISearch'
var aoaiConnectionName = '${aiHubName}-connection-AIServices_aoai'

resource aisearch 'Microsoft.Search/searchServices@2020-03-13' existing = {
  name: aiSearchName
}

@description('Name for capabilityHost.')
param capabilityHostName string = 'caphost1'

@description('Provide the IP address to allow access to the Azure Container Registry')
param myIpAddress string = ''

// var useProvidedHubIdentity = !empty(hubIdentityResourceId)

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2025-01-01-preview' = {
  name: aiHubName
  location: location
  tags: tags
  kind: 'Hub'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: { '${managedIdentityId}': {} }
  }
  // identity: {
  //   type: useProvidedHubIdentity ? 'UserAssigned' : 'SystemAssigned'
  //   userAssignedIdentities: useProvidedHubIdentity ? { '${hubIdentityResourceId}': {} } :  {}
  // }
  properties: {
    // organization
    friendlyName: aiHubFriendlyName
    description: aiHubDescription

    // dependent resources
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId
    //systemDatastoresAuthMode: 'identity'
    primaryUserAssignedIdentity: managedIdentityId
    
    // WARNING: these do not seem be allowed in @2024-10-01, but it's not stopping the deployment...
    ipAllowlist: empty(myIpAddress) ? [] : [myIpAddress]
    systemDatastoresAuthMode: 'identity'
    
    // THIS IS NOT WORKING
    //sharedPrivateLinkResources: [
    // {
    //   name: 'link-to-openai-openai'
    //   properties: {
    //     groupId: 'openai_account'
    //     privateLinkResourceId: aiServicesId
    //     requestMessage: 'automatically created by the system'
    //     status: 'Approved'
    //   }
    // }
    // {
    //   name: 'link-to-storage-blob'
    //   properties: {
    //     groupId: 'blob'
    //     privateLinkResourceId: storageAccountId
    //     requestMessage: 'automatically created by the system'
    //     status: 'Approved'
    //   }
    // }
    // {
    //   name: 'link-to-storage-file'
    //   properties: {
    //     groupId: 'file'
    //     privateLinkResourceId: storageAccountId
    //     requestMessage: 'automatically created by the system'
    //     status: 'Approved'
    //   }
    // }
    // {
    //   name: 'link-to-search-${aiSearchName}'
    //   properties: {
    //     groupId: 'search'
    //     privateLinkResourceId: aisearch.id
    //     requestMessage: 'automatically created by the system'
    //     status: 'Approved'
    //   }
    // }
    // ]
  }

  resource aiServicesConnection 'connections@2024-10-01' = {
    name: aoaiConnectionName
    properties: {
      category: 'AzureOpenAI'
      target: aiServicesTarget
      authType: 'AAD'
      isSharedToAll: true
      metadata: {
        ApiType: 'Azure'
        ResourceId: aiServicesId
      }
    }
  }

  resource hub_connection_azureai_search 'connections@2024-07-01-preview' = {
    name: acsConnectionName
    properties: {
      category: 'CognitiveSearch'
      target: 'https://${aiSearchName}.search.windows.net'
      authType: 'AAD'
      //useWorkspaceManagedIdentity: false
      isSharedToAll: true
      metadata: {
        ApiType: 'Azure'
        ResourceId: aisearch.id
        location: aisearch.location
      }
    }
  }

  // This fails...
  // resource aiServicesConnection 'connections@2024-04-01-preview' = {
  //   name: '${aiHubName}-connection'
  //   properties: {
  //     category: 'OpenAI'        // Error: Unsupported authtype AAD for OpenAI (Code: ValidationError)
  //     // category: 'AIServices' // Error: The associated account is of kind OpenAI. Please provide an account of kind AIServices. 
  //     target: aiServicesTarget
  //     authType: 'AAD'
  //     isSharedToAll: true
  //     metadata: {
  //       ApiType: 'Azure'
  //       ResourceId: aiServicesId
  //     }
  //   }
  // }

  // this is defined in the ai-hub-project.bicep file... 
  // this is failing... do we need it here?
  // // Resource definition for the capability host
  // // Documentation: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces/capabilityhosts?tabs=bicep
  // resource capabilityHost 'capabilityHosts@2025-01-01-preview' = {
  //   name: capabilityHostName
  //   properties: {
  //     // TODO: this doesn't work
  //     // "code": "UserError",
  //     // "message": "/subscriptions/0721e282-2773-4021-af16-e00641ed5e36/resourceGroups/rg-philips-emissions/providers/Microsoft.Network/virtualNetworks/philipsemissions-vnet-dev/subnets/snet-agents is invalid",
  //     // customerSubnet: subnetId
  //     capabilityHostKind: 'Agents'
  //   }
  // }
  // dependsOn: [
  //   aisearch
  // ]
}

module hubPrivateEndpoint '../networking/private-endpoint.bicep' = if (!empty(privateEndpointSubnetId)) {
  name: 'hub-private-endpoint'
  params: {
    privateEndpointName: privateEndpointName
    groupIds: ['amlworkspace']
    targetResourceId: aiHub.id
    subnetId: privateEndpointSubnetId
  }
}

output id string = aiHub.id
output name string = aiHub.name
output aoaiConnectionName string = aoaiConnectionName
output acsConnectionName string = acsConnectionName
output aiHubPrincipalId string = empty(hubIdentityResourceId) ? aiHub.identity.principalId : aiHub.identity.userAssignedIdentities[hubIdentityResourceId].principalId
output privateEndpointName string = privateEndpointName
