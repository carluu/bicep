param nameModifier string = 'cuubc'
param subnetId string = ''
param vmpass string
param scriptsrcport int = 1433
param scriptdestport int = 1433
param scriptip string = '10.10.10.10'
param pubip bool = true
param region string = resourceGroup().location

var scripturl = 'https://raw.githubusercontent.com/carluu/bicep/main/modules/PrivateLinkForwarder/privatelink_fwder_vm_script.sh'


module testVnet '../Utility/basicvnet.bicep' = if(subnetId == ''){
  name: 'testvnet'
  params: {
    nameModifier: nameModifier
    region: region
  }
}

resource publicip 'Microsoft.Network/publicIPAddresses@2021-02-01' = if(pubip) {
  name: '${nameModifier}pubip'
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
  name: '${nameModifier}nic'
  location: region
  properties: {
    enableAcceleratedNetworking: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${subnetId == '' ? testVnet.outputs.subnetId : subnetId}'
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
  name: '${nameModifier}vm'
  location: region
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    osProfile: {
      adminUsername: 'cuuadmin'
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
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
  }
  resource fwderscript 'extensions' = {
    name: '${nameModifier}fwderscript'
    location: region
    properties: {
      publisher: 'Microsoft.Azure.Extensions'
      type: 'CustomScript'
      typeHandlerVersion: '2.0'
      autoUpgradeMinorVersion: true
      protectedSettings: {
        commandToExecute: 'curl -o ./custom-script.sh --remote-name --location ${scripturl} && chmod +x ./custom-script.sh && ./custom-script.sh -i eth0 -f ${scriptsrcport} -a ${scriptip} -b ${scriptdestport}'
      }
    }
  }
}

output vmprivip string = fwdernic.properties.ipConfigurations[0].properties.privateIPAddress
