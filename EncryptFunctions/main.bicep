// az group create --name rg-bcrypt-prod-eastus --location eastus
// az deployment group create --resource-group rg-bcrypt-prod-eastus --template-file main.bicep
// az group delete --name rg-bcrypt-prod-eastus 

@description('Specify de location for all the resources')
param defaultLocation string = resourceGroup().location

@description('Specify de environment')
@allowed([
  'dev'
  'qa'
  'prod'
])
param deployEnvironment string = 'prod'

@description('Specify the type of Storage account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
])
param saType string = 'Standard_LRS'

@description('Specify the language of function app.')
@allowed([
  'node'
  'dotnet'
  'java'
])
param afRuntime string = 'dotnet'


var afName = 'af-bcrypt-${deployEnvironment}-${defaultLocation}'
var saName = 'sabcrypt${deployEnvironment}${defaultLocation}'
var aiName = 'ai-bcrypt-${deployEnvironment}-${defaultLocation}'


resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: aiName
  location: defaultLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: saName
  location: defaultLocation
  sku: {
    name: saType
  }
  kind: 'Storage'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: afName
  location: defaultLocation
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: afName
  location: defaultLocation
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${saName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${saName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(afName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: afRuntime
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
