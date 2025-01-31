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
param existingVnetName = '#{existingVnetName}#'
param subnet1Name = '#{subnet1Name}#'
param subnet2Name = '#{subnet2Name}#'
param myIpAddress = '#{AdminIpAddress}#'
param principalId = '#{AdminPrincipalId}#'
param deployAIHub = #{deployAIHub}#

// param existingVnetName = ''
// param subnet1Name = ''
// param subnet2Name = ''
// param existing_ACR_Name = 'crxxxxxxx'
// param existing_ACR_ResourceGroupName = ''
// param existing_LogAnalytics_Name = 'logxxxxxx'
// param existing_AppInsights_Name = 'appixxxxxx'
// param existing_managedAppEnv_Name = 'xxx-cae-dev'
// param existing_CogServices_Name = ''
// param existing_CogServices_RG_Name = ''
