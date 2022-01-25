param nameModifier string = 'cuubcweb'
param tenantId string
param clientId string

resource asp 'Microsoft.Web/serverfarms@2021-02-01' = {
  location: resourceGroup().location
  name: '${nameModifier}-asp'
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  properties: {
    isSpot: false
    isXenon: false
    hyperV: false
    reserved: false
  }
}

resource app 'Microsoft.Web/sites@2021-02-01' = {
  location: resourceGroup().location
  name: '${nameModifier}-app'
  kind: 'app,linux'
  properties: {
    serverFarmId: asp.id
  }
}

resource config 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${app.name}/authsettingsV2'
  properties: {
    enabled: true
    globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'RedirectToLoginPage'
      redirectToProvider: 'azureactivedirectory'
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          openIdIssuer: 'https://sts.windows.net/${tenantId}/v2.0'
          clientId: clientId
          clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
        }
      }
    }
    login: {
      tokenStore: {
        enabled: true
      }
    }
  }
}
