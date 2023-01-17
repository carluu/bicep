param region string = resourceGroup().location
resource storageacct 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  kind: 'StorageV2'
  name: 'hellostorageforcuu'
  location: region
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    
  }
}
