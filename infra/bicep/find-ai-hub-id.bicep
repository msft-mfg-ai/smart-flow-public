// --------------------------------------------------------------------------------------------------------------
// Bicep file to locate an existing AI Hub by name
// --------------------------------------------------------------------------------------------------------------
// You can test it with these commands:
//   az deployment group create -n find-hub --resource-group rg-ai-ll-sfpub-130-dev --template-file 'find-ai-hub-id.bicep' --parameters environmentName=dev applicationName=ll-sfpub-130
// --------------------------------------------------------------------------------------------------------------

targetScope = 'resourceGroup'

// you can supply a full application name, or you don't it will append resource tokens to a default suffix
@description('Full Application Name (supply this or use default of prefix+token)')
param applicationName string = ''
@description('If you do not supply Application Name, this prefix will be combined with a token to create a unique applicationName')
param applicationPrefix string = 'ai_doc'

@description('The environment code (i.e. dev, qa, prod)')
param environmentName string = 'dev'

@description('Primary location for all resources')
param location string = resourceGroup().location

@description('Set this if you want to append all the resource names with a unique token')
param appendResourceTokens bool = false

// --------------------------------------------------------------------------------------------------------------
// A variable masquerading as a parameter to allow for dynamic value assignment in Bicep
// --------------------------------------------------------------------------------------------------------------
param runDateTime string = utcNow()

// --------------------------------------------------------------------------------------------------------------
// -- Variables -------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
var resourceToken = toLower(uniqueString(resourceGroup().id, location))

// if user supplied a full application name, use that, otherwise use default prefix and a unique token
var appName = applicationName != '' ? applicationName : '${applicationPrefix}_${resourceToken}'

var deploymentSuffix = '-${runDateTime}'

// --------------------------------------------------------------------------------------------------------------
// -- Generate Resource Names -----------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
module resourceNames 'resourcenames.bicep' = {
  name: 'resource-names${deploymentSuffix}'
  params: {
    applicationName: appName
    environmentName: environmentName
    resourceToken: appendResourceTokens ? resourceToken : ''
  }
}

resource aiHubExisting 'Microsoft.MachineLearningServices/workspaces@2024-10-01' existing = {
  name:  resourceNames.outputs.aiHubName
}

// --------------------------------------------------------------------------------------------------------------
// -- Outputs ---------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
output AI_HUB_ID string = aiHubExisting.id
output AI_HUB_NAME string = aiHubExisting.name
output AI_PROJECT_NAME string = resourceNames.outputs.aiHubProjectName
