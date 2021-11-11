// Paramterized version of App Gateway template
param nameModifier string = 'cuubc'
param subnetId string = ''

@allowed([
  'Standard_Large'
  'Standard_Medium'
  'Standard_Small'
  'Standard_v2'
  'WAF_Large'
  'WAF_Medium'
  'WAF_v2'
])
param size string

@allowed([
  'Standard'
  'Standard_v2'
  'WAF'
  'WAF_v2'
])
param tier string

param port int
param backendFqdn string

module testVnet '../Utility/basicvnet.bicep' = if(subnetId == ''){
  name: 'testvnet'
  params: {
    nameModifier: '${nameModifier}appgw'
  }
}

resource pubIp 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${nameModifier}-pubip'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod:'Static'
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
      name: size
      tier: tier
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
          port: port
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bepool1'
        properties: {
          backendAddresses: [
            {
              fqdn: backendFqdn
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'behttpsettings1'
        properties: {
          port: port
          protocol: port == 80 ? 'Http' : 'Https'
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
          protocol: port == 80 ? 'Http' : 'Https'
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

