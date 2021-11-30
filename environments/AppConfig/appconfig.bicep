param nameModifier string = 'cuubc23'

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: '${nameModifier}-appconfig'
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: false
    publicNetworkAccess: 'Enabled'
  }
  location: resourceGroup().location

}

resource appconfigvalue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-03-01-preview' = {
  name: '${appconfig.name}/secret'
  properties: {
    contentType: 'string'
    value: 'hello'
  }
}
