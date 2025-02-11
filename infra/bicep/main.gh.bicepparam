// --------------------------------------------------------------------------------------------------------------
// The most minimal parameters you need - everything else is defaulted
// --------------------------------------------------------------------------------------------------------------
using 'main.bicep'

param applicationName = '#{APP_NAME}#'
param location = '#{RESOURCEGROUP_LOCATION}#'
param openAI_deploy_location = '#{OPENAI_DEPLOY_LOCATION}#'
param environmentName = '#{envCode}#'
param appendResourceTokens = false
param addRoleAssignments = #{addRoleAssignments}#
param createDnsZones = #{createDnsZones}#
param publicAccessEnabled = #{publicAccessEnabled}#
param myIpAddress = '#{ADMIN_IP_ADDRESS}#'
param principalId = '#{ADMIN_PRINCIPAL_ID}#'
param deployAIHub = #{deployAIHub}#
param deployBatchApp = #{deployBatchApp}#

// param existingVnetName = 'vnetxxxxxxx'
// param vnetPrefix = '10.2.0.0/16'
// param subnet1Name = ''
// param subnet1Prefix = '10.2.0.64/26'
// param subnet2Name = ''
// param subnet2Prefix = '10.2.2.0/23'

// param existing_ACR_Name = 'acrxxxxxxx'
// param existing_ACR_ResourceGroupName = 'rg_cogsvcs'

// param existing_SearchService_Name = 'searchxxxxxx'
// param existing_CogServices_Name = 'openaixxxxxx'
// param existing_CogServices_RG_Name = 'rg_cogsvcs'

// param existing_LogAnalytics_Name = 'logxxxxxx'
// param existing_AppInsights_Name = 'appixxxxxx'
// param existing_CosmosAccount_Name = 'cosmosxxxxx'
// param existing_managedAppEnv_Name = 'appenvxxxxxx'
