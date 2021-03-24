var location = 'eastus2'

resource testVirtualNetwork 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: 'biceptestvnet3'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/8'
      ]
    }
  }
}

resource bicepnsg 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: 'bicepnsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'testrule'
        properties: {
          protocol: '*'
          access: 'Allow'
          direction:'Inbound'
          destinationAddressPrefix: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          priority: 1000
        }
      }
    ]    
  }
}

resource testSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {

  name: 'biceptestvnet3/biceptestsubnet'
  dependsOn: [
    testVirtualNetwork
  ]
  properties: {
    addressPrefix: '10.0.0.0/28'
    networkSecurityGroup:{
      id: bicepnsg.id
    }

  }
}
