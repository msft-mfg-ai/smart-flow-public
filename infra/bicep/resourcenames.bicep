// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Bicep file that builds all the resource names used by other Bicep templates
// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
param applicationName string = ''

// @allowed(['azd','dev','demo','qa','stg','ct','prod'])
param environmentName string = 'dev'

@description('Optional resource token to ensure uniqueness - leave blank if desired')
param resourceToken string = ''

param location string = resourceGroup().location

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
var sanitizedEnvironment = toLower(environmentName)
var sanitizedAppNameWithDashes = replace(replace(toLower(applicationName), ' ', ''), '_', '')
var sanitizedAppName = replace(replace(replace(toLower(applicationName), ' ', ''), '-', ''), '_', '')

var resourceTokenWithDash = resourceToken == '' ? '' : '-${resourceToken}'
var resourceTokenWithoutDash = resourceToken == '' ? '' : '${resourceToken}'

// pull resource abbreviations from a common JSON file
var resourceAbbreviations = loadJsonContent('./data/abbreviation.json')

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
output webSiteName string                 = toLower('${sanitizedAppNameWithDashes}-${sanitizedEnvironment}${resourceTokenWithDash}')
output webSiteAppServicePlanName string   = toLower('${sanitizedAppName}-${resourceAbbreviations.webServerFarms}-${sanitizedEnvironment}${resourceTokenWithDash}')

output appInsightsName string             = toLower('${sanitizedAppName}-${resourceAbbreviations.insightsComponents}-${sanitizedEnvironment}${resourceTokenWithDash}')
output logAnalyticsWorkspaceName string   = toLower('${sanitizedAppName}-${resourceAbbreviations.operationalInsightsWorkspaces}-${sanitizedEnvironment}${resourceTokenWithDash}')
output azureMonitorPLSName string         = toLower('${sanitizedAppName}-${resourceAbbreviations.networkPrivateLinkServices}monitor-${sanitizedEnvironment}${resourceTokenWithDash}')

output cosmosName string                  = toLower('${sanitizedAppName}-${resourceAbbreviations.documentDBDatabaseAccounts}-${sanitizedEnvironment}${resourceTokenWithDash}')

output searchServiceName string           = toLower('${sanitizedAppName}-${resourceAbbreviations.searchSearchServices}-${sanitizedEnvironment}${resourceTokenWithDash}')
output cogServiceName string              = toLower('${sanitizedAppName}-${resourceAbbreviations.cognitiveServicesAccounts}-${sanitizedEnvironment}${resourceTokenWithDash}')
output documentIntelligenceServiceName string = toLower('${sanitizedAppName}-${resourceAbbreviations.cognitiveServicesFormRecognizer}${sanitizedEnvironment}${resourceTokenWithDash}')

output aiHubName string                   = toLower('${sanitizedAppName}-${resourceAbbreviations.cognitiveServicesHub}-${sanitizedEnvironment}${resourceTokenWithDash}')
output aiHubProjectName string            = toLower('${sanitizedAppName}-${resourceAbbreviations.cognitiveServicesHub}-Project-${sanitizedEnvironment}${resourceTokenWithDash}')

output caManagedEnvName string            = toLower('${sanitizedAppName}-${resourceAbbreviations.appManagedEnvironments}-${sanitizedEnvironment}${resourceToken}')
// CA name must be lower case alpha or '-', must start and end with alpha, cannot have '--', length must be <= 32
output containerAppAPIName string         = take(toLower('${sanitizedAppName}-${resourceAbbreviations.appContainerApps}-api-${sanitizedEnvironment}${resourceTokenWithDash}'), 32)
output containerAppUIName string          = take(toLower('${sanitizedAppName}-${resourceAbbreviations.appContainerApps}-ui-${sanitizedEnvironment}${resourceTokenWithDash}'), 32)
output containerAppBatchName string       = take(toLower('${sanitizedAppName}-${resourceAbbreviations.appContainerApps}-batch-${sanitizedEnvironment}${resourceTokenWithDash}'), 32)

output caManagedIdentityName string       = toLower('${sanitizedAppName}-${resourceAbbreviations.appManagedEnvironments}-${resourceAbbreviations.managedIdentityUserAssignedIdentities}-${sanitizedEnvironment}${resourceToken}')
output kvManagedIdentityName string       = toLower('${sanitizedAppName}-${resourceAbbreviations.keyVaultVaults}-${resourceAbbreviations.managedIdentityUserAssignedIdentities}-${sanitizedEnvironment}${resourceToken}')
output userAssignedIdentityName string    = toLower('${sanitizedAppName}-app-${resourceAbbreviations.managedIdentityUserAssignedIdentities}')

var vnetName                              = toLower('${sanitizedAppName}-${resourceAbbreviations.networkVirtualNetworks}-${sanitizedEnvironment}${resourceTokenWithDash}')
output vnet_Name string                   = vnetName
output vnetAppSubnetName string           = toLower('snet-app')
output vnetPeSubnetName string            = toLower('snet-prv-endpoint')
output vnetAgentSubnetName string         = toLower('snet-agents')
output nsgName string                     = toLower('${vnetName}-${resourceAbbreviations.networkNetworkSecurityGroups}-${location}')

// ----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Container Registry, Key Vaults and Storage Account names are only alpha numeric characters limited length
var acrName                               = take('${sanitizedAppName}${resourceAbbreviations.containerRegistryRegistries}${sanitizedEnvironment}${resourceTokenWithoutDash}', 50)
output ACR_Name string                    = acrName
output ACR_FQDN string                    = '${acrName}.azurecr.io'
output keyVaultName string                = take('${sanitizedAppName}${resourceAbbreviations.keyVaultVaults}${sanitizedEnvironment}${resourceTokenWithoutDash}', 24)
output storageAccountName string          = take('${sanitizedAppName}${resourceAbbreviations.storageStorageAccounts}${sanitizedEnvironment}${resourceTokenWithoutDash}', 24)
