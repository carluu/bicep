var namePrefix = 'cuu'
var addrSpace = '10.20.0.0'

resource networkVnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
    name: '${namePrefix}-rhvnet'
    location: resourceGroup().location
    properties: {
        addressSpace: {
            addressPrefixes: [
                '${addrSpace}/16'
            ]
        }
        subnets: [
            {
                name: '${namePrefix}-fwsubnet'
                properties: {
                    addressPrefix: addrSpace
                }
            }
    ]
    }
    

}