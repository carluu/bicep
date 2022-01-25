param nameModifier string = 'astesting'
param peSubnetId string = ''
param egressSubnetId string = ''

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = if (peSubnetId == '' && egressSubnetId == '') {
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

resource pesubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = if (peSubnetId == '') {
  name: '${vnet.name}/pesubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource egresssubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = if (egressSubnetId == '') {
  name: '${vnet.name}/egresssubnet'
  properties: {
    addressPrefix: '10.0.1.0/24'
    delegations: [
      {
        name: 'webdelegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
}

resource asp 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${nameModifier}-asp'
  location: resourceGroup().location
  kind: 'app'
  sku: {
    name: 'P1v3'
    tier: 'PremiumV3'
    size: 'P1v3'
    family: 'Pv3'
    capacity: 1
  }
  properties: {
    zoneRedundant: false
  }
}

resource webapp 'Microsoft.Web/sites@2021-02-01' = {
  name: '${nameModifier}-webapp'
  location: resourceGroup().location
  kind: 'app'
  properties: {
    serverFarmId: asp.id
    virtualNetworkSubnetId: '${egressSubnetId == '' ? egresssubnet.id : egressSubnetId}'
  }
  resource webconfig 'config@2021-02-01' = {
    name: 'web'
    kind: 'web'
    properties: {
      //numberOfWorkers: 3
      vnetRouteAllEnabled: true
    }
  }
}

resource webapppe 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${nameModifier}-webapppe'
  location: resourceGroup().location
  properties: {
    subnet: {
       id: '${peSubnetId == '' ? pesubnet.id : peSubnetId}'
    }
    privateLinkServiceConnections: [
      {
        name: '${nameModifier}-pecxn'
        properties: {
          privateLinkServiceId: webapp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}
