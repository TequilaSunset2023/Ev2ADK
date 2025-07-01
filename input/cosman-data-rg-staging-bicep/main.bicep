@secure()
param vulnerabilityAssessments_Default_storageContainerPath string
param servers_bigdataefficiency_shared_name string = 'bigdataefficiency-shared'
param Clusters_bigdataefficiencystage_name string = 'bigdataefficiencystage'
param storageAccounts_streamviewerstaging_name string = 'streamviewerstaging'
param networkSecurityPerimeters_nsp_cosman_staging_name string = 'nsp-cosman-staging'
param userAssignedIdentities_MI_IOE_staging_name string = 'MI-IOE-staging'
param Clusters_resourcemanagement_externalid string = '/subscriptions/c0636422-8158-45fd-98fd-fa8010bdde8a/resourceGroups/Prod/providers/Microsoft.Kusto/Clusters/resourcemanagement'

resource Clusters_bigdataefficiencystage_name_resource 'Microsoft.Kusto/Clusters@2024-04-13' = {
  name: Clusters_bigdataefficiencystage_name
  location: 'West US 2'
  tags: {
    'NRMS.KustoPlatform.Classification.1P': 'Corp'
  }
  sku: {
    name: 'Standard_L8as_v3'
    tier: 'Standard'
    capacity: 2
  }
  zones: [
    '1'
    '3'
    '2'
  ]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    trustedExternalTenants: []
    optimizedAutoscale: {
      version: 1
      isEnabled: false
      minimum: 2
      maximum: 3
    }
    enableDiskEncryption: false
    enableStreamingIngest: false
    languageExtensions: {
      value: [
        {
          languageExtensionName: 'PYTHON'
          languageExtensionImageName: 'Python3_11_7'
        }
      ]
    }
    enablePurge: true
    enableDoubleEncryption: false
    engineType: 'V3'
    acceptedAudiences: []
    restrictOutboundNetworkAccess: 'Disabled'
    allowedFqdnList: []
    publicNetworkAccess: 'Enabled'
    allowedIpRangeList: []
    enableAutoStop: true
    publicIPType: 'IPv4'
  }
}

resource userAssignedIdentities_MI_IOE_staging_name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: userAssignedIdentities_MI_IOE_staging_name
  location: 'westus2'
}

resource networkSecurityPerimeters_nsp_cosman_staging_name_resource 'Microsoft.Network/networkSecurityPerimeters@2024-06-01-preview' = {
  name: networkSecurityPerimeters_nsp_cosman_staging_name
  location: 'westus2'
  properties: {}
}

resource servers_bigdataefficiency_shared_name_resource 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: servers_bigdataefficiency_shared_name
  location: 'westus2'
  tags: {
    'NRMS.NetIsoLevel': 'Level2'
  }
  kind: 'v12.0'
  properties: {
    administratorLogin: 'SuperAdmin'
    version: '12.0'
    minimalTlsVersion: 'None'
    publicNetworkAccess: 'Enabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: 'CosmanDBA-Reader'
      sid: 'fdb1f382-eaf0-4b5b-abf7-787930e90dab'
      tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
      azureADOnlyAuthentication: true
    }
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource storageAccounts_streamviewerstaging_name_resource 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccounts_streamviewerstaging_name
  location: 'westus2'
  tags: {
    Owner: 'cosmandev'
  }
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    largeFileSharesState: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource Clusters_bigdataefficiencystage_name_rm_Shared 'Microsoft.Kusto/Clusters/AttachedDatabaseConfigurations@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'rm-Shared'
  location: 'West US 2'
  properties: {
    clusterResourceId: Clusters_resourcemanagement_externalid
    databaseName: 'share'
    defaultPrincipalsModificationKind: 'Union'
    tableLevelSharingProperties: {
      tablesToInclude: [
        'ScopeRecurringJobSuggestions'
        'ScopeJobRecommendations'
      ]
      tablesToExclude: []
      externalTablesToInclude: []
      externalTablesToExclude: [
        '*'
      ]
      materializedViewsToInclude: []
      materializedViewsToExclude: [
        '*'
      ]
      functionsToInclude: []
      functionsToExclude: []
    }
    databaseNameOverride: 'rm-shared'
  }
}

resource Clusters_bigdataefficiencystage_name_dev 'Microsoft.Kusto/Clusters/Databases@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'dev'
  location: 'West US 2'
  kind: 'ReadWrite'
}

resource Clusters_bigdataefficiencystage_name_dev_shared 'Microsoft.Kusto/Clusters/Databases@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'dev-shared'
  location: 'West US 2'
  kind: 'ReadWrite'
}

resource Clusters_bigdataefficiencystage_name_ODLSchemas 'Microsoft.Kusto/Clusters/Databases@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'ODLSchemas'
  location: 'West US 2'
  kind: 'ReadWrite'
}

resource Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared 'Microsoft.Kusto/Clusters/Databases@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'rm-shared'
  location: 'West US 2'
  kind: 'ReadOnlyFollowing'
}

resource Clusters_bigdataefficiencystage_name_staging 'Microsoft.Kusto/Clusters/Databases@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'staging'
  location: 'West US 2'
  kind: 'ReadWrite'
}

resource Clusters_bigdataefficiencystage_name_staging_shared 'Microsoft.Kusto/Clusters/Databases@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'staging-shared'
  location: 'West US 2'
  kind: 'ReadWrite'
}

resource Clusters_bigdataefficiencystage_name_0567f5dd_c3f0_40cb_ac36_b6f8fc79e0e5 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: '0567f5dd-c3f0-40cb-ac36-b6f8fc79e0e5'
  properties: {
    principalId: '730253c3-e114-4eee-ac4e-6d35428dae0f'
    role: 'AllDatabasesViewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_219d1fd6_b3cb_4ac0_973e_c07c515d8628 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: '219d1fd6-b3cb-4ac0-973e-c07c515d8628'
  properties: {
    principalId: '0eedee66-120a-40c7-b650-89623a3c600f'
    role: 'AllDatabasesViewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_4e98e327_38b4_48c2_a49c_7a372549836d 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: '4e98e327-38b4-48c2-a49c-7a372549836d'
  properties: {
    principalId: 'a3b7a5e1-0e5d-4a43-870c-15c2290388a4'
    role: 'AllDatabasesAdmin'
    principalType: 'Group'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_5fd983ff_6592_462d_b70a_57ae6fb0eb3d 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: '5fd983ff-6592-462d-b70a-57ae6fb0eb3d'
  properties: {
    principalId: 'adacc596-a3b8-494a-a55e-bf0f9a80978a'
    role: 'AllDatabasesMonitor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_8dcba762_c57d_491f_ac56_0456a8bc0fba 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: '8dcba762-c57d-491f-ac56-0456a8bc0fba'
  properties: {
    principalId: 'd602b941-d532-4ac4-846b-25be8c5f3f09'
    role: 'AllDatabasesAdmin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_9a402b40_83d5_482d_9fdb_a640d3407a84 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: '9a402b40-83d5-482d-9fdb-a640d3407a84'
  properties: {
    principalId: '6bd4b0e6-2fd3-4a55-8bf7-a93d0bcd17d4'
    role: 'AllDatabasesAdmin'
    principalType: 'Group'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_a0780df6_6557_439b_ae7e_b66f17c289d5 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'a0780df6-6557-439b-ae7e-b66f17c289d5'
  properties: {
    principalId: 'a3b7a5e1-0e5d-4a43-870c-15c2290388a4'
    role: 'AllDatabasesViewer'
    principalType: 'Group'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_c62e0727_7223_48a8_8223_d092146e85c4 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'c62e0727-7223-48a8-8223-d092146e85c4'
  properties: {
    principalId: '730253c3-e114-4eee-ac4e-6d35428dae0f'
    role: 'AllDatabasesAdmin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_c8cbac1f_297c_4423_9fd2_c1e55b0c32b0 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'c8cbac1f-297c-4423-9fd2-c1e55b0c32b0'
  properties: {
    principalId: '71d5afd6-37e2-46bf-8309-f4ba2fc67d70'
    role: 'AllDatabasesViewer'
    principalType: 'Group'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_d92aba3c_f969_40f3_9797_d58021e8586c 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'd92aba3c-f969-40f3-9797-d58021e8586c'
  properties: {
    principalId: 'e31aaa9a-c0ad-42c5-861f-4d433d9859d5'
    role: 'AllDatabasesAdmin'
    principalType: 'User'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_DataMap_Agent_001 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'DataMap Agent 001'
  properties: {
    principalId: 'da3419cc-2455-4136-a912-2a566e6bf74a'
    role: 'AllDatabasesViewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_eea7461d_f18d_4113_8b71_46d5c4f09566 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'eea7461d-f18d-4113-8b71-46d5c4f09566'
  properties: {
    principalId: '6d82c7d1-3616-4dfc-8e0e-5a2ee3f505a4'
    role: 'AllDatabasesViewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_f5d6f288_3157_449c_a989_b809cda118c9 'Microsoft.Kusto/Clusters/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'f5d6f288-3157-449c-a989-b809cda118c9'
  properties: {
    principalId: '24a067bd-67b8-47d3-9b2f-6e022c8beb22'
    role: 'AllDatabasesAdmin'
    principalType: 'User'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource Clusters_bigdataefficiencystage_name_exportkustotoparquet_AzureDataExplorer480_81d720c5_8129_47f2_9e51_9455578c84c3 'Microsoft.Kusto/Clusters/privateEndpointConnections@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_resource
  name: 'exportkustotoparquet.AzureDataExplorer480-81d720c5-8129-47f2-9e51-9455578c84c3'
  properties: {
    privateLinkServiceConnectionState: {
      status: 'Rejected'
      description: 'Requested by DataFactory:ExportKustoToParquet, Name:AzureDataExplorer480'
    }
  }
}

resource networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile 'Microsoft.Network/networkSecurityPerimeters/profiles@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_staging_name_resource
  name: 'defaultProfile'
  location: 'westus2'
  properties: {}
}

resource servers_bigdataefficiency_shared_name_ActiveDirectory 'Microsoft.Sql/servers/administrators@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: 'CosmanDBA-Reader'
    sid: 'fdb1f382-eaf0-4b5b-abf7-787930e90dab'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
}

resource servers_bigdataefficiency_shared_name_Default 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource servers_bigdataefficiency_shared_name_CreateIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'CreateIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_bigdataefficiency_shared_name_DbParameterization 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'DbParameterization'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_bigdataefficiency_shared_name_DefragmentIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'DefragmentIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_bigdataefficiency_shared_name_DropIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'DropIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_bigdataefficiency_shared_name_ForceLastGoodPlan 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'ForceLastGoodPlan'
  properties: {
    autoExecuteValue: 'Enabled'
  }
}

resource Microsoft_Sql_servers_auditingPolicies_servers_bigdataefficiency_shared_name_Default 'Microsoft.Sql/servers/auditingPolicies@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Default'
  location: 'West US 2'
  properties: {
    auditingState: 'Disabled'
  }
}

resource Microsoft_Sql_servers_auditingSettings_servers_bigdataefficiency_shared_name_Default 'Microsoft.Sql/servers/auditingSettings@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'default'
  properties: {
    retentionDays: 0
    auditActionsAndGroups: []
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource Microsoft_Sql_servers_azureADOnlyAuthentications_servers_bigdataefficiency_shared_name_Default 'Microsoft.Sql/servers/azureADOnlyAuthentications@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Default'
  properties: {
    azureADOnlyAuthentication: true
  }
}

resource Microsoft_Sql_servers_connectionPolicies_servers_bigdataefficiency_shared_name_default 'Microsoft.Sql/servers/connectionPolicies@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'default'
  location: 'westus2'
  properties: {
    connectionType: 'Default'
  }
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_dev 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'bigdataefficiency-dev'
  location: 'westus2'
  sku: {
    name: 'GP_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 32
  }
  kind: 'v12.0,user,vcore'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2199023255552
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    licenseType: 'LicenseIncluded'
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Geo'
    maintenanceConfigurationId: '/subscriptions/595c82ed-d6b5-44fb-827a-5a55fe86dd4e/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
    isLedgerOn: false
    availabilityZone: 'NoPreference'
  }
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_staging 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'bigdataefficiency-staging'
  location: 'westus2'
  tags: {
    Owner: 'cosmandev'
  }
  sku: {
    name: 'GP_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 80
  }
  kind: 'v12.0,user,vcore'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 4398046511104
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    licenseType: 'LicenseIncluded'
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Geo'
    maintenanceConfigurationId: '/subscriptions/595c82ed-d6b5-44fb-827a-5a55fe86dd4e/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
    isLedgerOn: false
    availabilityZone: 'NoPreference'
  }
}

resource servers_bigdataefficiency_shared_name_master_Default 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2024-05-01-preview' = {
  name: '${servers_bigdataefficiency_shared_name}/master/Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingPolicies_servers_bigdataefficiency_shared_name_master_Default 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  name: '${servers_bigdataefficiency_shared_name}/master/Default'
  location: 'West US 2'
  properties: {
    auditingState: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingSettings_servers_bigdataefficiency_shared_name_master_Default 'Microsoft.Sql/servers/databases/auditingSettings@2024-05-01-preview' = {
  name: '${servers_bigdataefficiency_shared_name}/master/Default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_extendedAuditingSettings_servers_bigdataefficiency_shared_name_master_Default 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2024-05-01-preview' = {
  name: '${servers_bigdataefficiency_shared_name}/master/Default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_bigdataefficiency_shared_name_master_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2024-05-01-preview' = {
  name: '${servers_bigdataefficiency_shared_name}/master/Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_master_Current 'Microsoft.Sql/servers/databases/ledgerDigestUploads@2024-05-01-preview' = {
  name: '${servers_bigdataefficiency_shared_name}/master/Current'
  properties: {}
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_securityAlertPolicies_servers_bigdataefficiency_shared_name_master_Default 'Microsoft.Sql/servers/databases/securityAlertPolicies@2024-05-01-preview' = {
  name: '${servers_bigdataefficiency_shared_name}/master/Default'
  properties: {
    state: 'Disabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_transparentDataEncryption_servers_bigdataefficiency_shared_name_master_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2024-05-01-preview' = {
  name: '${servers_bigdataefficiency_shared_name}/master/Current'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_vulnerabilityAssessments_servers_bigdataefficiency_shared_name_master_Default 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2024-05-01-preview' = {
  name: '${servers_bigdataefficiency_shared_name}/master/Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_devOpsAuditingSettings_servers_bigdataefficiency_shared_name_Default 'Microsoft.Sql/servers/devOpsAuditingSettings@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Default'
  properties: {
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource servers_bigdataefficiency_shared_name_current 'Microsoft.Sql/servers/encryptionProtector@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'current'
  kind: 'servicemanaged'
  properties: {
    serverKeyName: 'ServiceManaged'
    serverKeyType: 'ServiceManaged'
    autoRotationEnabled: false
  }
}

resource Microsoft_Sql_servers_extendedAuditingSettings_servers_bigdataefficiency_shared_name_Default 'Microsoft.Sql/servers/extendedAuditingSettings@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'default'
  properties: {
    retentionDays: 0
    auditActionsAndGroups: []
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource servers_bigdataefficiency_shared_name_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource servers_bigdataefficiency_shared_name_Corpnet_1 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Corpnet_1'
  properties: {
    startIpAddress: '167.220.0.0'
    endIpAddress: '167.220.255.255'
  }
}

resource servers_bigdataefficiency_shared_name_Corpnet_2 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Corpnet_2'
  properties: {
    startIpAddress: '131.107.0.0'
    endIpAddress: '131.107.255.255'
  }
}

resource servers_bigdataefficiency_shared_name_Corpnet_3 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Corpnet_3'
  properties: {
    startIpAddress: '67.160.205.0'
    endIpAddress: '67.160.205.255'
  }
}

resource servers_bigdataefficiency_shared_name_Corpnet_4 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Corpnet_4'
  properties: {
    startIpAddress: '115.96.0.0'
    endIpAddress: '115.96.255.255'
  }
}

resource servers_bigdataefficiency_shared_name_Corpnet_5 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Corpnet_5'
  properties: {
    startIpAddress: '20.247.0.0'
    endIpAddress: '20.247.255.255'
  }
}

resource servers_bigdataefficiency_shared_name_query_editor_129af7 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'query-editor-129af7'
  properties: {
    startIpAddress: '157.58.216.96'
    endIpAddress: '157.58.216.96'
  }
}

resource servers_bigdataefficiency_shared_name_query_editor_8443d9 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'query-editor-8443d9'
  properties: {
    startIpAddress: '157.58.216.99'
    endIpAddress: '157.58.216.99'
  }
}

resource servers_bigdataefficiency_shared_name_query_editor_da29c9 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'query-editor-da29c9'
  properties: {
    startIpAddress: '157.58.216.97'
    endIpAddress: '157.58.216.97'
  }
}

resource servers_bigdataefficiency_shared_name_query_editor_f15da4 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'query-editor-f15da4'
  properties: {
    startIpAddress: '157.58.216.98'
    endIpAddress: '157.58.216.98'
  }
}

resource Microsoft_Sql_servers_securityAlertPolicies_servers_bigdataefficiency_shared_name_Default 'Microsoft.Sql/servers/securityAlertPolicies@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
}

resource Microsoft_Sql_servers_sqlVulnerabilityAssessments_servers_bigdataefficiency_shared_name_Default 'Microsoft.Sql/servers/sqlVulnerabilityAssessments@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
}

resource Microsoft_Sql_servers_vulnerabilityAssessments_servers_bigdataefficiency_shared_name_Default 'Microsoft.Sql/servers/vulnerabilityAssessments@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_resource
  name: 'Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
    storageContainerPath: vulnerabilityAssessments_Default_storageContainerPath
  }
}

resource storageAccounts_streamviewerstaging_name_default 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
  parent: storageAccounts_streamviewerstaging_name_resource
  name: 'default'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_streamviewerstaging_name_default 'Microsoft.Storage/storageAccounts/fileServices@2024-01-01' = {
  parent: storageAccounts_streamviewerstaging_name_resource
  name: 'default'
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_streamviewerstaging_name_default 'Microsoft.Storage/storageAccounts/queueServices@2024-01-01' = {
  parent: storageAccounts_streamviewerstaging_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_streamviewerstaging_name_default 'Microsoft.Storage/storageAccounts/tableServices@2024-01-01' = {
  parent: storageAccounts_streamviewerstaging_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Clusters_bigdataefficiencystage_name_staging_00010355_2cc8_47ec_b43a_839e69ce8ed4 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '00010355-2cc8-47ec-b43a-839e69ce8ed4'
  properties: {
    principalId: '1f3b18c3-d879-4c2f-b317-0ac7d9a01c10'
    role: 'Monitor'
    principalType: 'App'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_02e5be07_54be_4488_8a06_77a67ed202ec 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '02e5be07-54be-4488-8a06-77a67ed202ec'
  properties: {
    principalId: '70c65d54-38c1-4dd3-88de-9b8a47e0fbb9'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_033b4bf3_be9e_4a28_83ed_0e0c52de18e8 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '033b4bf3-be9e-4a28-83ed-0e0c52de18e8'
  properties: {
    principalId: '7b9a63d8-1948-492e-8b19-00e35ec5893e'
    role: 'Viewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_035e04bc_1e26_450e_8101_b72138392560 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: '035e04bc-1e26-450e-8101-b72138392560'
  properties: {
    principalId: 'f3a3640a-fe9f-4b8d-920e-01750d094477'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_04b22957_a5d1_43aa_b33f_89547fe93d8f 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '04b22957-a5d1-43aa-b33f-89547fe93d8f'
  properties: {
    principalId: '449e2283-8b64-483e-b458-938df165407c'
    role: 'Admin'
    principalType: 'App'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_07192a97_988c_45f5_8624_76a626d05d10 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '07192a97-988c-45f5-8624-76a626d05d10'
  properties: {
    principalId: 'c1b72368-c933-4012-8305-36e78b13468c'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_071c1ee8_ab92_45a5_91cd_8e2794c14333 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '071c1ee8-ab92-45a5-91cd-8e2794c14333'
  properties: {
    principalId: 'd602b941-d532-4ac4-846b-25be8c5f3f09'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_09291f16_9b03_4995_9204_1938cafa168a 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: '09291f16-9b03-4995-9204-1938cafa168a'
  properties: {
    principalId: '993ddd69-4ad1-497e-8b6d-f9abca1353c0'
    role: 'User'
    principalType: 'Group'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_09467b1f_5404_4628_8afe_6a5d254bae04 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '09467b1f-5404-4628-8afe-6a5d254bae04'
  properties: {
    principalId: '4f1321cd-b9ea-473e-b9cd-b7ed18a1dcf6'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_0a518350_9394_45bc_9c91_babc6e6e3590 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '0a518350-9394-45bc-9c91-babc6e6e3590'
  properties: {
    principalId: '626a874c-f759-4966-84b9-98de317a2cb6'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_159e1cd0_3570_413a_8d27_97aeb562bc0a 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '159e1cd0-3570-413a-8d27-97aeb562bc0a'
  properties: {
    principalId: '70c65d54-38c1-4dd3-88de-9b8a47e0fbb9'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_15ae089d_9a0e_4f96_a140_22abd0b74c77 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '15ae089d-9a0e-4f96-a140-22abd0b74c77'
  properties: {
    principalId: '164dccc7-b0ca-4470-96aa-fe9e922556af'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_17565eee_ffdd_48dd_938e_c7693e2ee4bf 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '17565eee-ffdd-48dd-938e-c7693e2ee4bf'
  properties: {
    principalId: '70c65d54-38c1-4dd3-88de-9b8a47e0fbb9'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_17c8686f_3017_48d9_ad2b_e7874d1d2f6b 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '17c8686f-3017-48d9-ad2b-e7874d1d2f6b'
  properties: {
    principalId: 'd602b941-d532-4ac4-846b-25be8c5f3f09'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_19362f95_50cc_458d_b3b3_66e2e348bea0 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '19362f95-50cc-458d-b3b3-66e2e348bea0'
  properties: {
    principalId: '63514a68-95f1-48c2-a39b-3cbed639e847'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_1de304f0_dc2f_412a_94d6_6b304193de55 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '1de304f0-dc2f-412a-94d6-6b304193de55'
  properties: {
    principalId: '626a874c-f759-4966-84b9-98de317a2cb6'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_201ed37f_8c25_4c4c_b337_6d2e606db8a6 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '201ed37f-8c25-4c4c-b337-6d2e606db8a6'
  properties: {
    principalId: 'a3b7a5e1-0e5d-4a43-870c-15c2290388a4'
    role: 'Admin'
    principalType: 'Group'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_211ab6b9_50de_440d_af9e_62092fbff913 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '211ab6b9-50de-440d-af9e-62092fbff913'
  properties: {
    principalId: '49961a9f-d4bf-4cd6-be25-6610e02434d3'
    role: 'Viewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_23155171_9126_42a3_95dd_9899b6ecc822 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '23155171-9126-42a3-95dd-9899b6ecc822'
  properties: {
    principalId: 'cb96f63f-1833-48c1-87a8-d41d7806a5df'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_2b5c12ce_754c_4d07_8bff_4f18efe03b15 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '2b5c12ce-754c-4d07-8bff-4f18efe03b15'
  properties: {
    principalId: 'e5197294-0efc-4c0f-ae3d-b04a0a5d9975'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_2bd8425d_92b9_4c03_8c9b_b1e0ae48feda 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '2bd8425d-92b9-4c03-8c9b-b1e0ae48feda'
  properties: {
    principalId: '6c797385-845b-466e-835d-3ea4e8adc428'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_2c07d798_d42a_41ea_86d8_47a6c60cc012 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '2c07d798-d42a-41ea-86d8-47a6c60cc012'
  properties: {
    principalId: '70c65d54-38c1-4dd3-88de-9b8a47e0fbb9'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_2d08ca5a_1fb5_4fba_9d05_7c1ca4f1c49d 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '2d08ca5a-1fb5-4fba-9d05-7c1ca4f1c49d'
  properties: {
    principalId: 'e5197294-0efc-4c0f-ae3d-b04a0a5d9975'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_2d45082a_5cf5_4eca_8dca_1499c5b63819 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '2d45082a-5cf5-4eca-8dca-1499c5b63819'
  properties: {
    principalId: '626a874c-f759-4966-84b9-98de317a2cb6'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_2d8fa9bf_85f0_41ff_981e_1175a840933f 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '2d8fa9bf-85f0-41ff-981e-1175a840933f'
  properties: {
    principalId: '34c7bc5c-ddf8-4a00-afc0-ebe97575212a'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_2e32d4a8_2fbe_4591_ab38_0bb5c5de250a 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '2e32d4a8-2fbe-4591-ab38-0bb5c5de250a'
  properties: {
    principalId: '164dccc7-b0ca-4470-96aa-fe9e922556af'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_2f7e601c_86e5_47ba_a507_0c0d8eb2471c 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '2f7e601c-86e5-47ba-a507-0c0d8eb2471c'
  properties: {
    principalId: 'c1b72368-c933-4012-8305-36e78b13468c'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_317809ed_ef7a_4260_91ec_6caa5f7d4ec8 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '317809ed-ef7a-4260-91ec-6caa5f7d4ec8'
  properties: {
    principalId: 'c1b72368-c933-4012-8305-36e78b13468c'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_34fa511a_82f7_4d75_9d3e_e33915cc5c35 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '34fa511a-82f7-4d75-9d3e-e33915cc5c35'
  properties: {
    principalId: '70c65d54-38c1-4dd3-88de-9b8a47e0fbb9'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_3624279b_1912_40e8_94fd_39ff252c4891 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: '3624279b-1912-40e8-94fd-39ff252c4891'
  properties: {
    principalId: 'e087c9bd-428b-4100-9fae-beda63a1e1b1'
    role: 'Viewer'
    principalType: 'App'
    tenantId: '975f013f-7f24-47e8-a7d3-abc4752bf346'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_39b9fa7f_8035_4610_b75f_bd9275845d6f 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: '39b9fa7f-8035-4610-b75f-bd9275845d6f'
  properties: {
    principalId: '1f3b18c3-d879-4c2f-b317-0ac7d9a01c10'
    role: 'Monitor'
    principalType: 'App'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_3c228e67_05f3_4358_9136_60dc0ec467bc 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '3c228e67-05f3-4358-9136-60dc0ec467bc'
  properties: {
    principalId: 'f40d16cb-16ff-48e1-9e4d-6394a0ff011b'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_3d7de18b_eb24_4b13_8b6f_d6eb290192df 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '3d7de18b-eb24-4b13-8b6f-d6eb290192df'
  properties: {
    principalId: 'c1b72368-c933-4012-8305-36e78b13468c'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_3e14378d_c4f3_4804_b2be_e8fb9c2978e7 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '3e14378d-c4f3-4804-b2be-e8fb9c2978e7'
  properties: {
    principalId: 'e5197294-0efc-4c0f-ae3d-b04a0a5d9975'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_3fd836c1_406b_49b3_9afa_1bfcb30fa4e2 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: '3fd836c1-406b-49b3-9afa-1bfcb30fa4e2'
  properties: {
    principalId: 'cb96f63f-1833-48c1-87a8-d41d7806a5df'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_40ca0a78_5a1e_4b9e_b434_3ff2b079abd6 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '40ca0a78-5a1e-4b9e-b434-3ff2b079abd6'
  properties: {
    principalId: '730253c3-e114-4eee-ac4e-6d35428dae0f'
    role: 'Viewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_42a95da5_f613_4b1e_80d0_6a8366e9da86 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '42a95da5-f613-4b1e-80d0-6a8366e9da86'
  properties: {
    principalId: 'c1b72368-c933-4012-8305-36e78b13468c'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_42bcecf1_f488_447f_89f6_664999192af5 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '42bcecf1-f488-447f-89f6-664999192af5'
  properties: {
    principalId: 'e5197294-0efc-4c0f-ae3d-b04a0a5d9975'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_4a796c8a_d6c9_4142_a292_18215f0f13d8 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: '4a796c8a-d6c9-4142-a292-18215f0f13d8'
  properties: {
    principalId: 'cb96f63f-1833-48c1-87a8-d41d7806a5df'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_4bb40219_511d_4051_a1c3_08856e417174 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '4bb40219-511d-4051-a1c3-08856e417174'
  properties: {
    principalId: '34c7bc5c-ddf8-4a00-afc0-ebe97575212a'
    role: 'Viewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_4cc1f06d_a7df_49b3_9c40_4821d689364c 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '4cc1f06d-a7df-49b3-9c40-4821d689364c'
  properties: {
    principalId: '34c7bc5c-ddf8-4a00-afc0-ebe97575212a'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_4fd41326_e0c0_4b61_a35b_797596c7336b 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '4fd41326-e0c0-4b61-a35b-797596c7336b'
  properties: {
    principalId: '66c21b55-2d35-4a5c-a2a8-63f8a9b0fc53'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_5041b354_7467_4da0_8020_b99d022dd1c3 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '5041b354-7467-4da0-8020-b99d022dd1c3'
  properties: {
    principalId: '449e2283-8b64-483e-b458-938df165407c'
    role: 'Admin'
    principalType: 'App'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_506d77a2_ae0a_4147_8316_5d6948a8c1c5 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '506d77a2-ae0a-4147-8316-5d6948a8c1c5'
  properties: {
    principalId: 'c1b72368-c933-4012-8305-36e78b13468c'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_5114e177_cdd5_464c_9205_f7ff9da624d8 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '5114e177-cdd5-464c-9205-f7ff9da624d8'
  properties: {
    principalId: '9c544fed-b86e-4d60-827f-0324c5cd4dde'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_53bf6d71_5f43_4933_9bb4_78535f3fbd04 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '53bf6d71-5f43-4933-9bb4-78535f3fbd04'
  properties: {
    principalId: '730253c3-e114-4eee-ac4e-6d35428dae0f'
    role: 'Viewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_5a8e0a1d_a6cf_4edd_8e33_35e23112b2b5 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '5a8e0a1d-a6cf-4edd-8e33-35e23112b2b5'
  properties: {
    principalId: '626a874c-f759-4966-84b9-98de317a2cb6'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_5be2bf44_19a8_4389_bcd2_5ef812164740 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '5be2bf44-19a8-4389-bcd2-5ef812164740'
  properties: {
    principalId: 'd602b941-d532-4ac4-846b-25be8c5f3f09'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_5da9f04b_3e67_48c4_ad7a_472127f04895 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '5da9f04b-3e67-48c4-ad7a-472127f04895'
  properties: {
    principalId: 'cb96f63f-1833-48c1-87a8-d41d7806a5df'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_5ec50594_c74d_41db_a50d_08088824fdb0 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '5ec50594-c74d-41db-a50d-08088824fdb0'
  properties: {
    principalId: '63514a68-95f1-48c2-a39b-3cbed639e847'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_6518e602_ebde_4d39_aba1_8ea520b381a3 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '6518e602-ebde-4d39-aba1-8ea520b381a3'
  properties: {
    principalId: '6c797385-845b-466e-835d-3ea4e8adc428'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_663f7def_5bdc_4bd2_8aa1_7f0d4298fc6a 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '663f7def-5bdc-4bd2-8aa1-7f0d4298fc6a'
  properties: {
    principalId: 'a3b7a5e1-0e5d-4a43-870c-15c2290388a4'
    role: 'Admin'
    principalType: 'Group'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_66d25330_5c3d_44ea_8a7a_3466ea965fd8 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '66d25330-5c3d-44ea-8a7a-3466ea965fd8'
  properties: {
    principalId: 'cb96f63f-1833-48c1-87a8-d41d7806a5df'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_671d4ff3_b996_4b6a_8401_14ce572870a2 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '671d4ff3-b996-4b6a-8401-14ce572870a2'
  properties: {
    principalId: '626a874c-f759-4966-84b9-98de317a2cb6'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_6ad72fdb_1254_4d0c_ab9f_d22db904b534 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '6ad72fdb-1254-4d0c-ab9f-d22db904b534'
  properties: {
    principalId: '626a874c-f759-4966-84b9-98de317a2cb6'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_6b3bcee6_8581_468c_8de3_9779440b7f69 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '6b3bcee6-8581-468c-8de3-9779440b7f69'
  properties: {
    principalId: 'f2325d08-d168-4a20-87c2-87a547ee0a09'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_6c0c67d0_c455_4e8a_b685_0f66afd59d8a 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '6c0c67d0-c455-4e8a-b685-0f66afd59d8a'
  properties: {
    principalId: '0f830cea-7057-4b09-9d4b-790a05490487'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_ODLSchemas_7370ef2e_1e5d_4060_b66b_76b276848833 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_ODLSchemas
  name: '7370ef2e-1e5d-4060-b66b-76b276848833'
  properties: {
    principalId: '4f2286b0-39e0-4305-81bd-c0ef7a826eae'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_763c47e3_21f9_47c9_a5a0_690dbea99e76 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '763c47e3-21f9-47c9-a5a0-690dbea99e76'
  properties: {
    principalId: '164dccc7-b0ca-4470-96aa-fe9e922556af'
    role: 'Admin'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_ODLSchemas_77d91c59_f2a8_4f8a_a2d0_c331636b117c 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_ODLSchemas
  name: '77d91c59-f2a8-4f8a-a2d0-c331636b117c'
  properties: {
    principalId: '8b211fa6-b1f3-45e2-8be3-1170a79a409f'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_7900dbee_44ef_4f36_bcf8_c05109da2831 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '7900dbee-44ef-4f36-bcf8-c05109da2831'
  properties: {
    principalId: 'cfeead70-bbcd-42b0-9e47-c20511f8bcc0'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_79f08e9c_0f45_4f0b_aa37_977943610cd7 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '79f08e9c-0f45-4f0b-aa37-977943610cd7'
  properties: {
    principalId: '66c21b55-2d35-4a5c-a2a8-63f8a9b0fc53'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_7b5eac8b_fce0_4c8c_8b25_4f4e9a3df3af 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '7b5eac8b-fce0-4c8c-8b25-4f4e9a3df3af'
  properties: {
    principalId: '449e2283-8b64-483e-b458-938df165407c'
    role: 'Admin'
    principalType: 'App'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_7e04c076_e288_459b_90af_0909ad44a356 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '7e04c076-e288-459b-90af-0909ad44a356'
  properties: {
    principalId: '626a874c-f759-4966-84b9-98de317a2cb6'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_7e877529_4e9d_4d24_a372_9d09f65d11ba 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: '7e877529-4e9d-4d24-a372-9d09f65d11ba'
  properties: {
    principalId: '626a874c-f759-4966-84b9-98de317a2cb6'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_8284266f_d6b8_4a03_8e4c_706c9bc4b38c 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '8284266f-d6b8-4a03-8e4c-706c9bc4b38c'
  properties: {
    principalId: '6d82c7d1-3616-4dfc-8e0e-5a2ee3f505a4'
    role: 'Viewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_83dc9474_3f79_474a_b41e_9d84393b32dc 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '83dc9474-3f79-474a-b41e-9d84393b32dc'
  properties: {
    principalId: '66c21b55-2d35-4a5c-a2a8-63f8a9b0fc53'
    role: 'Viewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_8943eca9_ed3e_450c_b2e8_9dc6570c9197 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '8943eca9-ed3e-450c-b2e8-9dc6570c9197'
  properties: {
    principalId: '449e2283-8b64-483e-b458-938df165407c'
    role: 'Admin'
    principalType: 'App'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_8a9b5696_d9a1_404e_b5ec_e25dcd8bd5ac 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '8a9b5696-d9a1-404e-b5ec-e25dcd8bd5ac'
  properties: {
    principalId: 'cfeead70-bbcd-42b0-9e47-c20511f8bcc0'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_8b2ec8c7_c67c_4e23_baaa_55d4e1a5a7be 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '8b2ec8c7-c67c-4e23-baaa-55d4e1a5a7be'
  properties: {
    principalId: '164dccc7-b0ca-4470-96aa-fe9e922556af'
    role: 'Admin'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_8d9565f1_83e4_428d_bc8f_ed12482472a8 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '8d9565f1-83e4-428d-bc8f-ed12482472a8'
  properties: {
    principalId: '63514a68-95f1-48c2-a39b-3cbed639e847'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_8ed784f2_5de0_476f_a43a_90a13536bb7a 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '8ed784f2-5de0-476f-a43a-90a13536bb7a'
  properties: {
    principalId: '1f3b18c3-d879-4c2f-b317-0ac7d9a01c10'
    role: 'Monitor'
    principalType: 'App'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_90bf7f1f_12fc_4f9c_8a5f_a596a5321ca7 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: '90bf7f1f-12fc-4f9c-8a5f-a596a5321ca7'
  properties: {
    principalId: '70c65d54-38c1-4dd3-88de-9b8a47e0fbb9'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_9258b2f9_4a84_43fc_85d0_bb4efdd0ed03 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '9258b2f9-4a84-43fc-85d0-bb4efdd0ed03'
  properties: {
    principalId: 'c1b72368-c933-4012-8305-36e78b13468c'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_9636d8f0_e1e0_4047_bb0c_7d6569424434 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '9636d8f0-e1e0-4047-bb0c-7d6569424434'
  properties: {
    principalId: 'c1b72368-c933-4012-8305-36e78b13468c'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_9b595787_4a33_46c9_bb51_efcdb48efc2c 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '9b595787-4a33-46c9-bb51-efcdb48efc2c'
  properties: {
    principalId: '70c65d54-38c1-4dd3-88de-9b8a47e0fbb9'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_9ba632e2_5f00_41c4_8be1_90dd4409deca 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: '9ba632e2-5f00-41c4-8be1-90dd4409deca'
  properties: {
    principalId: 'xiruiwei@microsoft.com'
    role: 'Admin'
    principalType: 'User'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_9f9a860c_5819_48ff_8759_9b1b049e8f57 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: '9f9a860c-5819-48ff-8759-9b1b049e8f57'
  properties: {
    principalId: 'cb96f63f-1833-48c1-87a8-d41d7806a5df'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_9fa67ca5_b80c_4b6e_b445_13b7a123b65f 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: '9fa67ca5-b80c-4b6e-b445-13b7a123b65f'
  properties: {
    principalId: 'f8e72140-aea5-4eec-a862-b392ae574d3d'
    role: 'Admin'
    principalType: 'User'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_a2655f5d_41da_4406_845c_bdee2cf02da9 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: 'a2655f5d-41da-4406-845c-bdee2cf02da9'
  properties: {
    principalId: '164dccc7-b0ca-4470-96aa-fe9e922556af'
    role: 'Admin'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_a9fd329c_e811_43db_9d76_0cb47b2cbde6 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: 'a9fd329c-e811-43db-9d76-0cb47b2cbde6'
  properties: {
    principalId: '164dccc7-b0ca-4470-96aa-fe9e922556af'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_aaa40bb5_ce5e_406a_89ca_e660845f2e95 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'aaa40bb5-ce5e-406a-89ca-e660845f2e95'
  properties: {
    principalId: '63514a68-95f1-48c2-a39b-3cbed639e847'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_b4de18a0_9ab2_4c7d_8b11_214908ae4d83 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: 'b4de18a0-9ab2-4c7d-8b11-214908ae4d83'
  properties: {
    principalId: '75d66c2d-cc9b-4186-8c2d-0ff26b02f1fd'
    role: 'User'
    principalType: 'Group'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_b4e3f54b_39d8_4663_a607_9756c7cef66c 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: 'b4e3f54b-39d8-4663-a607-9756c7cef66c'
  properties: {
    principalId: '9c544fed-b86e-4d60-827f-0324c5cd4dde'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_b5a66a0e_8e03_41bb_aa75_7125f5488780 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: 'b5a66a0e-8e03-41bb-aa75-7125f5488780'
  properties: {
    principalId: '164dccc7-b0ca-4470-96aa-fe9e922556af'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_b68afedc_e18a_45ed_abeb_e73070b199bd 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: 'b68afedc-e18a-45ed-abeb-e73070b199bd'
  properties: {
    principalId: 'f40d16cb-16ff-48e1-9e4d-6394a0ff011b'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_b8cf0292_6074_4f67_9511_027c7dd923fa 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: 'b8cf0292-6074-4f67-9511-027c7dd923fa'
  properties: {
    principalId: 'c1b72368-c933-4012-8305-36e78b13468c'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_bd60f8f7_85d8_463c_894d_661d27c32bca 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'bd60f8f7-85d8-463c-894d-661d27c32bca'
  properties: {
    principalId: 'e5197294-0efc-4c0f-ae3d-b04a0a5d9975'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_be0bb84d_ec99_4b5c_9ac5_d074a531699e 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: 'be0bb84d-ec99-4b5c-9ac5-d074a531699e'
  properties: {
    principalId: 'cb96f63f-1833-48c1-87a8-d41d7806a5df'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_bf35b061_d345_42bd_8bb6_04c5244bfd2c 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'bf35b061-d345-42bd-8bb6-04c5244bfd2c'
  properties: {
    principalId: '34c7bc5c-ddf8-4a00-afc0-ebe97575212a'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_c3543788_92f9_48a8_b19b_5de2fa33dbf4 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: 'c3543788-92f9-48a8-b19b-5de2fa33dbf4'
  properties: {
    principalId: '164dccc7-b0ca-4470-96aa-fe9e922556af'
    role: 'Admin'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_c4f33653_f102_4b99_82df_4a49f2de1189 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: 'c4f33653-f102-4b99-82df-4a49f2de1189'
  properties: {
    principalId: 'a3b7a5e1-0e5d-4a43-870c-15c2290388a4'
    role: 'Admin'
    principalType: 'Group'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_c7d1c071_93ca_4ebb_ae77_71088fef7176 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: 'c7d1c071-93ca-4ebb-ae77-71088fef7176'
  properties: {
    principalId: '66c21b55-2d35-4a5c-a2a8-63f8a9b0fc53'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_c840ca2c_e9d3_4281_8759_69499e4434d6 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: 'c840ca2c-e9d3-4281-8759-69499e4434d6'
  properties: {
    principalId: 'cb96f63f-1833-48c1-87a8-d41d7806a5df'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_c89fd39c_a461_4ba4_9717_31ac4d25e298 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: 'c89fd39c-a461-4ba4-9717-31ac4d25e298'
  properties: {
    principalId: '34c7bc5c-ddf8-4a00-afc0-ebe97575212a'
    role: 'Viewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_c90ec760_4b80_4891_83e5_e5976264646d 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: 'c90ec760-4b80-4891-83e5-e5976264646d'
  properties: {
    principalId: 'c8026bd9-2872-4399-aaa2-ca9ca037d837'
    role: 'Viewer'
    principalType: 'App'
    tenantId: '975f013f-7f24-47e8-a7d3-abc4752bf346'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_c9928d1a_6a84_4b25_9baf_2a5e12785628 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: 'c9928d1a-6a84-4b25-9baf-2a5e12785628'
  properties: {
    principalId: 'e5197294-0efc-4c0f-ae3d-b04a0a5d9975'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_ODLSchemas_c9b18716_84f7_43ba_b61f_725df18c11ab 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_ODLSchemas
  name: 'c9b18716-84f7-43ba-b61f-725df18c11ab'
  properties: {
    principalId: 'baonguyen_jit@prdtrs01.prod.outlook.com'
    role: 'Admin'
    principalType: 'User'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_cd189666_625e_4612_bd60_9c45631b4dca 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: 'cd189666-625e-4612-bd60-9c45631b4dca'
  properties: {
    principalId: '33db8b7e-c3e7-4e18-a739-816ec2cb7f87'
    role: 'Monitor'
    principalType: 'App'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_cdaae426_e7aa_453a_af7d_b46af57ad3c9 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: 'cdaae426-e7aa-453a-af7d-b46af57ad3c9'
  properties: {
    principalId: 'cb96f63f-1833-48c1-87a8-d41d7806a5df'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_ce16cb85_0517_4f95_a429_1f049d225fde 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'ce16cb85-0517-4f95-a429-1f049d225fde'
  properties: {
    principalId: 'f2325d08-d168-4a20-87c2-87a547ee0a09'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_d18bac68_90dd_48b5_a887_923b7c705278 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: 'd18bac68-90dd-48b5-a887-923b7c705278'
  properties: {
    principalId: 'e5197294-0efc-4c0f-ae3d-b04a0a5d9975'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_d1954923_0620_4f64_8f83_3e076818edf4 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: 'd1954923-0620-4f64-8f83-3e076818edf4'
  properties: {
    principalId: '6d82c7d1-3616-4dfc-8e0e-5a2ee3f505a4'
    role: 'Viewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_d1b2c848_ad60_4c69_a078_181af2bca1a7 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: 'd1b2c848-ad60-4c69-a078-181af2bca1a7'
  properties: {
    principalId: '164dccc7-b0ca-4470-96aa-fe9e922556af'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_d68bcc91_c028_4e01_bddb_f0e5c6a63d39 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'd68bcc91-c028-4e01-bddb-f0e5c6a63d39'
  properties: {
    principalId: 'cb96f63f-1833-48c1-87a8-d41d7806a5df'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_d7ba00c7_bdd6_428b_9665_98a8c39616bb 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: 'd7ba00c7-bdd6-428b-9665-98a8c39616bb'
  properties: {
    principalId: '0f830cea-7057-4b09-9d4b-790a05490487'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_d8d45add_a4ab_41a9_b82d_adfcf3df4b65 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: 'd8d45add-a4ab-41a9-b82d-adfcf3df4b65'
  properties: {
    principalId: '66c21b55-2d35-4a5c-a2a8-63f8a9b0fc53'
    role: 'Viewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_d9c2d060_94d1_4507_8f80_20574c206da6 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: 'd9c2d060-94d1-4507-8f80-20574c206da6'
  properties: {
    principalId: ';cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_db99bfb7_0df5_48b3_8943_95f6c11e3ee1 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'db99bfb7-0df5-48b3-8943-95f6c11e3ee1'
  properties: {
    principalId: 'e5197294-0efc-4c0f-ae3d-b04a0a5d9975'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_dc5514bb_6881_4f57_981d_50531ec29e93 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'dc5514bb-6881-4f57-981d-50531ec29e93'
  properties: {
    principalId: '60cc5859-3342-43ae-867b-7b7397afa975'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_shared_dd18867a_080d_4c41_89d5_10b4f1f8f173 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev_shared
  name: 'dd18867a-080d-4c41-89d5-10b4f1f8f173'
  properties: {
    principalId: '70c65d54-38c1-4dd3-88de-9b8a47e0fbb9'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_deb2f267_6c19_4aeb_8006_c203c2fa18e8 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging
  name: 'deb2f267-6c19-4aeb-8006-c203c2fa18e8'
  properties: {
    principalId: 'a3b7a5e1-0e5d-4a43-870c-15c2290388a4'
    role: 'Admin'
    principalType: 'Group'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_df02d9c5_86ae_4354_a537_c2db2d1fc09f 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: 'df02d9c5-86ae-4354-a537-c2db2d1fc09f'
  properties: {
    principalId: '66c21b55-2d35-4a5c-a2a8-63f8a9b0fc53'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_e2116981_e815_40d7_924c_ca0339bc42eb 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: 'e2116981-e815-40d7-924c-ca0339bc42eb'
  properties: {
    principalId: 'de3681c1-eb95-4290-ac60-2f439a1c2c8b'
    role: 'Monitor'
    principalType: 'App'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_e67c632a_8229_4c6d_94c3_48df64163033 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'e67c632a-8229-4c6d-94c3-48df64163033'
  properties: {
    principalId: 'c1b72368-c933-4012-8305-36e78b13468c'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_ef08268d_93a8_474f_aa74_0466c8bd748f 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'ef08268d-93a8-474f-aa74-0466c8bd748f'
  properties: {
    principalId: 'f40d16cb-16ff-48e1-9e4d-6394a0ff011b'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_ef651868_43d7_45ea_8e6f_cf4d44cb14a4 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'ef651868-43d7-45ea-8e6f-cf4d44cb14a4'
  properties: {
    principalId: '70c65d54-38c1-4dd3-88de-9b8a47e0fbb9'
    role: 'User'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_staging_shared_efda5555_3ea5_442e_90ad_6520724ed1c1 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_staging_shared
  name: 'efda5555-3ea5-442e-90ad-6520724ed1c1'
  properties: {
    principalId: '626a874c-f759-4966-84b9-98de317a2cb6'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_f93ae2bc_9091_4dc5_99c2_ec0a8d234fcd 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'f93ae2bc-9091-4dc5-99c2-ec0a8d234fcd'
  properties: {
    principalId: '70c65d54-38c1-4dd3-88de-9b8a47e0fbb9'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_f9ab8606_dd76_40f7_9857_d5146b49bdd7 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'f9ab8606-dd76-40f7-9857-d5146b49bdd7'
  properties: {
    principalId: '34c7bc5c-ddf8-4a00-afc0-ebe97575212a'
    role: 'Ingestor'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_dev_fbf7e27d_f077_48fa_8772_850a6e7cc29f 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Clusters_bigdataefficiencystage_name_dev
  name: 'fbf7e27d-f077-48fa-8772-850a6e7cc29f'
  properties: {
    principalId: '626a874c-f759-4966-84b9-98de317a2cb6'
    role: 'Admin'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_feea602e_1ccd_4855_8eca_fa646ffe4ad4 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: 'feea602e-1ccd-4855-8eca-fa646ffe4ad4'
  properties: {
    principalId: 'b57df2d9-17fc-4679-8d35-6b2eb0c3c0d7'
    role: 'Viewer'
    principalType: 'App'
    tenantId: 'cdc5aeea-15c5-4db6-b079-fcadd2505dc2'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource Clusters_bigdataefficiencystage_name_rm_shared_ff759ffa_f368_446f_9a9c_b8d5d216c050 'Microsoft.Kusto/Clusters/Databases/PrincipalAssignments@2024-04-13' = {
  parent: Microsoft_Kusto_Clusters_Databases_Clusters_bigdataefficiencystage_name_rm_shared
  name: 'ff759ffa-f368-446f-9a9c-b8d5d216c050'
  properties: {
    principalId: '63514a68-95f1-48c2-a39b-3cbed639e847'
    role: 'Viewer'
    principalType: 'Group'
    tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
  }
  dependsOn: [
    Clusters_bigdataefficiencystage_name_resource
  ]
}

resource networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile_allow_access_from_subscription 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile
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
    networkSecurityPerimeters_nsp_cosman_staging_name_resource
  ]
}

resource networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile_allow_corpnet_1 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile
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
    networkSecurityPerimeters_nsp_cosman_staging_name_resource
  ]
}

resource networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile_allow_corpnet_2 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile
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
    networkSecurityPerimeters_nsp_cosman_staging_name_resource
  ]
}

resource networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile_allow_corpnet_3 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile
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
    networkSecurityPerimeters_nsp_cosman_staging_name_resource
  ]
}

resource networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile_allow_corpnet_4 'Microsoft.Network/networkSecurityPerimeters/profiles/accessRules@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile
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
    networkSecurityPerimeters_nsp_cosman_staging_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_dev_Default 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_staging_Default 'Microsoft.Sql/servers/databases/advancedThreatProtectionSettings@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_dev_CreateIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'CreateIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_staging_CreateIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'CreateIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_dev_DbParameterization 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'DbParameterization'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_staging_DbParameterization 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'DbParameterization'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_dev_DefragmentIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'DefragmentIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_staging_DefragmentIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'DefragmentIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_dev_DropIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'DropIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_staging_DropIndex 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'DropIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_dev_ForceLastGoodPlan 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'ForceLastGoodPlan'
  properties: {
    autoExecuteValue: 'Enabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_staging_ForceLastGoodPlan 'Microsoft.Sql/servers/databases/advisors@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'ForceLastGoodPlan'
  properties: {
    autoExecuteValue: 'Enabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingPolicies_servers_bigdataefficiency_shared_name_bigdataefficiency_dev_Default 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'Default'
  location: 'West US 2'
  properties: {
    auditingState: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingPolicies_servers_bigdataefficiency_shared_name_bigdataefficiency_staging_Default 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'Default'
  location: 'West US 2'
  properties: {
    auditingState: 'Disabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingSettings_servers_bigdataefficiency_shared_name_bigdataefficiency_dev_Default 'Microsoft.Sql/servers/databases/auditingSettings@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingSettings_servers_bigdataefficiency_shared_name_bigdataefficiency_staging_Default 'Microsoft.Sql/servers/databases/auditingSettings@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'default'
  properties: {
    retentionDays: 0
    auditActionsAndGroups: []
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_backupLongTermRetentionPolicies_servers_bigdataefficiency_shared_name_bigdataefficiency_dev_default 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'default'
  properties: {
    weeklyRetention: 'PT0S'
    monthlyRetention: 'PT0S'
    yearlyRetention: 'PT0S'
    weekOfYear: 0
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_backupLongTermRetentionPolicies_servers_bigdataefficiency_shared_name_bigdataefficiency_staging_default 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'default'
  properties: {
    weeklyRetention: 'PT0S'
    monthlyRetention: 'PT0S'
    yearlyRetention: 'PT0S'
    weekOfYear: 0
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_backupShortTermRetentionPolicies_servers_bigdataefficiency_shared_name_bigdataefficiency_dev_default 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'default'
  properties: {
    retentionDays: 7
    diffBackupIntervalInHours: 12
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_backupShortTermRetentionPolicies_servers_bigdataefficiency_shared_name_bigdataefficiency_staging_default 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'default'
  properties: {
    retentionDays: 7
    diffBackupIntervalInHours: 12
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_extendedAuditingSettings_servers_bigdataefficiency_shared_name_bigdataefficiency_dev_Default 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'default'
  properties: {
    retentionDays: 0
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_extendedAuditingSettings_servers_bigdataefficiency_shared_name_bigdataefficiency_staging_Default 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'default'
  properties: {
    retentionDays: 0
    auditActionsAndGroups: []
    isStorageSecondaryKeyInUse: false
    isAzureMonitorTargetEnabled: false
    isManagedIdentityInUse: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_bigdataefficiency_shared_name_bigdataefficiency_dev_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_bigdataefficiency_shared_name_bigdataefficiency_staging_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_dev_Current 'Microsoft.Sql/servers/databases/ledgerDigestUploads@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'Current'
  properties: {}
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource servers_bigdataefficiency_shared_name_bigdataefficiency_staging_Current 'Microsoft.Sql/servers/databases/ledgerDigestUploads@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'Current'
  properties: {}
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_securityAlertPolicies_servers_bigdataefficiency_shared_name_bigdataefficiency_dev_Default 'Microsoft.Sql/servers/databases/securityAlertPolicies@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'Default'
  properties: {
    state: 'Disabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_securityAlertPolicies_servers_bigdataefficiency_shared_name_bigdataefficiency_staging_Default 'Microsoft.Sql/servers/databases/securityAlertPolicies@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'Default'
  properties: {
    state: 'Disabled'
    disabledAlerts: [
      ''
    ]
    emailAddresses: [
      ''
    ]
    emailAccountAdmins: false
    retentionDays: 0
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_transparentDataEncryption_servers_bigdataefficiency_shared_name_bigdataefficiency_dev_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'Current'
  properties: {
    state: 'Enabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_transparentDataEncryption_servers_bigdataefficiency_shared_name_bigdataefficiency_staging_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'Current'
  properties: {
    state: 'Enabled'
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_vulnerabilityAssessments_servers_bigdataefficiency_shared_name_bigdataefficiency_dev_Default 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_dev
  name: 'Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_vulnerabilityAssessments_servers_bigdataefficiency_shared_name_bigdataefficiency_staging_Default 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2024-05-01-preview' = {
  parent: servers_bigdataefficiency_shared_name_bigdataefficiency_staging
  name: 'Default'
  properties: {
    recurringScans: {
      isEnabled: false
      emailSubscriptionAdmins: true
    }
  }
  dependsOn: [
    servers_bigdataefficiency_shared_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_azure_webjobs_hosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: storageAccounts_streamviewerstaging_name_default
  name: 'azure-webjobs-hosts'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_azure_webjobs_secrets 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: storageAccounts_streamviewerstaging_name_default
  name: 'azure-webjobs-secrets'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_streamcleanupschedulerstaging_applease 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: storageAccounts_streamviewerstaging_name_default
  name: 'streamcleanupschedulerstaging-applease'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_streamcleanupschedulerstaging_largemessages 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: storageAccounts_streamviewerstaging_name_default
  name: 'streamcleanupschedulerstaging-largemessages'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_streamcleanupschedulerstaging_leases 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: storageAccounts_streamviewerstaging_name_default
  name: 'streamcleanupschedulerstaging-leases'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_streamcleanupschedulerstaging_control_00 'Microsoft.Storage/storageAccounts/queueServices/queues@2024-01-01' = {
  parent: Microsoft_Storage_storageAccounts_queueServices_storageAccounts_streamviewerstaging_name_default
  name: 'streamcleanupschedulerstaging-control-00'
  properties: {
    metadata: {}
  }
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_streamcleanupschedulerstaging_control_01 'Microsoft.Storage/storageAccounts/queueServices/queues@2024-01-01' = {
  parent: Microsoft_Storage_storageAccounts_queueServices_storageAccounts_streamviewerstaging_name_default
  name: 'streamcleanupschedulerstaging-control-01'
  properties: {
    metadata: {}
  }
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_streamcleanupschedulerstaging_control_02 'Microsoft.Storage/storageAccounts/queueServices/queues@2024-01-01' = {
  parent: Microsoft_Storage_storageAccounts_queueServices_storageAccounts_streamviewerstaging_name_default
  name: 'streamcleanupschedulerstaging-control-02'
  properties: {
    metadata: {}
  }
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_streamcleanupschedulerstaging_control_03 'Microsoft.Storage/storageAccounts/queueServices/queues@2024-01-01' = {
  parent: Microsoft_Storage_storageAccounts_queueServices_storageAccounts_streamviewerstaging_name_default
  name: 'streamcleanupschedulerstaging-control-03'
  properties: {
    metadata: {}
  }
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_streamcleanupschedulerstaging_workitems 'Microsoft.Storage/storageAccounts/queueServices/queues@2024-01-01' = {
  parent: Microsoft_Storage_storageAccounts_queueServices_storageAccounts_streamviewerstaging_name_default
  name: 'streamcleanupschedulerstaging-workitems'
  properties: {
    metadata: {}
  }
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_StreamCleanupSchedulerstagingHistory 'Microsoft.Storage/storageAccounts/tableServices/tables@2024-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_streamviewerstaging_name_default
  name: 'StreamCleanupSchedulerstagingHistory'
  properties: {}
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource storageAccounts_streamviewerstaging_name_default_StreamCleanupSchedulerstagingInstances 'Microsoft.Storage/storageAccounts/tableServices/tables@2024-01-01' = {
  parent: Microsoft_Storage_storageAccounts_tableServices_storageAccounts_streamviewerstaging_name_default
  name: 'StreamCleanupSchedulerstagingInstances'
  properties: {}
  dependsOn: [
    storageAccounts_streamviewerstaging_name_resource
  ]
}

resource networkSecurityPerimeters_nsp_cosman_staging_name_bigdataefficiency_shared_4f410a19_cd10_41de_9786_554a172b16f0 'Microsoft.Network/networkSecurityPerimeters/resourceAssociations@2024-06-01-preview' = {
  parent: networkSecurityPerimeters_nsp_cosman_staging_name_resource
  name: 'bigdataefficiency-shared-4f410a19-cd10-41de-9786-554a172b16f0'
  properties: {
    privateLinkResource: {
      id: servers_bigdataefficiency_shared_name_resource.id
    }
    profile: {
      id: networkSecurityPerimeters_nsp_cosman_staging_name_defaultProfile.id
    }
    accessMode: 'Learning'
  }
}
