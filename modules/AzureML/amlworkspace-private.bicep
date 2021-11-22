param nameModifier string = 'cuuaml'
param vnetId string = ''
param subnetId string = ''
param storageId string = ''
param akvId string = ''
param insightsId string = ''
param acrId string = ''

module testVnet '../Utility/basicvnet.bicep' = if(subnetId == ''){
  name: '${nameModifier}-vnet'
  params: {
    nameModifier: nameModifier
    pePolicies: 'Disabled'
  }
}


// Required resources
resource amlStorage 'Microsoft.Storage/storageAccounts@2021-06-01' = if(storageId == ''){
  name: '${nameModifier}stg'
  kind: 'StorageV2'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
  }
}

resource amlAkv 'Microsoft.KeyVault/vaults@2021-06-01-preview' = if(akvId == '') {
  name: '${nameModifier}akv'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableSoftDelete: false
  }
}

resource amlAppInsights 'Microsoft.Insights/components@2020-02-02' = if(insightsId == '') {
  name: '${nameModifier}insights'
  kind: 'web'
  location: resourceGroup().location
  properties: {
    Application_Type: 'web'
  }
}

resource amlAcr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = if(acrId == '') {
  name: '${nameModifier}acr'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}



// Workspace
resource amlWorkspace 'Microsoft.MachineLearningServices/workspaces@2021-07-01' = {
  name: '${nameModifier}amlworkspace'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    friendlyName: '${nameModifier}amlworkspace'
    storageAccount: storageId == '' ? amlStorage.id : storageId
    keyVault: akvId == '' ? amlAkv.id : akvId
    applicationInsights: insightsId == '' ? amlAppInsights.id : insightsId
    containerRegistry: acrId == '' ? amlAcr.id : acrId
    hbiWorkspace: true
    allowPublicAccessWhenBehindVnet: false
    description: ''
    publicNetworkAccess: 'Disabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}


// Private endpoint stuff
resource workspacePe 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: '${nameModifier}workspacepe'
  location: resourceGroup().location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${nameModifier}workspacepesettings'
        properties: {
          groupIds: [
            'amlworkspace'
          ]
          privateLinkServiceId: amlWorkspace.id
        }
      }
    ]
    subnet: {
      id: '${subnetId == '' ? testVnet.outputs.subnetId : subnetId}'
    }
  }
}

resource workspaceDnsApi 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.api.azureml.ms'
  location: 'global'
}

resource wokspaceDnsApiLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privatelink.api.azureml.ms/${vnetId == '' ? uniqueString(resourceId('Microsoft.Network/virtualNetworks',testVnet.name)) : uniqueString(vnetId)}'
  location: 'global'
  dependsOn: [
    workspaceDnsApi
  ]
  properties: {
    virtualNetwork: {
      id: '${vnetId == '' ? testVnet.outputs.vnetId : vnetId}'
    }
    registrationEnabled: false
  }  
}

resource workspaceDnsNb 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.notebooks.azure.net'
  location: 'global'
}

resource workspaceDnsNbLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privatelink.notebooks.azure.net/${vnetId == '' ? uniqueString(resourceId('Microsoft.Network/virtualNetworks',testVnet.name)) : uniqueString(vnetId)}'
  location: 'global'
  dependsOn: [
    workspaceDnsNb
  ]
  properties: {
    virtualNetwork: {
      id: '${vnetId == '' ? testVnet.outputs.vnetId : vnetId}'
    }
    registrationEnabled: false
  }
}

resource workspaceDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-03-01' = {
  name: '${workspacePe.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink_api_azureml_ms'
        properties: {
          privateDnsZoneId: workspaceDnsApi.id
        }
      }
      {
        name: 'privatelink_notebook_azureml_ms'
        properties: {
          privateDnsZoneId: workspaceDnsNb.id
        }
      }
    ]
  }
}


// resource asd 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  
// }
