// --------------------------------------------------------------------------------------------------------------
// The most minimal parameters you need - everything else is defaulted
// --------------------------------------------------------------------------------------------------------------
using 'find-ai-hub-id.bicep'

param applicationName = '#{APP_NAME}#'
param location = '#{RESOURCEGROUP_LOCATION}#'
param environmentName = '#{envCode}#'
param appendResourceTokens = false
