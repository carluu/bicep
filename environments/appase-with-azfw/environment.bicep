var nameModifier = 'cuuenv1'
var aseMgmtIps = [
  '13.66.140.0/32'
  '13.67.8.128/32'
  '13.69.64.128/32'
  '13.69.227.128/32'
  '13.70.73.128/32'
  '13.71.170.64/32'
  '13.71.194.129/32'
  '13.75.34.192/32'
  '13.75.127.117/32'
  '13.77.50.128/32'
  '13.78.109.0/32'
  '13.89.171.0/32'
  '13.94.141.115/32'
  '13.94.143.126/32'
  '13.94.149.179/32'
  '20.36.106.128/32'
  '20.36.114.64/32'
  '20.37.74.128/32'
  '23.96.195.3/32'
  '23.102.135.246/32'
  '23.102.188.65/32'
  '40.69.106.128/32'
  '40.70.146.128/32'
  '40.71.13.64/32'
  '40.74.100.64/32'
  '40.78.194.128/32'
  '40.79.130.64/32'
  '40.79.178.128/32'
  '40.83.120.64/32'
  '40.83.121.56/32'
  '40.83.125.161/32'
  '40.112.242.192/32'
  '51.107.58.192/32'
  '51.107.154.192/32'
  '51.116.58.192/32'
  '51.116.155.0/32'
  '51.120.99.0/32'
  '51.120.219.0/32'
  '51.140.146.64/32'
  '51.140.210.128/32'
  '52.151.25.45/32'
  '52.162.106.192/32'
  '52.165.152.214/32'
  '52.165.153.122/32'
  '52.165.154.193/32'
  '52.165.158.140/32'
  '52.174.22.21/32'
  '52.178.177.147/32'
  '52.178.184.149/32'
  '52.178.190.65/32'
  '52.178.195.197/32'
  '52.187.56.50/32'
  '52.187.59.251/32'
  '52.187.63.19/32'
  '52.187.63.37/32'
  '52.224.105.172/32'
  '52.225.177.153/32'
  '52.231.18.64/32'
  '52.231.146.128/32'
  '65.52.172.237/32'
  '65.52.250.128/32'
  '70.37.57.58/32'
  '104.44.129.141/32'
  '104.44.129.243/32'
  '104.44.129.255/32'
  '104.44.134.255/32'
  '104.208.54.11/32'
  '104.211.81.64/32'
  '104.211.146.128/32'
  '157.55.208.185/32'
  '191.233.50.128/32'
  '191.233.203.64/32'
  '191.236.154.88/32'
]

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
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.Sql'
      }
      {
        service: 'Microsoft.EventHub'
      }
    ]
  }
}

module firewall '../../modules/Firewall/basefirewall.bicep' = {
  name: 'firewall'
  params: {
    nameModifier: nameModifier
    subnetId: fwsubnet.id
  }
}

resource aseroutetable 'Microsoft.Network/routeTables@2021-02-01' = {
  name: '${nameModifier}-asert'
  location: resourceGroup().location
}

resource aseroutes 'Microsoft.Network/routeTables/routes@2021-02-01' = [for (ip, count) in aseMgmtIps: {
  name: 'route${count}'
  parent: aseroutetable
  properties: {
    addressPrefix: ip
    nextHopType: 'Internet'
  }
}]

resource defaultroute 'Microsoft.Network/routeTables/routes@2021-02-01' = {
  name: 'defaultroute'
  parent: aseroutetable
  properties: {
    addressPrefix: '0.0.0.0/0'
    nextHopIpAddress: firewall.outputs.firewallip
    nextHopType: 'VirtualAppliance'
  }
}

resource asesubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${vnet.name}/${nameModifier}asesubnet'
  properties: {
    addressPrefix: '10.0.1.0/24'
    routeTable: {
      id: aseroutetable.id
    }
  }
}

module ase '../../modules/AppService/windowsase.bicep' = {
  name: 'windowsase'
  params: {
    nameModifier: nameModifier
    subnetId: asesubnet.id
  }
  dependsOn: aseroutes
}
