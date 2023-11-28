
param vnetName string
param location string
param addressPrefix string[]
param subnetPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefix
    }
    subnets: [
      {
        name: 'subnet1'
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}
