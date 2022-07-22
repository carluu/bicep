param nameModifier string = 'cuueg'
param region string= resourceGroup().location

resource storage 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${nameModifier}stg'
  kind: 'StorageV2'
  location: region
  sku: {
    name: 'Standard_LRS'
  }
}

resource egtopic 'Microsoft.EventGrid/systemTopics@2021-12-01' = {
  name: '${nameModifier}-egsystop'
  location: region
  properties: {
    source: storage.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource egsub 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2021-12-01' = {
  name: '${egtopic.name}/${nameModifier}-egsub'
  properties: {
    destination: {
      endpointType: 'StorageQueue'
      properties: {
        //resourceId: '/subscriptions/8d4251aa-41f1-485c-97e9-460259f227b6/resourceGroups/BoxOfSand/providers/Microsoft.Storage/storageAccounts/cuutestqueue2
        resourceId: '/subscriptions/7929c68b-f2f7-483c-a1c4-196873a31c6c/resourceGroups/CUU-Permanent/providers/Microsoft.Storage/storageAccounts/cuutestqueue'
        queueName: 'test'
      }
    }
  }
}
