// --------------------------------------------------------------------------------------------------------------
// The most minimal parameters you need - everything else is defaulted
// --------------------------------------------------------------------------------------------------------------
using 'main.bicep'

param applicationName = '#{appNameLower}#'                   // from the variable group
param location = '#{location}#'                              // from the var_common file
param openAI_deploy_location = '#{openAI_deploy_location}#'  // from the var_common file
param environmentName = '#{environmentNameLower}#'           // from the pipeline inputs
param appendResourceTokens = false
param addRoleAssignments = #{addRoleAssignments}#
param createDnsZones = #{createDnsZones}#
param publicAccessEnabled = #{publicAccessEnabled}#
param myIpAddress = '#{AdminIpAddress}#'
param principalId = '#{AdminPrincipalId}#'
param deployAIHub = #{deployAIHub}#
param deployBatchApp = #{deployBatchApp}#

// param existingVnetName = '#{appNameLowerNoDashes}#-vnet-dev'
// param existingVnetResourceGroupName = '#{resourceGroupPrefix}#-#{environmentNameLower}#'
// param vnetPrefix = '10.2.0.0/16'
// param subnet1Name = 'snet-prv-endpoint'
// param subnet1Prefix = '10.2.0.64/26'
// param subnet2Name = 'snet-app'
// param subnet2Prefix = '10.2.2.0/23'

// param existing_ACR_Name = '#{appNameLowerNoDashes}#cr#{environmentNameLower}#'
// param existing_ACR_ResourceGroupName = '#{resourceGroupPrefix}#-#{environmentNameLower}#'

// param existing_CogServices_Name = '#{appNameLowerNoDashes}#-cog-#{environmentNameLower}#'
// param existing_CogServices_ResourceGroupName = '#{resourceGroupPrefix}#-#{environmentNameLower}#'

// param existing_SearchService_Name = '#{appNameLowerNoDashes}#-srch-#{environmentNameLower}#'
// param existing_SearchService_ResourceGroupName = '#{resourceGroupPrefix}#-#{environmentNameLower}#'

// param existing_Cosmos_Name = '#{appNameLowerNoDashes}#-cosmos-#{environmentNameLower}#'
// param existing_Cosmos_ResourceGroupName = '#{resourceGroupPrefix}#-#{environmentNameLower}#'

// param existing_KeyVault_Name = '#{appNameLowerNoDashes}#kv#{environmentNameLower}#'
// param existing_KeyVault_ResourceGroupName = '#{resourceGroupPrefix}#-#{environmentNameLower}#'

// param existing_LogAnalytics_Name = '#{appNameLowerNoDashes}#-log-#{environmentNameLower}#'
// param existing_AppInsights_Name = '#{appNameLowerNoDashes}#-appi-#{environmentNameLower}#'

// param existing_managedAppEnv_Name = '#{appNameLowerNoDashes}#-cae-#{environmentNameLower}#'
