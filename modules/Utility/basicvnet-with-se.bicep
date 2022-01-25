param nameModifier string = 'cuubc'
@allowed([
  'Enabled'
  'Disabled'
])
param pePolicies string = 'Enabled'
param isFirewall bool = false

resource testVnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: '${nameModifier}-vnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/8'
      ]
    }
  }
}

resource testSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${testVnet.name}/${isFirewall == true ? 'AzureFirewallSubet' : 'default'}'
  properties: {
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.Sql'
      }
      {
        service: 'Microsoft.EventHub'
      }
    ]
    privateEndpointNetworkPolicies: pePolicies
  }
}

output vnetId string = testVnet.id
output vnetName string = testVnet.name
output subnetId string = testSubnet.id
