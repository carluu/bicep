param nameModifier string = 'cuubc'
param subnetId string = ''
param vmpass string
param scriptport string = '1433'
param scriptip string = '10.10.10.10'

var scripturl = 'https://raw.githubusercontent.com/carluu/bicep/main/modules/VM/vmfwd-ipt.sh'


module testVnet '../Utility/basicvnet.bicep' = if(subnetId == ''){
  name: 'testvnet'
  params: {
    nameModifier: nameModifier
  }
}

resource fwdernic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${nameModifier}nic'
  location: resourceGroup().location
  properties: {
    enableAcceleratedNetworking: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${subnetId == '' ? testVnet.outputs.subnetId : subnetId}'
          }
        }
      }
    ]
  }
}

resource fwdervm 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: '${nameModifier}vm'
  location: resourceGroup().location
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
    location: resourceGroup().location
    properties: {
      publisher: 'Microsoft.Azure.Extensions'
      type: 'CustomScript'
      typeHandlerVersion: '2.0'
      autoUpgradeMinorVersion: true
      protectedSettings: {
        commandToExecute: 'curl -o ./custom-script.sh --remote-name --location ${scripturl} && chmod +x ./custom-script.sh && ./custom-script.sh -i eth0 -f ${scriptport} -a ${scriptip} -b ${scriptport}'
      }
    }
  }
}
