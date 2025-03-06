// ----------------------------------------------------------------------------------------------------
// Assign roles needed for a working AI Application to the a userId (service principal or user)
// ----------------------------------------------------------------------------------------------------
// NOTE: this script requires elevated permissions in the resource group
// Contributor is not enough, you need 'Owner' or 'User Access Administrator'
// ----------------------------------------------------------------------------------------------------
// The Role Id's are defined in the roleDefinitions.json file
// For a list of Role Id's see https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// ----------------------------------------------------------------------------------------------------
@description('The principal that is being granted the rights')
param identityPrincipalId string

@allowed(['ServicePrincipal', 'User'])
@description('Is this principal a ServicePrincipal or a User?')
param principalType string = 'ServicePrincipal'

@description('If you supply this parameter, the roles will be granted at the resource group level instead of the resource level')
param grantRolesAtResourceGroupLevel bool = false

param registryName string = ''
param storageAccountName string = ''
param aiSearchName string = ''
param aiServicesName string = ''
param cosmosName string = ''
param keyvaultName string = ''
param documentIntelligenceName string = ''
param aiHubName string = ''

// ----------------------------------------------------------------------------------------------------
var roleDefinitions = loadJsonContent('../../data/roleDefinitions.json')
var addRegistryRoles = !empty(registryName)
var addStorageRoles = !empty(storageAccountName)
var addSearchRoles = !empty(aiSearchName)
var addCogServicesRoles = !empty(aiServicesName)
var addCosmosRoles = !empty(cosmosName)
var addKeyVaultRoles = !empty(keyvaultName)
var addDocumentIntelligenceRoles = !empty(documentIntelligenceName)
var addAIHubRoles = !empty(aiHubName)

// ----------------------------------------------------------------------------------------------------
// Registry Roles
// ----------------------------------------------------------------------------------------------------
resource registry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = if (addRegistryRoles) {
  name: registryName
  // scope: resourceGroup(registryResourceGroupName)
}
resource registry_Role_AcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addRegistryRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.containerregistry.acrPullRoleId) : guid(registry.id, identityPrincipalId, roleDefinitions.containerregistry.acrPullRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : registry
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.containerregistry.acrPullRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to pull images from the registry ${registryName}'
  }
}

// ----------------------------------------------------------------------------------------------------
// Storage Roles
// ----------------------------------------------------------------------------------------------------
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = if (addStorageRoles) {
  name: storageAccountName
  // scope: resourceGroup(storageResourceGroupName)
}
resource storage_Role_BlobContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addStorageRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.storage.blobDataContributorRoleId) : guid(storageAccount.id, identityPrincipalId, roleDefinitions.storage.blobDataContributorRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : storageAccount
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.storage.blobDataContributorRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to write to the storage account ${storageAccountName} Blob'
  }
}
resource storage_Role_TableContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addStorageRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.storage.tableContributorRoleId) : guid(storageAccount.id, identityPrincipalId, roleDefinitions.storage.tableContributorRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : storageAccount
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.storage.tableContributorRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to write to the storage account ${storageAccountName} Table'
  }
}
resource storage_Role_QueueContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addStorageRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.storage.queueDataContributorRoleId) : guid(storageAccount.id, identityPrincipalId, roleDefinitions.storage.queueDataContributorRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : storageAccount
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.storage.queueDataContributorRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to write to the storage account ${storageAccountName} Queue'
  }
}

// ----------------------------------------------------------------------------------------------------
// Cognitive Services Roles
// ----------------------------------------------------------------------------------------------------
resource aiService 'Microsoft.CognitiveServices/accounts@2024-06-01-preview' existing = if (addCogServicesRoles) {
  name: aiServicesName
  // scope: resourceGroup(aiServicesResourceGroupName)
}
resource cognitiveServices_Role_OpenAIUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addCogServicesRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesOpenAIUserRoleId) : guid(aiService.id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesOpenAIUserRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : aiService
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.openai.cognitiveServicesOpenAIUserRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to be OpenAI User'
  }
}
resource cognitiveServices_Role_OpenAIContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addCogServicesRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesOpenAIContributorRoleId) : guid(aiService.id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesOpenAIContributorRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : aiService
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.openai.cognitiveServicesOpenAIContributorRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to be OpenAI Contributor'
  }
}
resource cognitiveServices_Role_User 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addCogServicesRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesUserRoleId) : guid(aiService.id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesUserRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : aiService
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.openai.cognitiveServicesUserRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to be a Cognitive Services User'
  }
}
resource cognitiveServices_Role_Contributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addCogServicesRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesContributorRoleId) : guid(aiService.id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesContributorRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : aiService
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.openai.cognitiveServicesContributorRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to be a Cognitive Services Contributor'
  }
}

// ----------------------------------------------------------------------------------------------------
// Search Roles
// ----------------------------------------------------------------------------------------------------
resource searchService 'Microsoft.Search/searchServices@2024-06-01-preview' existing = if (addSearchRoles) {
  name: aiSearchName
  // scope: resourceGroup(aiSearchResourceGroupName)
}
resource search_Role_IndexDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addSearchRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.search.indexDataContributorRoleId) : guid(searchService.id, identityPrincipalId, roleDefinitions.search.indexDataContributorRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : searchService
  properties: {
    principalId: identityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.search.indexDataContributorRoleId)
    principalType: principalType
    description: 'Permission for ${principalType} ${identityPrincipalId} to use the modify search service indexes'
  }
}
resource search_Role_IndexDataReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addSearchRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.search.indexDataReaderRoleId) : guid(searchService.id, identityPrincipalId, roleDefinitions.search.indexDataReaderRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : searchService
  properties: {
    principalId: identityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.search.indexDataReaderRoleId)
    principalType: principalType
    description: 'Permission for ${principalType} ${identityPrincipalId} to use the read search service indexes'
  }
}
resource search_Role_ServiceContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addSearchRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.search.serviceContributorRoleId) : guid(searchService.id, identityPrincipalId, roleDefinitions.search.serviceContributorRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : searchService
  properties: {
    principalId: identityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.search.serviceContributorRoleId)
    principalType: principalType
    description: 'Permission for ${principalType} ${identityPrincipalId} to be a search service contributor'
  }
}

// ----------------------------------------------------------------------------------------------------
// Cosmos Database Roles
// ----------------------------------------------------------------------------------------------------
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-08-15' existing = if (addCosmosRoles) {
  name: cosmosName
}

resource cosmos_Role_DataContributor 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-08-15' = if (addCosmosRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.cosmos.dataContributorRoleId) : guid(cosmosAccount.id, identityPrincipalId, roleDefinitions.cosmos.dataContributorRoleId)
  parent: cosmosAccount
  properties: {
    principalId: identityPrincipalId
    roleDefinitionId: '${resourceGroup().id}/providers/Microsoft.DocumentDB/databaseAccounts/${cosmosAccount.name}/sqlRoleDefinitions/${roleDefinitions.cosmos.dataContributorRoleId}'
    scope: cosmosAccount.id
  }
}

// ----------------------------------------------------------------------------------------------------
// Document Intelligence Roles
// ----------------------------------------------------------------------------------------------------
resource documentIntelligence 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = if (addDocumentIntelligenceRoles) {
  name: documentIntelligenceName
}

resource documentIntelligence_Role_OpenAIContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addDocumentIntelligenceRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesOpenAIContributorRoleId) : guid(documentIntelligence.id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesOpenAIContributorRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : documentIntelligence
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.openai.cognitiveServicesOpenAIContributorRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to use the Document Intelligence cognitive services'
  }
}
resource documentIntelligence_Role_User 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addDocumentIntelligenceRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesUserRoleId) : guid(documentIntelligence.id, identityPrincipalId, roleDefinitions.openai.cognitiveServicesUserRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : documentIntelligence
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.openai.cognitiveServicesUserRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to use the Document Intelligence'
  }
}


// ----------------------------------------------------------------------------------------------------
// Document Intelligence Roles
// ----------------------------------------------------------------------------------------------------
resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = if (addKeyVaultRoles) {
  name: keyvaultName
}
resource keyVault_Role_Contributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addKeyVaultRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.keyvault.contributorRoleId) : guid(keyvault.id, identityPrincipalId, roleDefinitions.keyvault.contributorRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : keyvault
  properties: {
    principalId: identityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.keyvault.contributorRoleId)
    principalType: principalType
    description: 'Permission for ${principalType} ${identityPrincipalId} to manage the key vault ${keyvault.name}'
  }
}

resource keyVault_Role_SecretOfficer 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addKeyVaultRoles) {
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : keyvault
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.keyvault.secretOfficerRoleId) : guid(keyvault.id, identityPrincipalId, roleDefinitions.keyvault.secretOfficerRoleId)
  properties: {
    principalId: identityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.keyvault.secretOfficerRoleId)
    principalType: principalType
    description: 'Permission for ${principalType} ${identityPrincipalId} to manage secrets in ${keyvault.name}'
  }
}
resource keyVault_Role_Administrator 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addKeyVaultRoles) {
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : keyvault
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.keyvault.administratorRoleId) : guid(keyvault.id, identityPrincipalId, roleDefinitions.keyvault.administratorRoleId)
  properties: {
    principalId: identityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.keyvault.administratorRoleId)
    principalType: principalType
    description: 'Permission for ${principalType} ${identityPrincipalId} to administer ${keyvault.name}'
  }
}

// ----------------------------------------------------------------------------------------------------
// AI Hub Roles
// ----------------------------------------------------------------------------------------------------
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01' existing = if (addAIHubRoles) {
  name: aiHubName
}
resource aiHub_Role_DataScientist 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addAIHubRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.ml.dataScientistRoleId) : guid(aiHub.id, identityPrincipalId, roleDefinitions.ml.dataScientistRoleId)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : aiHub
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.ml.dataScientistRoleId)
    description: 'Permission for ${principalType} ${identityPrincipalId} to be in Data Scientist Role'
  }
}

resource aiHub_Role_Administrator 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addAIHubRoles) {
  name: grantRolesAtResourceGroupLevel ? guid(resourceGroup().id, identityPrincipalId, roleDefinitions.ai.administrator) : guid(aiHub.id, identityPrincipalId, roleDefinitions.ai.administrator)
  scope: grantRolesAtResourceGroupLevel ? resourceGroup() : aiHub
  properties: {
    principalId: identityPrincipalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.ai.administrator)
    description: 'Permission for ${principalType} ${identityPrincipalId} to administer ${aiHubName}'
  }
}
