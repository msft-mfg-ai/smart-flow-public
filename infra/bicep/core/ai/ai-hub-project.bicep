// Creates an Azure AI resource with proxied endpoints for the Azure AI services provider

// When using the Project - I get an error: 
//   "your project does not have permission to access the connected Azure OpenAI resource because its connection is set to
//    use role-based authentication. To resolve this issue, you can either assign the role of Azure AI Developer to your project 
//    for the resource, or change the connection's authentication method to use an API key and try again. 


@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI Project name')
param aiProjectName string

@description('AI Project display name')
param aiProjectFriendlyName string = aiProjectName

@description('AI Project description')
param aiProjectDescription string

@description('Resource ID of the AI Hub resource')
param aiHubId string

/* @description('Name for capabilityHost.')
param capabilityHostName string 

@description('Name for ACS connection.')
param acsConnectionName string

@description('Name for ACS connection.')
param aoaiConnectionName string */

//for constructing endpoint
var subscriptionId = subscription().subscriptionId
var resourceGroupName = resourceGroup().name

var projectConnectionString = '${location}.api.azureml.ms;${subscriptionId};${resourceGroupName};${aiProjectName}'

// var storageConnections = ['${aiProjectName}/workspaceblobstore']
// var aiSearchConnection = ['${acsConnectionName}']
// var aiServiceConnections = ['${aoaiConnectionName}']

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: aiProjectName
  location: location
  tags: union(tags, {
    ProjectConnectionString: projectConnectionString
  })
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // organization
    friendlyName: aiProjectFriendlyName
    description: aiProjectDescription

    // dependent resources
    hubResourceId: aiHubId
  
  }
  kind: 'project'

  // Resource definition for the capability host
  #disable-next-line BCP081
/*   resource capabilityHost 'capabilityHosts@2024-10-01-preview' = {
    name: '${aiProjectName}-${capabilityHostName}'
    properties: {
      capabilityHostKind: 'Agents'
      aiServicesConnections: aiServiceConnections
      vectorStoreConnections: aiSearchConnection
      storageConnections: storageConnections
    }
  } */
}

resource waitScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'WaitForProjectDeployment'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '10.0'
    scriptContent: '''
      Write-Output "Starting wait script..."
      Start-Sleep -Seconds 120  # Wait for 2 minutes
      Write-Output "Wait completed. Proceeding with deployment..."
    '''
    retentionInterval: 'PT1H'
    cleanupPreference: 'OnSuccess'
  }
  dependsOn: [
    aiProject
  ]
}

output name string = aiProject.name
output id string = aiProject.id
output principalId string = aiProject.identity.principalId
output workspaceId string = aiProject.properties.workspaceId
output connectionString string = aiProject.tags.ProjectConnectionString
