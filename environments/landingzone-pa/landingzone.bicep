var nameModifier = 'landingzone'
var deployVnet = true

resource testVnet 'Microsoft.Network/virtualNetworks@2020-08-01' = if(deployVnet){
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

resource testSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = if(deployVnet){
  name: '${testVnet.name}/${nameModifier}fwsubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource vmSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${testVnet.name}/${nameModifier}vmsubnet'
  properties: {
    addressPrefix: '10.0.1.0/24'
  }
}
