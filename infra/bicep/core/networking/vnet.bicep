// --------------------------------------------------------------------------------------------------------------
// VNET
// --------------------------------------------------------------------------------------------------------------
param location string = resourceGroup().location
param modelLocation string = location

param existingVirtualNetworkName string = ''
param existingVnetResourceGroupName string = resourceGroup().name
param newVirtualNetworkName string = ''
param vnetAddressPrefix string

param subnet1Name string
param subnet2Name string
param subnet3Name string
param subnet1Prefix string
param subnet2Prefix string
param subnet3Prefix string

param myIpAddress string = ''

param deploymentSuffix string = ''

// --------------------------------------------------------------------------------------------------------------
var useExistingResource = !empty(existingVirtualNetworkName)

// --------------------------------------------------------------------------------------------------------------
resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = if (useExistingResource) {
  name: existingVirtualNetworkName
  scope: resourceGroup(existingVnetResourceGroupName)
  resource subnet1 'subnets' existing = {
    name: subnet1Name
  }
  resource subnet2 'subnets' existing = {
    name: subnet2Name
  }
  resource subnet3 'subnets' existing = {
    name: subnet3Name
  }
}

module networkSecurityGroup './network-security-group.bicep' = if (!useExistingResource) {
  name: 'nsg${deploymentSuffix}'
  params: {
    nsgName: '${newVirtualNetworkName}-nsg-${location}'
    location: location
    myIpAddress: myIpAddress
  }
}

resource newVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = if (!useExistingResource) {
  name: newVirtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: subnet1Prefix
          networkSecurityGroup: {
            id: networkSecurityGroup.outputs.id
          }
          serviceEndpoints: [
            { service: 'Microsoft.KeyVault', locations: [ location ]}
            { service: 'Microsoft.Storage', locations: [ location ]}
            { service: 'Microsoft.CognitiveServices', locations: [ modelLocation ]}
          ]
        }
      }
      {
        // The subnet of the managed environment must be delegated to the service 'Microsoft.App/environments'
        name: subnet2Name
        properties: {
          addressPrefix: subnet2Prefix
          networkSecurityGroup: { id: networkSecurityGroup.outputs.id }
          delegations: [
            { name: 'Microsoft.app/environments', properties: { serviceName: 'Microsoft.app/environments' } }
          ]
        }
      }
      {
        name: subnet3Name 
        properties: {
          addressPrefix: subnet3Prefix
          networkSecurityGroup: { id: networkSecurityGroup.outputs.id }
          delegations: [
            { name: 'Microsoft.app/environments', properties: { serviceName: 'Microsoft.app/environments' } }
          ]
        }
      }
    ]
  }

  resource subnet1 'subnets' existing = {
    name: subnet1Name
  }

  resource subnet2 'subnets' existing = {
    name: subnet2Name
  }
  resource subnet3 'subnets' existing = {
    name: subnet3Name
  }
}

output vnetResourceId string = useExistingResource ? existingVirtualNetwork.id : newVirtualNetwork.id
output vnetName string = useExistingResource ? existingVirtualNetwork.name : newVirtualNetwork.name
output vnetAddressPrefix string = useExistingResource ? existingVirtualNetwork.properties.addressSpace.addressPrefixes[0] : newVirtualNetwork.properties.addressSpace.addressPrefixes[0]
output subnet1ResourceId string = useExistingResource ? existingVirtualNetwork::subnet1.id : newVirtualNetwork::subnet1.id
output subnet2ResourceId string = useExistingResource ? existingVirtualNetwork::subnet2.id : newVirtualNetwork::subnet2.id
output subnet3ResourceId string = useExistingResource ? existingVirtualNetwork::subnet3.id : newVirtualNetwork::subnet3.id
output allSubnets array = useExistingResource ? existingVirtualNetwork.properties.subnets : newVirtualNetwork.properties.subnets
