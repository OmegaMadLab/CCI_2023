param storageAccountPrefix string
param location string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: take(toLower('${storageAccountPrefix}${uniqueString(resourceGroup().id)}'), 24)
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
