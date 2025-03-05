param nsgName string
param location string
param tags object = {}
param myIpAddress string = ''
param existingVnetName string = ''

var useExistingResource = !empty(existingVnetName)

var myPersonalRule = myIpAddress == '' ? [] : [
  {
        name: 'AllowMyIP'
        properties: {
          priority: 140
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourceAddressPrefix: myIpAddress
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
    }
]

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-05-01' = if (useExistingResource) {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: union(myPersonalRule, [
      {
        name: 'AllowAnyCustom8080Inbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAnyCustom8000Inbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '8000'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAnyCustom443Inbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAnyCustom80Inbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAllOutbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
    ])
  }
}

output id string = useExistingResource ? '' : networkSecurityGroup.id
output name string = useExistingResource ? '' : networkSecurityGroup.name
