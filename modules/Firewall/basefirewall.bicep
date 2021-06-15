param nameModifier string = 'cuubc'
param subnetId string = ''

resource fwpubip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${nameModifier}-fwpubip'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod:'Static'
    publicIPAddressVersion: 'IPv4'
  }
  sku: {
    name: 'Standard'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-02-01' = {
  name: '${nameModifier}-fw'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: fwpubip.id
          }
        }
      }
    ]
    applicationRuleCollections: [
      {
        name: 'allowAllApps'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 100
          rules: [
            {
              name: 'allowAll'
              protocols: [
                {
                  protocolType: 'Https'
                  port: 443
                }
                {
                  protocolType: 'Http' 
                  port: 80
                }
              ]
              sourceAddresses: [
                '*'
              ]
              targetFqdns: [
                '*'
              ]
            }
          ]
        }
      }
    ]
    networkRuleCollections: [
      {
        name: 'allowAllNet'
        properties: {
          action: {
            type: 'Allow'
          }
          priority: 100
          rules: [
            {
              name: 'allowAll'
              protocols: [
                'Any'
              ]
              sourceAddresses: [
                '*'
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '*'
              ]
            }
          ]
        }
      }
    ]    
  }
}

output firewallip string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
