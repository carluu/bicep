param nameModifier string = 'cuubc'
param subnetId string = ''

module testVnet '../Utility/basicvnet.bicep' = if(subnetId == ''){
  name: 'testvnet'
  params: {
    nameModifier: nameModifier
  }
}

resource pubIp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${nameModifier}-pubip'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod:'Dynamic'
    publicIPAddressVersion: 'IPv4'
  }
}

resource appgw 'Microsoft.Network/applicationGateways@2020-11-01' = {
  dependsOn: [
    pubIp
  ]
  name: '${nameModifier}appgw'
  location: resourceGroup().location
  properties: {
    sku: {
      capacity: 1
      name: 'Standard_Small'
      tier: 'Standard'
    }
    gatewayIPConfigurations:[
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${subnetId == '' ? testVnet.outputs.subnetId : subnetId }'
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'feconfig1'
        properties: {
          publicIPAddress: {
            id: pubIp.id
          }
        }
      }
    ]
    frontendPorts:[
      {
        name: 'feport1'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bepool1'
        properties: {
          backendAddresses: [
            {
              fqdn: 'test'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'behttpsettings1'
        properties: {
          port: 80
          protocol: 'Http'
        }
      }
    ]
    httpListeners: [
      {
        name: 'httplistener1'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', '${nameModifier}appgw','feconfig1')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', '${nameModifier}appgw','feport1')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'routingrule1'
        properties: {
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', '${nameModifier}appgw','httplistener1')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', '${nameModifier}appgw','bepool1')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', '${nameModifier}appgw','behttpsettings1')
          }
        }
      }
    ]
  }
}

