param sku string = 'Standard_LRS'
var locationUs = 'eastus2'
var locationCan = 'eastus2'
var canadaApproved = true
var namePrefix = 'cuu'

resource testStorage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: '${namePrefix}testbicepstorage'
    location: canadaApproved ? locationCan : locationUs
    kind: 'Storage'
    sku: {
        name: sku
    }
}

output storageId string = testStorage.id
output blobEndpoint string = testStorage.properties.primaryEndpoints.blob