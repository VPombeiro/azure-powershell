# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

<#
.SYNOPSIS
Gets valid resource group name
#>
function Get-ResourceGroupName
{
    return getAssetName
}

<#
.SYNOPSIS
Gets valid resource name
#>
function Get-ResourceName
{
    return getAssetName
}

<#
.SYNOPSIS
Gets the default location for a provider
#>
function Get-ProviderLocation($provider)
{
	if ([Microsoft.Azure.Test.HttpRecorder.HttpMockServer]::Mode -ne [Microsoft.Azure.Test.HttpRecorder.HttpRecorderMode]::Playback)
	{
		$namespace = $provider.Split("/")[0]  
		if($provider.Contains("/"))  
		{  
			$type = $provider.Substring($namespace.Length + 1)  
			$location = Get-AzResourceProvider -ProviderNamespace $namespace | where {$_.ResourceTypes[0].ResourceTypeName -eq $type}  
  
			if ($location -eq $null) 
			{  
				return "West US"  
			} else 
			{  
				return $location.Locations[0]
			}  
		}
		
		return "West US"
	}

	return "WestUS"
}

<#
.SYNOPSIS
Gets the default test location name.
#>
function Get-LocationName()
{
	return 'brazilsouth'
}

<#
.SYNOPSIS
Creates a resource group to use in tests
#>
function TestSetup-CreateResourceGroup
{
    $resourceGroupName = getAssetName
	$rglocation = Get-ProviderLocation "North Europe"
    $resourceGroup = New-AzResourceGroup -Name $resourceGroupName -location $rglocation -Force
	
	return $resourceGroup
}

<#
.SYNOPSIS
Creates named resource group to use in tests
#>
function TestSetup-CreateNamedResourceGroup([string]$resourceGroupName)
{
	$location = Get-LocationName
    $resourceGroup = New-AzResourceGroup -Name $resourceGroupName -location $location -Force
	
	return $resourceGroup
}

<#
.SYNOPSIS
Creates a new Integration account
#>
function TestSetup-CreateIntegrationAccount ([string]$resourceGroupName, [string]$integrationAccountName)
{
	$location = Get-LocationName
	$integrationAccount = New-AzIntegrationAccount -ResourceGroupName $resourceGroupName -IntegrationAccountName $integrationAccountName -Location $location -Sku "Standard"
	return $integrationAccount
}

<#
.SYNOPSIS
Creates a new workflow
#>
function TestSetup-CreateWorkflow ([string]$resourceGroupName, [string]$workflowName, [string]$AppServicePlan)
{
	$rglocation = Get-ProviderLocation "North Europe"
    $resourceGroup = New-AzResourceGroup -Name $resourceGroupName -location $rglocation -Force

	TestSetup-CreateAppServicePlan $resourceGroupName $AppServicePlan

	$definitionFilePath = Join-Path "Resources" "TestSimpleWorkflowDefinition.json"
	$parameterFilePath = Join-Path "Resources" "TestSimpleWorkflowParameter.json"
	$workflow = $resourceGroup | New-AzLogicApp -Name $workflowName -Location $WORKFLOW_LOCATION -DefinitionFilePath $definitionFilePath -ParameterFilePath $parameterFilePath
    return $workflow
}

<#
.SYNOPSIS
Sleep in record mode only
#>
function SleepInRecordMode ([int]$SleepIntervalInMillisec)
{
	$mode = $env:AZURE_TEST_MODE
	if ( $mode -ne $null -and $mode.ToUpperInvariant() -eq "RECORD")
	{
		Sleep -Milliseconds $SleepIntervalInMillisec 
	}
}