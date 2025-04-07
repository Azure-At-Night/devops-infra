targetScope = 'subscription'

var varResourceGroupName = 'rg-atn-devops-tfstate-001'
var varTags = {
  WorkloadName: 'Terraform State File Storage'
  Criticality: 'high'
  Env: 'Prod'
  Control: 'Bicep'
}
var varStorageAccounts = [
  {
    name: 'statndevopsstate001'
    location: 'centralus'
    skuName: 'Standard_RAGRS'
    tags: varTags
    containers: [
      {
        name: 'atn-devops-runners'
        publicAccess: 'None'
      }
      {
        name: 'atn-identities'
        publicAccess: 'None'
      }
    ]
    roleAssignments: [
      {
        principalId: '41fa029f-be49-48bd-beee-4732c5880743'
        principalType: 'User'
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      }
    ]
  }
]
 
module modTfStateRg 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'modTfStateRg'
  params: {
    name: varResourceGroupName
    location: deployment().location
    tags: varTags
  }
}
 
module modTfStateSt 'br/public:avm/res/storage/storage-account:0.18.1' = [for st in varStorageAccounts: {
  scope: resourceGroup(varResourceGroupName)
  name: 'mod${st.name}'
  dependsOn: [
    modTfStateRg
  ]
  params: {
    name: st.name
    location: st.location
    skuName: st.skuName
    tags: varTags
    allowSharedKeyAccess: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          action: 'Allow'
          value: '213.29.219.194'
        }
      ]
      virtualNetworkRules: [
      ]
    }
    allowBlobPublicAccess: false
    blobServices: {
      automaticSnapshotPolicyEnabled: true
      deleteRetentionPolicyDays: 100
      deleteRetentionPolicyEnabled: true
      containerDeleteRetentionPolicyDays: 60
      containerDeleteRetentionPolicyEnabled: true
      isVersioningEnabled: true
      lastAccessTimeTrackingPolicyEnabled: false
      containers: [for container in st.containers: {
          name: container.name
          publicAccess: 'None'
        }
      ]
    }
    roleAssignments: [for ra in st.roleAssignments: {
      principalId: ra.principalId
      principalType: ra.principalType
      roleDefinitionIdOrName: ra.roleDefinitionIdOrName
    }
  ]
  }
}]
