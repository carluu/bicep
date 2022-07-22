resource rt 'Microsoft.Network/routeTables@2020-11-01' = {
  name: 'e3001-centralus-routetable-aml-1'
  location: resourceGroup().location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'route_0'
        properties: {
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.196.137.164'
          addressPrefix: '0.0.0.0/0'
        }
      }
      {
        name: 'route_1'
        properties: {
          nextHopType: 'Internet'
          nextHopIpAddress: ''
          addressPrefix: 'BatchNodeManagement'
        }
      }  
      {
        name: 'route_2'
        properties: {
          nextHopType: 'Internet'
          nextHopIpAddress: ''
          addressPrefix: 'AzureMachineLearning'
        }
      }            
    ]
  }
}
