var nameModifier = 'cuupefwd'
param vmpass string


// Client networking
// ***********************************************************************************************
resource clientVnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: '${nameModifier}-clientvnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource clientSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${clientVnet.name}/client'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource clientPeSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${clientVnet.name}/clientPe'
  properties: {
    addressPrefix: '10.0.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
  dependsOn: [
    clientSubnet
  ]
}
// ***********************************************************************************************

// Forwarder networking
// ***********************************************************************************************
resource fwderVnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: '${nameModifier}-fwdervnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
  }
}

resource fwderSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${fwderVnet.name}/fwder'
  properties: {
    addressPrefix: '10.1.0.0/24'
  }
}

resource fwderPeSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${fwderVnet.name}/fwderPe'
  properties: {
    addressPrefix: '10.1.1.0/24'
  }
  dependsOn: [
    fwderSubnet
  ]
}
// ***********************************************************************************************

// Target networking
// ***********************************************************************************************
resource targetVnet 'Microsoft.Network/virtualNetworks@2020-08-01'= {
  name: '${nameModifier}-targetvnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/16'
      ]
    }
  }
}

resource targetSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${targetVnet.name}/target'
  properties: {
    addressPrefix: '10.2.0.0/24'
  }
}
// ***********************************************************************************************


// Sample client VM
module clientVm '../../modules/VM/basic_ubuntu_vm.bicep' = {
  name: 'clientVm'
  params: {
    vmpass: vmpass
    nameModifier: '${nameModifier}client'
    pubip: true
    subnetId: clientSubnet.id
  }
}

// Forwarder setup
module fwder '../../modules/PrivateLinkForwarder/privatelink-fwder-full.bicep' = {
  name: 'fwder'
  params: {
    nameModifier: '${nameModifier}fwder'
    lbport: 443
    vmpass: vmpass
    subnetId: fwderSubnet.id
  }

}

