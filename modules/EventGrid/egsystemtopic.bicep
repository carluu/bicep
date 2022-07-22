param nameModifier string = 'cuubc'
param region string= resourceGroup().location
param sourceResource string
param resourceType string

// Create a storage account if no resource id specified just as a way to test
resource teststg 'Microsoft.Storage/storageAccounts@2021-08-01' = if (sourceResource == '') {
  name: '${nameModifier}teststg'
  location: region
  kind: 'StorageV2'
  sku: {
     name: 'Standard_LRS'
  } 
}

resource egtopic 'Microsoft.EventGrid/systemTopics@2021-12-01' = {
  name: '${nameModifier}-egsystop'
  location: region
  properties: {
    source: sourceResource == '' ? teststg.id : sourceResource
    topicType: sourceResource == '' ? 'Microsoft.Storage.StorageAccounts' : resourceType
  }
}
