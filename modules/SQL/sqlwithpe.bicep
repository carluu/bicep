var nameModifier = 'sqlwithpe'
param subnetId string = ''
param adminPassword string

module testVnet '../Utility/basicvnet.bicep' = if(subnetId == ''){
  name: 'testvnet'
  params: {
    nameModifier: '${nameModifier}sql'
    pePolicies: 'Disabled'
  }
}

resource testPeForSql 'Microsoft.Network/privateEndpoints@2020-11-01' = {
  name: '${nameModifier}-pe'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: '${subnetId == '' ? testVnet.outputs.subnetId : subnetId}'
    }
    privateLinkServiceConnections: [
      {
        name: '${nameModifier}-pe'
        properties: {
          privateLinkServiceId: testSql.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
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
}
