var nameModifier = 'cuubc'

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
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

resource asesubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${vnet.name}/${nameModifier}asesubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource appgwsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${vnet.name}/${nameModifier}appgwsubnet'
  properties: {
    addressPrefix: '10.0.1.0/24'
  }
}

module ase '../../modules/AppService/windowsase.bicep' = {
  name: 'windowsase'
  params: {
    nameModifier: nameModifier
    subnetId: asesubnet.id
  }
}

module appgw '../../modules/AppGateway/appgateway.bicep' = {
  name: 'appgw'
  params: {
    nameModifier: nameModifier
    subnetId: appgwsubnet.id
  }
}
