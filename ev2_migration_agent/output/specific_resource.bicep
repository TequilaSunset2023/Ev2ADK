param networkManagers_NetManager_test_guorongma_name string = 'NetManager-test-guorongma'

resource networkManagers_NetManager_test_guorongma_name_resource 'Microsoft.Network/networkManagers@2024-05-01' = {
  name: networkManagers_NetManager_test_guorongma_name
  location: 'westus3'
  properties: {
    networkManagerScopes: {
      managementGroups: []
      subscriptions: [
        '/subscriptions/595c82ed-d6b5-44fb-827a-5a55fe86dd4e'
      ]
    }
    networkManagerScopeAccesses: [
      'Connectivity'
      'Routing'
    ]
  }
}
