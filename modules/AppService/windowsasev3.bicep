param nameModifier string = 'cuubc'
param subnetId string = ''

module testVnet '../Utility/basicvnet-with-se.bicep' = if(subnetId == ''){
  name: 'testvnet'
  params: {
    nameModifier: nameModifier
  }
}

resource testAse 'Microsoft.Web/hostingEnvironments@2021-01-01' = {
  name: '${nameModifier}ase'
  location: resourceGroup().location
  kind: 'ASEv3'
  properties: {
    dedicatedHostCount: 0
    zoneRedundant: false
    internalLoadBalancingMode: 'Web, Publishing'
    virtualNetwork: {
      id: '${subnetId == '' ? testVnet.outputs.subnetId : subnetId}'
    }    
  }
}

// resource testAsp 'Microsoft.Web/serverfarms@2020-10-01' = {
//   name: '${nameModifier}-asp'
//   location: resourceGroup().location
//   kind: ''
//   sku: {
//     tier: 'Isolated'
//     name: 'I1'
//   }
//   properties: {
//     hostingEnvironmentProfile: {
//       id: testAse.id
//     }
//     isSpot: false
//     isXenon: false
//     hyperV: false
//     reserved: false
//   }
// }
