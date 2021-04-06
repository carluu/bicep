var nameModifier = 'cuuwindowsase'
var deployVnet = false

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
  name: '${testVnet.name}/${nameModifier}asesubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource testAse 'Microsoft.Web/hostingEnvironments@2020-10-01' = {
  name: '${nameModifier}ase'
  location: resourceGroup().location
  kind: 'ASEV2'
  properties: {
    name: '${nameModifier}ase'
    internalLoadBalancingMode:'None'
    location: resourceGroup().location
    virtualNetwork: {
      id: testSubnet.id
    }
    workerPools: [
      {
        workerSizeId: 0
        workerCount: 2
        workerSize: 'Small'
      }
    ]
  }
}

resource testAsp 'Microsoft.Web/serverfarms@2020-10-01' = {
  name: '${nameModifier}-asp'
  location: resourceGroup().location
  kind: ''
  sku: {
    tier: 'Isolated'
    name: 'I1'
  }
  properties: {
    hostingEnvironmentProfile: {
      id: testAse.id
    }
    isSpot: false
    isXenon: false
    hyperV: false
    reserved: false
  }
}

