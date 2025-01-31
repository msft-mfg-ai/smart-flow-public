// --------------------------------------------------------------------------------------------------------------
// Parameter file with many existing resources specified
// --------------------------------------------------------------------------------------------------------------
using 'main.bicep'

param applicationName = '#{appNameLower}#'                   // from the variable group
param location = '#{location}#'                              // from the var_common file

param existingVnetName = 'vnet-core-eastus'
param vnetPrefix = '10.2.0.0/16'
param subnet1Name = 'snet-prv-endpoint'
param subnet1Prefix = '10.2.0.64/26'
param subnet2Name = 'snet-app'
param subnet2Prefix = '10.2.2.0/23'

param existing_ACR_Name = 'crmikjoahmkv7fg'
// param existing_ACR_ResourceGroupName = ''

param existing_LogAnalytics_Name = 'log-Default-eastus'
param existing_AppInsights_Name = 'appi--default-eastus'

param existing_managedAppEnv_Name = 'caeaidocmentrevieweastus'
param appendResourceTokens = false

// param existing_CogServices_Name = ''
// param existing_CogServices_RG_Name = ''

param deployAIHub = #{deployAIHub}#
param addRoleAssignments = #{addRoleAssignments}#
param createDnsZones = #{createDnsZones}#
param publicAccessEnabled = #{publicAccessEnabled}#
