param nameModifier string
param region string = resourceGroup().location
param repoUrl string
param repoBranch string

resource functionstorage 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: '${nameModifier}stg'
  location: region
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
  kind: 'StorageV2'
}

resource asp 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${nameModifier}-asp'
  location: region
  kind: 'linux'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: '${nameModifier}-app'
  location: region
  kind: 'functionapp,linux'
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionstorage.name};AccountKey=${functionstorage.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }  
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionstorage.name};AccountKey=${functionstorage.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }                      
      ]
      linuxFxVersion: 'Python|3.9'
    }
    serverFarmId: asp.id
    httpsOnly: true
  }

  resource sc 'sourcecontrols' = {

    name: 'web'
    properties: {
      repoUrl: repoUrl
      branch: repoBranch
      isManualIntegration: false
      deploymentRollbackEnabled: false
      isMercurial: false
      isGitHubAction: true
      gitHubActionConfiguration: {
        generateWorkflowFile: true
        workflowSettings: {
          appType: 'functionapp'
          publishType: 'code'
          os: 'linux'
          runtimeStack: 'python'
          workflowApiVersion: '2020-12-01'
          slotName: 'production'
          variables: {
            runtimeVersion: '3.9'
          }
        }
      }
    }
  }
}
