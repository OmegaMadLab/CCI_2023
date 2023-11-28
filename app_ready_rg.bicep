targetScope = 'subscription'

param AppName string
param location string

param contributorGrpId string
param readerGrpId string

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${AppName}-RG'
  location: location
}

module readerRole 'modules/role.bicep' = {
  scope: rg
  name: 'readerRole'
  params: {
    builtInRoleType: 'Reader' 
    principalId: readerGrpId
  }
}

module contributorRole 'modules/role.bicep' = {
  scope: rg
  name: 'contributorRole'
  params: {
    builtInRoleType: 'Contributor' 
    principalId: contributorGrpId
  }
}

module vnet 'modules/vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    vnetName: '${AppName}-VNET'
    location: location
    addressPrefix: ['10.0.0.0/16']
    subnetPrefix: '10.0.0.0/24'
  }
}

module storage 'modules/storage.bicep' = {
  scope: rg
  name: 'storage'
  params: {
    storageAccountPrefix: '${AppName}stg'
    location: location
  }
}
