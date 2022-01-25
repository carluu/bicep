param storename string = 'cuubc23-appconfig'

resource appconfigvalue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-03-01-preview' = {
  name: '${storename}/secret6'
  properties: {
    contentType: 'string'
    value: 'hello6'
  }
}
