param existing_CogServices_Name string = ''
param existing_CogServices_ResourceGroupName string = resourceGroup().name
param name string = ''
param location string = resourceGroup().location
param tags object = {}
param kind string = 'OpenAI'
param sku object = { name: 'S0' }
param deployments array = []
param pe_location string = location
param publicNetworkAccess string = ''
param privateEndpointSubnetId string = ''
param privateEndpointName string = ''
param managedIdentityId string = ''
@description('Provide the admin IP address to allow access to the Cog Services Account')
param myIpAddress string = ''

// --------------------------------------------------------------------------------------------------------------
// Variables
// --------------------------------------------------------------------------------------------------------------
var resourceGroupName = resourceGroup().name
var useExistingService = !empty(existing_CogServices_Name)
var cognitiveServicesKeySecretName = 'cognitive-services-key'

// --------------------------------------------------------------------------------------------------------------
resource existingAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = if (useExistingService) {
  name: existing_CogServices_Name
  scope: resourceGroup(existing_CogServices_ResourceGroupName)
}

// --------------------------------------------------------------------------------------------------------------
resource account 'Microsoft.CognitiveServices/accounts@2024-10-01' = if (!useExistingService) {
  name: name
  location: location
  tags: tags
  kind: kind
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: { '${managedIdentityId}': {} }
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: publicNetworkAccess == 'Enabled' ? 'Allow' : 'Deny'
      ipRules: empty(myIpAddress) ? [] : [ { value: myIpAddress } ]
    }
    customSubDomainName: name
  }
  sku: sku
}

@batchSize(1)
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = [
  for deployment in deployments: if (!useExistingService) {
    parent: account
    name: deployment.name
    properties: {
      model: deployment.model
      // // use the policy in the deployment if it exists, otherwise default to null
      // raiPolicyName: deployment.?raiPolicyName ?? null
    }
    // use the sku in the deployment if it exists, otherwise default to standard
    sku: deployment.?sku ?? { name: 'Standard', capacity: 20 }
  }
]

module privateEndpoint '../networking/private-endpoint.bicep' = if (empty(existing_CogServices_Name) && !empty(privateEndpointSubnetId)) {
  name: '${name}-private-endpoint'
  dependsOn: deployment
  params: {
    location: pe_location
    privateEndpointName: privateEndpointName
    groupIds: ['account']
    targetResourceId: account.id
    subnetId: privateEndpointSubnetId
  }
}

// --------------------------------------------------------------------------------------------------------------
// Outputs
// --------------------------------------------------------------------------------------------------------------
output id string = !empty(existing_CogServices_Name) ? existingAccount.id : account.id
output name string = !empty(existing_CogServices_Name) ? existingAccount.name : account.name
output endpoint string = !empty(existing_CogServices_Name) ? existingAccount.properties.endpoint : account.properties.endpoint
output resourceGroupName string = !empty(existing_CogServices_Name) ? existing_CogServices_ResourceGroupName : resourceGroupName
output cognitiveServicesKeySecretName string = cognitiveServicesKeySecretName
output privateEndpointName string = privateEndpointName
output deployments array = deployments
