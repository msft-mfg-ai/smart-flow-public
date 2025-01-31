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

// param existingVnetName = ''
// param subnet1Name = ''
// param subnet2Name = ''
// param existing_ACR_Name = 'crxxxxxxx'
// param existing_ACR_ResourceGroupName = ''
// param existing_LogAnalytics_Name = 'logxxxxxx'
// param existing_AppInsights_Name = 'appixxxxxx'
// param existing_managedAppEnv_Name = 'xxxx-cae-dev'
// param existing_CogServices_Name = ''
// param existing_CogServices_RG_Name = ''
