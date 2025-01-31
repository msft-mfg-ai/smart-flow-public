// -----------------------------------------------------------------------------------------------
// This BICEP file will create a project inside an AI Foundry using a Powershell Script
// -----------------------------------------------------------------------------------------------
param hubId string = ''
param resourceGroupName string = ''
param projectName string = ''
param managedIdentityId string = ''

param location string = resourceGroup().location
param utcValue string = utcNow()

resource createAIHubProject 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'createAIHubProject'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: { '${ managedIdentityId }': {} }
  }
  properties: {
    azPowerShellVersion: '8.1'
    forceUpdateTag: utcValue
    retentionInterval: 'PT1H'
    timeout: 'PT5M'
    cleanupPreference: 'Always' // cleanupPreference: 'OnSuccess' or 'Always'
    arguments: ' -rgName ${resourceGroupName} -hubId ${hubId} -projectName ${projectName}'
    scriptContent: '''
      Param ([string] $resourceGroupName, [string] $hubId, [string] $projectName)
      $startDate = Get-Date
      $startTime = [System.Diagnostics.Stopwatch]::StartNew()
      $message = ""
      $message = "Creating project $($projectName) in hub $($hubId) in RG $($resourceGroupName)..."
      az config set extension.dynamic_install_allow_preview=true          
      az ml workspace create --kind project --resource-group $resourceGroupName --hub-id $hubId --name $projectName
      $endDate = Get-Date
      $endTime = $startTime.Elapsed;
      $elapsedTime = "Script Elapsed Time: {0:HH:mm:ss}" -f ([datetime]$endTime.Ticks)
      $elapsedTime += "; Start: {0:HH:mm:ss}" -f ([datetime]$startDate)
      $elapsedTime += "; End: {0:HH:mm:ss}" -f ([datetime]$endDate)
      Write-Output $message
      Write-Output $elapsedTime
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs['message'] = $message
      $DeploymentScriptOutputs['elapsed'] = $elapsedTime
      '''
  }
}

output message string = createAIHubProject.properties.outputs.message
output elapsed string = createAIHubProject.properties.outputs.elapsed
