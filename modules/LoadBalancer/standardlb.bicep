param nameModifier string = 'cuubc'
param subnetId string = ''
param region string = resourceGroup().location

module basevnet '../../modules/Utility/basicvnet.bicep' = if(subnetId == '') {
  name: 'basevnet'
  params: {
    nameModifier: '${nameModifier}ilb'
    region: region
  }
}

resource loadbalancer 'Microsoft.Network/loadBalancers@2021-02-01' = {
  name: '${nameModifier}-lb'
  location: region
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
      frontendIPConfigurations: [
        {
          name: 'feconfig'
          properties: {
            privateIPAddressVersion: 'IPv4'
            privateIPAllocationMethod: 'Static'
            subnet: {
              id: subnetId == '' ? basevnet.outputs.subnetId : subnetId
            }
          }
        }
      ]
      backendAddressPools: [
        {
          name: 'bepool'
          properties: {
            loadBalancerBackendAddresses: [
              {
                name: 'beaddress'
                properties: {
                  ipAddress: '10.10.10.10'
                }
              }
            ]
          }
        }
      ]
  }
}
