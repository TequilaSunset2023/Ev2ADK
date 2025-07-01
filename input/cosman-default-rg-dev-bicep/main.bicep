param networkSecurityPerimeters_nsp_cosman_dev_name string = 'nsp-cosman-dev'
param networkManagers_NetManager_test_guorongma_name string = 'NetManager-test-guorongma'
param userAssignedIdentities_MI_CosmanCopilot_Dev_name string = 'MI-CosmanCopilot-Dev'
param userAssignedIdentities_MI_CosmanNonProdARM_dev_name string = 'MI-CosmanNonProdARM-dev'
param userAssignedIdentities_MI_VCAccess_o365vcMgmt_dev_name string = 'MI-VCAccess-o365vcMgmt-dev'
param userAssignedIdentities_MI_AppWithCosmanDatabaseRO_dev_name string = 'MI-AppWithCosmanDatabaseRO-dev'
param userAssignedIdentities_MI_AppWithCosmanDatabaseRW_dev_name string = 'MI-AppWithCosmanDatabaseRW-dev'
param userAssignedIdentities_MI_AccessExternalDatabase_M365SOTELSApp_dev_name string = 'MI-AccessExternalDatabase-M365SOTELSApp-dev'
param userAssignedIdentities_MI_CallingDownstream_M365CosmanStreamViewer_dev_name string = 'MI-CallingDownstream-M365CosmanStreamViewer-dev'
param userAssignedIdentities_MI_CallingDownstream_M365CosmanServiceApplication_dev_name string = 'MI-CallingDownstream-M365CosmanServiceApplication-dev'
param userAssignedIdentities_MI_AccessExternalDatabase_M365CosmanServiceApplication_dev_name string = 'MI-AccessExternalDatabase-M365CosmanServiceApplication-dev'
param servers_bigdataefficiency_feature2_externalid string = '/subscriptions/595c82ed-d6b5-44fb-827a-5a55fe86dd4e/resourceGroups/cosman-data-rg-feature/providers/Microsoft.Sql/servers/bigdataefficiency-feature2'
param vaults_EUDBReplicationKV_externalid string = '/subscriptions/817ea61f-b59e-42d8-887b-7c2aa63bce2f/resourceGroups/EUDBReplication/providers/Microsoft.KeyVault/vaults/EUDBReplicationKV'

resource userAssignedIdentities_MI_AccessExternalDatabase_M365CosmanServiceApplication_dev_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_MI_AccessExternalDatabase_M365CosmanServiceApplication_dev_name
  location: 'westus2'
}

resource userAssignedIdentities_MI_AccessExternalDatabase_M365SOTELSApp_dev_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_MI_AccessExternalDatabase_M365SOTELSApp_dev_name
  location: 'westus2'
}

resource userAssignedIdentities_MI_AppWithCosmanDatabaseRO_dev_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_MI_AppWithCosmanDatabaseRO_dev_name
  location: 'westus2'
}

resource userAssignedIdentities_MI_AppWithCosmanDatabaseRW_dev_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_MI_AppWithCosmanDatabaseRW_dev_name
  location: 'westus2'
}

resource userAssignedIdentities_MI_CallingDownstream_M365CosmanServiceApplication_dev_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_MI_CallingDownstream_M365CosmanServiceApplication_dev_name
  location: 'westus2'
  tags: {
    TargetResourceId: '0f830cea-7057-4b09-9d4b-790a05490487'
  }
}

resource userAssignedIdentities_MI_CallingDownstream_M365CosmanStreamViewer_dev_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_MI_CallingDownstream_M365CosmanStreamViewer_dev_name
  location: 'westus2'
}

resource userAssignedIdentities_MI_CosmanCopilot_Dev_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_MI_CosmanCopilot_Dev_name
  location: 'westus3'
}

resource userAssignedIdentities_MI_CosmanNonProdARM_dev_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_MI_CosmanNonProdARM_dev_name
  location: 'westus2'
}

resource userAssignedIdentities_MI_VCAccess_o365vcMgmt_dev_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_MI_VCAccess_o365vcMgmt_dev_name
  location: 'westus2'
  tags: {
    TargetResourceId: '6b447287-6420-455f-9db2-c6b28831732c'
  }
}

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

resource networkSecurityPerimeters_nsp_cosman_dev_name_resource 'Microsoft.Network/networkSecurityPerimeters@2024-06-01-preview' = {
  name: networkSecurityPerimeters_nsp_cosman_dev_name
  location: 'westus2'
  properties: {}
}

resource userAssignedIdentities_MI_CosmanNonProdARM_dev_name_FIC_CosmanNonProdARM_dev 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2025-01-31-preview' = {
  parent: userAssignedIdentities_MI_CosmanNonProdARM_dev_name_resource
  name: 'FIC-CosmanNonProdARM-dev'
  properties: {
    issuer: 'https://vstoken.dev.azure.com/d1a8f71c-7f64-45ad-9c5c-19c2f469d620'
    subject: 'sc://O365Exchange/O365 Core/CosmanNonProdARM-dev'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}

resource networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile 'Microsoft.Network/networkSecurityPerimeters/profiles@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_dev_name_resource
  name: 'defaultProfile'
  location: 'westus2'
  properties: {}
}

resource networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile_allow_access_from_subscription 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile
  name: 'allow-access-from-subscription'
  properties: {
    direction: 'Inbound'
    addressPrefixes: []
    fullyQualifiedDomainNames: []
    subscriptions: [
      {
        id: '/subscriptions/595c82ed-d6b5-44fb-827a-5a55fe86dd4e'
      }
    ]
    emailAddresses: []
    phoneNumbers: []
  }
  dependsOn: [
    networkSecurityPerimeters_nsp_cosman_dev_name_resource
  ]
}

resource networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile_allow_corpnet_1 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile
  name: 'allow-corpnet-1'
  properties: {
    direction: 'Inbound'
    addressPrefixes: [
      '167.220.0.0/16'
    ]
    fullyQualifiedDomainNames: []
    subscriptions: []
    emailAddresses: []
    phoneNumbers: []
  }
  dependsOn: [
    networkSecurityPerimeters_nsp_cosman_dev_name_resource
  ]
}

resource networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile_allow_corpnet_2 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile
  name: 'allow-corpnet-2'
  properties: {
    direction: 'Inbound'
    addressPrefixes: [
      '131.107.0.0/16'
    ]
    fullyQualifiedDomainNames: []
    subscriptions: []
    emailAddresses: []
    phoneNumbers: []
  }
  dependsOn: [
    networkSecurityPerimeters_nsp_cosman_dev_name_resource
  ]
}

resource networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile_allow_corpnet_3 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile
  name: 'allow-corpnet-3'
  properties: {
    direction: 'Inbound'
    addressPrefixes: [
      '67.160.205.0/24'
    ]
    fullyQualifiedDomainNames: []
    subscriptions: []
    emailAddresses: []
    phoneNumbers: []
  }
  dependsOn: [
    networkSecurityPerimeters_nsp_cosman_dev_name_resource
  ]
}

resource networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile_allow_corpnet_4 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile
  name: 'allow-corpnet-4'
  properties: {
    direction: 'Inbound'
    addressPrefixes: [
      '115.96.0.0/16'
    ]
    fullyQualifiedDomainNames: []
    subscriptions: []
    emailAddresses: []
    phoneNumbers: []
  }
  dependsOn: [
    networkSecurityPerimeters_nsp_cosman_dev_name_resource
  ]
}

resource networkSecurityPerimeters_nsp_cosman_dev_name_bigdataefficiency_feature2_4bad35bb_138b_4cfe_bc50_df996c5287e5 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_dev_name_resource
  name: 'bigdataefficiency-feature2-4bad35bb-138b-4cfe-bc50-df996c5287e5'
  properties: {
    privateLinkResource: {
      id: servers_bigdataefficiency_feature2_externalid
    }
    profile: {
      id: networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile.id
    }
    accessMode: 'Learning'
  }
}

resource networkSecurityPerimeters_nsp_cosman_dev_name_EUDBReplicationKV_97b22620_1c8d_4f1c_ab48_dd1c1801022c 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_dev_name_resource
  name: 'EUDBReplicationKV-97b22620-1c8d-4f1c-ab48-dd1c1801022c'
  properties: {
    privateLinkResource: {
      id: vaults_EUDBReplicationKV_externalid
    }
    profile: {
      id: networkSecurityPerimeters_nsp_cosman_dev_name_defaultProfile.id
    }
    accessMode: 'Learning'
  }
}
