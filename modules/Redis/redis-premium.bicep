param nameModifier string = 'cuubc'

resource redis 'Microsoft.Cache/redis@2021-06-01' = {
  location: resourceGroup().location
  name: '${nameModifier}-redis'
  properties: {
    sku: {
      capacity: 1
      family: 'P'
      name: 'Premium'
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
  }

}
