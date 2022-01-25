resource storageacct 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  kind: 'StorageV2'
  name: 'hellostorageforcuu'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    
  }
}
