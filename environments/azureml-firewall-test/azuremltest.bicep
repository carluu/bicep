/* TODO: Fix the private endpoint link
* If using firewall for tracing traffic, add:
* -- Network rule for File on 445 (unless using PE on customer storage)
* -- NTP (123) rule
* -- App rule for all HTTP/HTTPS traffic
*/

var nameModifier = 'amlenv'
@secure()
param vmpass string

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
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

resource fwsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${vnet.name}/AzureFirewallSubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

module firewall '../../modules/Firewall/basefirewall.bicep' = {
  name: 'firewall'
  params: {
    nameModifier: nameModifier
    subnetId: fwsubnet.id
  }
}

resource fwroute 'Microsoft.Network/routeTables@2021-03-01' = {
  name: '${nameModifier}-rt'
  location: resourceGroup().location
  properties: {
    routes: [
      {
        name: 'routetofw'
        properties: {
          nextHopType: 'VirtualAppliance'
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: firewall.outputs.firewallip
        }
      }
    ]
  }
}

resource amlsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${vnet.name}/amlsubnet'
  properties: {
    addressPrefix: '10.0.1.0/24' 
    privateEndpointNetworkPolicies: 'Disabled' 
    privateLinkServiceNetworkPolicies: 'Disabled'
    routeTable: {
      id: fwroute.id
    }
  }
  dependsOn: [
    fwsubnet
  ]
}

resource vmsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${vnet.name}/vmsubnet'
  properties: {
    addressPrefix: '10.0.2.0/24'  
  }
  dependsOn: [
    amlsubnet
  ]
}

module amlworkspace '../../modules/AzureML/amlworkspace-private.bicep' = {
  name: 'amlworkspace'
  params: {
    subnetId: amlsubnet.id
    vnetId: vnet.id
    nameModifier: nameModifier
  }
  dependsOn: [
    amlsubnet
  ]
}

module adminvm '../../modules/VM/basic_windows_vm.bicep' = {
  name: 'adminvm'
  params: {
    nameModifier: nameModifier
    subnetId: vmsubnet.id
    vmpass: vmpass
  }
  dependsOn: [
    vmsubnet
  ]
}


