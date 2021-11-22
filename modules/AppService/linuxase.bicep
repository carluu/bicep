param nameModifier string = 'cuubc'
param subnetId string = ''

module testVnet '../Utility/basicvnet.bicep' = if(subnetId == ''){
  name: 'testvnet'
  params: {
    nameModifier: '${nameModifier}ase'
  }
}

resource testAse 'Microsoft.Web/hostingEnvironments@2021-01-01' = {
  name: '${nameModifier}ase'
  location: resourceGroup().location
  kind: 'ASEV2'
  properties: {
    internalLoadBalancingMode:'None'
    osPreference: 'linux'
    virtualNetwork: {
      id: '${subnetId == '' ? testVnet.outputs.subnetId : subnetId}'
    }
    multiSize: 'Small' // Front end VM size
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

output aseProfile object = {
  id : testAse.id
}
output aspId string = testAsp.id
