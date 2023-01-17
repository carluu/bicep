// Use AZ VM Image List for easiest way to get list of core images
param nameModifier string = 'cuubc'
param subnetId string = ''
@secure()
param vmpass string
param pubip bool = true
param vmsize string = 'Standard_B2ms'
param accelNet bool = false
param adminun string = 'cuuadmin'
param region string = resourceGroup().location


module testVnet '../Utility/basicvnet.bicep' = if(subnetId == ''){
  name: 'testvnet'
  params: {
    region: region
    nameModifier: '${nameModifier}win'
  }
}

resource publicip 'Microsoft.Network/publicIPAddresses@2021-02-01' = if(pubip) {
  name: '${nameModifier}winpubip'
  location: region
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource fwdernic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${nameModifier}winnic'
  location: region
  properties: {
    enableAcceleratedNetworking: accelNet
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId == '' ? testVnet.outputs.subnetId : subnetId
          }
          publicIPAddress: pubip ? {
            id: publicip.id
          } : null
        }
      }
    ]
  }
}

resource fwdervm 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: '${nameModifier}winvm'
  location: region
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    osProfile: {
      adminUsername: adminun
      adminPassword: vmpass
      computerName: '${nameModifier}vm'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: fwdernic.id
        }
      ]
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
  }
}

output vmprivip string = fwdernic.properties.ipConfigurations[0].properties.privateIPAddress
