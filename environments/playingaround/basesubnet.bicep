var addrSpace = '10.1.0.0/28'
var location = 'eastus2'
param vnetName string
param nsgId string
param rtId string

resource testSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {

  name: '${vnetName}/biceptestsubnet1'
  properties: {
    addressPrefix: addrSpace
    networkSecurityGroup:{
      id: nsgId
    }
    routeTable: {
      id: rtId
    }
  }
}
