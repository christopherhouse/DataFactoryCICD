param sourceStorageAccountName string
param destStorageAccountName string
param orderContainerName string
param archiveContainerName string
param keyVaultName string
param dataFactoryName string

var location = resourceGroup().location

resource sourceStorage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: sourceStorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource sourceBlobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  name: 'default'
  parent: sourceStorage
}

resource orderContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: orderContainerName
  parent: sourceBlobService
}
