param nameModifier string = 'cuubc'
param subnetId string = ''
param vmpass string
param lbport int = 1433
param region string = resourceGroup().location

module basevnet '../../modules/Utility/basicvnet.bicep' = if(subnetId == '') {
  name: 'basevnet'
  params: {
    nameModifier: '${nameModifier}plfwd'
    region: region
  }
}

module fwdervm1 'privatelink_fwder_vm.bicep' = {
  name: 'fwdervm1'
  params: {
    nameModifier: '${nameModifier}1'
    pubip: false
    vmpass: vmpass
    subnetId: '${subnetId == '' ? basevnet.outputs.subnetId : subnetId}'
    scriptdestport: lbport
    scriptsrcport: lbport
    scriptip: '10.10.10.10'
    region: region
  }
}

module fwdervm2 'privatelink_fwder_vm.bicep' = {
  name: 'fwdervm2'
  params: {
    nameModifier: '${nameModifier}2'
    pubip: false
    vmpass: vmpass
    subnetId: '${subnetId == '' ? basevnet.outputs.subnetId : subnetId}'
    scriptdestport: lbport
    scriptsrcport: lbport
    scriptip: '10.10.10.10'
    region: region
  }
}

resource loadbalancer 'Microsoft.Network/loadBalancers@2021-02-01' = {
  name: '${nameModifier}lb'
  dependsOn: [
    fwdervm1
    fwdervm2
  ]
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
            privateIPAllocationMethod: 'Dynamic'
            subnet: {
              id: '${subnetId == '' ? basevnet.outputs.subnetId : subnetId}'
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
                name: 'beaddress1'
                properties: {
                  ipAddress: fwdervm1.outputs.vmprivip
                }
              }
              {
                name: 'beaddress2'
                properties: {
                  ipAddress: fwdervm2.outputs.vmprivip
                }
              }
            ]
          }
        }
      ]
      loadBalancingRules: [
        {
          name: 'lbrule'
          properties: {
            backendAddressPool: {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', '${nameModifier}lb','bepool')
            }
            frontendIPConfiguration: {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', '${nameModifier}lb','feconfig')
            }
            backendPort: lbport
            frontendPort: lbport
            protocol: 'Tcp'
          }
        }
      ]
  }
}

output lbip string = loadbalancer.properties.frontendIPConfigurations[0].properties.privateIPAddress
