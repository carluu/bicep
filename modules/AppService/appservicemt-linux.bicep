// Kind values for webapp: https://github.com/Azure/app-service-linux-docs/blob/master/Things_You_Should_Know/kind_property.md
// App Service Plan doesn't respect kind. for ASP:  (if reserved = true, it’s a Linux ASP, otherwise it’s a Windows ASP).

param nameModifier string = 'cuuappserv'
param ibSubnetId string = ''
param obSubnetId string = ''
param vnetInjected bool = true
param vnetRouteAll bool = true
param peEnabled bool = true
param skuTier string = 'PremiumV2'
param skuName string = 'P1v2'
param zoneRedundant bool = false
param linuxFxVersion string = 'TOMCAT|10.0-java17'
param region string = resourceGroup().location


// Make a VNET if either of the network spaces doesn't exist
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = if((vnetInjected && obSubnetId == '') || (peEnabled && ibSubnetId == '')) {
  name: '${nameModifier}-vnet'
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/8'
      ]
    }
  }  
}

resource obSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = if(vnetInjected && obSubnetId == ''){
  name: '${vnet.name}/outbound'
  properties: {
    addressPrefix: '10.0.0.0/24'
    delegations: [
      {
        name: 'appservice'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
      }      
    ]
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource ibSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = if(peEnabled && ibSubnetId == ''){
  name: '${vnet.name}/inbound'
  properties: {
    addressPrefix: '10.0.1.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource privDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if(peEnabled) {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
}

resource asp 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${nameModifier}-asp'
  location: region
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    reserved: true
    zoneRedundant: zoneRedundant 
  }
}

resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: '${nameModifier}-app'
  location: region
  kind: 'app,linux'
  properties: {
    // These two are only set if vnet injection is on
    virtualNetworkSubnetId: vnetInjected ? (obSubnetId == '' ? obSubnet.id : obSubnetId) : null
    vnetRouteAllEnabled: vnetInjected ? vnetRouteAll : null
    httpsOnly: true
    serverFarmId: asp.id
  }

  resource appconfig 'config' = {
    name: 'web'
    properties: {
      linuxFxVersion: linuxFxVersion
    }
  }  
}

resource appPe 'Microsoft.Network/privateEndpoints@2022-01-01' = if(peEnabled) {
  name: '${nameModifier}-pe'
  location: region
  properties: {
    subnet: {
      id: ibSubnetId == '' ? ibSubnet.id : ibSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${nameModifier}-pe'
        properties: {
          groupIds: [
            'sites'
          ]
          privateLinkServiceId: app.id
        }
      }
    ]
  }

  resource dnsGroup 'privateDnsZoneGroups@2022-01-01' = {
    name: 'default'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink.azurewebsites.net-config'
          properties: {
            privateDnsZoneId: privDnsZone.id
          }
        }
      ]
    }
  }

}



 