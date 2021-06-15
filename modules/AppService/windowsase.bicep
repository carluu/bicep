param nameModifier string = 'cuubc'
param subnetId string = ''

resource testVnet 'Microsoft.Network/virtualNetworks@2020-08-01' = if(subnetId == ''){
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

resource testSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = if(subnetId == ''){
  name: '${testVnet.name}/${nameModifier}asesubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource testAse 'Microsoft.Web/hostingEnvironments@2021-01-01' = {
  name: '${nameModifier}ase'
  location: resourceGroup().location
  kind: 'ASEV2'
  properties: {
    internalLoadBalancingMode:'None'
    virtualNetwork: {
      id: '${subnetId == '' ? testSubnet.id : subnetId}'
    }
    multiSize: 'Small' // Front ennd VM size
    frontEndScaleFactor: 15 // How many app service instances per front end
    clusterSettings: [ // see: https://docs.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-custom-settings
      {
        name: 'DisableTls1.0'
        value: '1'
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

