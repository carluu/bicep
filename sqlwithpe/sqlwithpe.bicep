var nameModifier = 'sqlwithpe'
var deployVnet = true
param adminPassword string

resource testVnet 'Microsoft.Network/virtualNetworks@2020-08-01' = if(deployVnet){
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

resource testSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = if(deployVnet){
  name: '${testVnet.name}/${nameModifier}fwsubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource testPeForSql 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: '${nameModifier}-pe'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: testSubnet.id
    }
  }
}

resource testSql 'Microsoft.Sql/servers@2020-11-01-preview' = {
  name: '${nameModifier}-sql'
  location: resourceGroup().location
  properties: {
      administratorLogin: 'testpeadmin'
      administratorLoginPassword: adminPassword
      publicNetworkAccess: 'Disabled'
  }
  resource testSqlPEC 'privateEndpointConnections@2020-11-01-preview' = {
    name: '${nameModifier}-sqlpec'
    properties: {
      privateEndpoint: {
        id: testPeForSql.id
      }
    }
  }
}
