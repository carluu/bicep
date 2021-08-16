var nameModifier = 'cuubc'
var webappOS = 'Windows'
var stack = 'java'
var phpVersion = 'OFF'
var javaVersion = '11'
var javaContainer = 'TOMCAT'
var javaContainerVersion = '9.0' 

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: '${nameModifier}-vnet'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/8'
      ]
    }
  }
}

resource asesubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${vnet.name}/${nameModifier}asesubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
}

resource appgwsubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  name: '${vnet.name}/${nameModifier}appgwsubnet'
  properties: {
    addressPrefix: '10.0.1.0/24'
  }
  dependsOn: [
    asesubnet
  ]
}

module ase '../../modules/AppService/windowsase.bicep' = {
  name: 'windowsase'
  params: {
    nameModifier: nameModifier
    subnetId: asesubnet.id
  }
}

resource webapp 'Microsoft.Web/sites@2021-01-15' = {
  name: '${nameModifier}-webapp'
  location: resourceGroup().location
  properties: {
    serverFarmId: ase.outputs.aspId
    siteConfig: {
      alwaysOn: true
      phpVersion: phpVersion
      javaVersion: javaVersion
      javaContainer: javaContainer
      javaContainerVersion: javaContainerVersion
    }
    clientAffinityEnabled: true
    hostingEnvironmentProfile: ase.outputs.aseProfile
  }
}

module appgw '../../modules/AppGateway/appgateway-params.bicep' = {
  name: 'appgw'
  params: {
    nameModifier: nameModifier
    subnetId: appgwsubnet.id
    port: 80
    size: 'Standard_Small'
    tier: 'Standard'
    backendFqdn: webapp.properties.defaultHostName
  }
}
