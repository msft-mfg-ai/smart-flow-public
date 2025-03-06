param location string = resourceGroup().location
param modelLocation string = location

param existingVirtualNetworkName string = ''
param existingVnetResourceGroupName string = resourceGroup().name
param newVirtualNetworkName string = ''
param vnetAddressPrefix string

param subnet1Name string
param subnet2Name string
param subnet1Prefix string
param subnet2Prefix string
param otherSubnets object[] = []
param networkSecurityGroupId string

var useExistingResource = !empty(existingVirtualNetworkName)

resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = if (useExistingResource) {
  name: existingVirtualNetworkName
  scope: resourceGroup(existingVnetResourceGroupName)
  resource subnet1 'subnets' existing = {
    name: subnet1Name
  }
  resource subnet2 'subnets' existing = {
    name: subnet2Name
  }
}

var moreSubnets = [
  for subnet in otherSubnets: {
    name: subnet.name
    properties: union(
      subnet.properties,
      !useExistingResource ? { networkSecurityGroup: { id: networkSecurityGroupId } } : {}
    )
  }
]

resource newVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = if (!useExistingResource) {
  name: newVirtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: union(
      [
        {
          name: subnet1Name
          properties: {
            addressPrefix: subnet1Prefix
            networkSecurityGroup: {
              id: networkSecurityGroupId
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
            networkSecurityGroup: {
              id: networkSecurityGroupId
            }
            delegations: [
              {
                name: 'Microsoft.app/environments'
                properties: { serviceName: 'Microsoft.app/environments' }
              }
            ]
          }
        }
      ],
      moreSubnets
    )
  }

  resource subnet1 'subnets' existing = {
    name: subnet1Name
  }

  resource subnet2 'subnets' existing = {
    name: subnet2Name
  }
}

output vnetResourceId string = useExistingResource ? existingVirtualNetwork.id : newVirtualNetwork.id
output vnetName string = useExistingResource ? existingVirtualNetwork.name : newVirtualNetwork.name
output vnetAddressPrefix string = useExistingResource ? existingVirtualNetwork.properties.addressSpace.addressPrefixes[0] : newVirtualNetwork.properties.addressSpace.addressPrefixes[0]
output subnet1ResourceId string = useExistingResource ? existingVirtualNetwork::subnet1.id : newVirtualNetwork::subnet1.id
output subnet2ResourceId string = useExistingResource ? existingVirtualNetwork::subnet2.id : newVirtualNetwork::subnet2.id
output allSubnets array = useExistingResource ? existingVirtualNetwork.properties.subnets : newVirtualNetwork.properties.subnets
