param nameModifier string = 'cuubc'
param region string = resourceGroup().location

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: '${nameModifier}-adf'
  location: region
  properties: {
    repoConfiguration: {
      type: 'FactoryGitHubConfiguration'
      accountName: 'carluu'
      collaborationBranch: 'master'
      hostName: '10.10.10.10'
      repositoryName: 'test'
      rootFolder: 'test'
    }
  }
}
