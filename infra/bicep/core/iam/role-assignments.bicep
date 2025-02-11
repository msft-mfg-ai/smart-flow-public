// Assign roles to the service principal 
// NOTE: this requires elevated permissions in the resource group
// Contributor is not enough, you need Owner or User Access Administrator
// See https://docs.microsoft.com/azure/role-based-access-control/role-assignments-template#new-service-principal

param registryName string = ''
param storageAccountName string = ''
param aiSearchName string = ''
param aiServicesName string = ''
param identityPrincipalId string
@allowed(['ServicePrincipal', 'User'])
param principalType string = 'ServicePrincipal'

var roleDefinitions = loadJsonContent('../../data/roleDefinitions.json')
var addRegistryRoles = !empty(registryName)
var addStorageRoles = !empty(storageAccountName)
var addSearchRoles = !empty(aiSearchName)
var addCogServicesRoles = !empty(aiServicesName)

resource registry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = if (addRegistryRoles) {
  name: registryName
}
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = if (addStorageRoles) {
  name: storageAccountName
}
resource aiService 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' existing = {
  name: aiServicesName
  scope: resourceGroup()
}
resource searchService 'Microsoft.Search/searchServices@2024-06-01-preview' existing = {
  name: aiSearchName
  scope: resourceGroup()
}

resource registry_Role_AcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addRegistryRoles) {
  name: guid(registry.id, identityPrincipalId, roleDefinitions.containerregistry.acrPullRoleId)
  scope: registry
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.containerregistry.acrPullRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to pull images from the registry ${registryName}'
  }
}

resource storage_Role_BlobContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addStorageRoles) {
  name: guid(storageAccount.id, identityPrincipalId, roleDefinitions.storage.blobDataContributorRoleId)
  scope: storageAccount
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.storage.blobDataContributorRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to write to the storage account ${storageAccountName} Blob'
  }
}
resource storage_Role_TableContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addStorageRoles) {
  name: guid(storageAccount.id, identityPrincipalId, roleDefinitions.storage.tableContributorRoleId)
  scope: storageAccount
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.storage.tableContributorRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to write to the storage account ${storageAccountName} Table'
  }
}
resource storage_Role_QueueContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addStorageRoles) {
  name: guid(storageAccount.id, identityPrincipalId, roleDefinitions.storage.queueDataContributorRoleId)
  scope: storageAccount
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.storage.queueDataContributorRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to write to the storage account ${storageAccountName} Queue'
  }
}

resource cognitiveServices_Role_OpenAIUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addCogServicesRoles) {
  name: guid(aiService.id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesOpenAIUserRoleId)
  scope: aiService
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.openai.cognitiveServicesOpenAIUserRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to be OpenAI User'
  }
}
resource cognitiveServices_Role_OpenAIContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addCogServicesRoles) {
  name: guid(aiService.id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesOpenAIContributorRoleId)
  scope: aiService
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.openai.cognitiveServicesOpenAIContributorRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to be OpenAI Contributor'
  }
}

resource cognitiveServices_Role_User 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addCogServicesRoles) {
  name: guid(aiService.id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesUserRoleId)
  scope: aiService
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.openai.cognitiveServicesUserRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to be a Cognitive Services User'
  }
}
resource cognitiveServices_Role_Contributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addCogServicesRoles) {
  name: guid(aiService.id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesContributorRoleId)
  scope: aiService
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.openai.cognitiveServicesContributorRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to be a Cognitive Services Contributor'
  }
}

resource search_Role_IndexDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addSearchRoles) {
  name: guid(searchService.id, identityPrincipalId, roleDefinitions.search.indexDataContributorRoleId)
  scope: searchService
  properties: {
    principalId: identityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.search.indexDataContributorRoleId)
    principalType: principalType
    description: 'Permission for ${principalType} ${identityPrincipalId} to use the modify search service indexes'
  }
}
resource search_Role_ServiceContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addSearchRoles) {
  name: guid(searchService.id, identityPrincipalId, roleDefinitions.search.serviceContributorRoleId)
  scope: searchService
  properties: {
    principalId: identityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.search.serviceContributorRoleId)
    principalType: principalType
    description: 'Permission for ${principalType} ${identityPrincipalId} to be a search service contributor'
  }
}
