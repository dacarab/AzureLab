﻿# Dotsource all the script files from functions folder that are not pester tests
get-childitem $PSScriptRoot\functions -Exclude "*tests*" | ForEach-Object {. $_.FullName}

# Module Variables
$LabTemplatePath = "$PSScriptRoot\files\LabFiles"
$Labs = @{
  Splunk = @{
    LabType = "Splunk"
    TemplatePath = "$LabTemplatePath\Splunk\Splunk.json"
  }
}

function New-AzureLab {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]")]
    [string]$LabName,

    [Parameter(Mandatory)]
    [ValidateSet("Splunk")]
    [string]$LabType,
    
    [Parameter(Mandatory)]
    [securestring]$LabPassword
  )
  # Block to ensure only valid AzureLocations are selected (if connected to Azure)
  DynamicParam {
    _DynamicParamAzureLocation
  }

  Begin { 
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    If (!$PSBoundParameters.ContainsKey("Verbose")) {
          $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }
    
    Write-Verbose "+ENTERING        New-AzureLab $($PSBoundParameters.GetEnumerator())"
    $azureContext = _EnsureConnected
    
    # Assign AzureLocation dynamic parameter value to $AzureLocation for use in script
    $AzureLocation = $($PSBoundParameters.AzureLocation)
  }

  End {
    $newRgState = _NewResourceGroup -LabName $LabName -AzureLocation $AzureLocation -LabType $LabType
    $storageAccount = _NewStorageAccount -LabName $LabName -AzureLocation $AzureLocation
    $storageAccountContext = _GetStorageAccountContext -LabName $LabName -StorageAccount $StorageAccount
    $uploadLabFilesState = _UploadLabFiles -LabType $LabType -StorageContext $storageAccountContext
    $templateParamHash = _GenerateTemplateParamHash-LabType -RealIP
    $deployState = _DeployArmTemplate -LabName $LabName -LabType $LabType -TemplateParamHash $templateParamHash -LabPassword $LabPassword

    Write-Verbose "-EXITING         New-AzureLab          Returning $deployState"
    Return $deployState
  }
  
}

function Remove-AzureLab {
  [CmdletBinding()]
  param(
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]")]
    [Parameter(Mandatory)]
    [string]$LabName
  )

  Begin {
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')

    Write-Verbose "+ENTERING        Remove-AzureLab $($PSBoundParameters.GetEnumerator())"
    $azureContext = _EnsureConnected 
  }

  End {
    $removeResult = $false
     Write-Verbose "Get          AzureRMResourceGroup $LabName"
    $initialState = Get-AzureRmResourceGroup -Name $LabName -ErrorAction SilentlyContinue
    Write-Verbose "Get          AzureRmResourceGroup          returns $initialRGState"
    If ($initialState) {
      if ($initialState.Tags.AutoLab -eq $LabName) {
        Write-Verbose "Remove        AzureRMResourceGroup $LabName"
        $removeResult = Remove-AzureRmResourceGroup -Name $LabName -Force
        Write-Verbose "Remove        AzureRMResourceGroup returned $removeResult"        
      }
      Else {
        Throw "Cannot remove Resource Group $LabName - does not have the correct tag, 'AutoLab'."
      }
  }
  Else {
    Throw "Cannot remove Resource Group $LabName - it does not exist."
  }

  Write-Verbose "-EXITING         Remove-AzureLab Returning $removeResult"
  Return $removeResult
  }
} 

# HelperFunctions
function _DynamicParamAzureLocation { # Dynamic AzureLocation parameter
  $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
  $paramAttributes = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
  $parameterAttribute = New-Object Parameter 
  $parameterAttribute.Mandatory = $true
  $parameterAttribute.ParameterSetName = "Default"
  $parameterAttribute.Position = 1
  $paramAttributes.Add($parameterAttribute)

  Try { # If connected to Azure, create ValidateSet of Azure regions
    $locations = Get-AzureRmLocation | Select-Object -ExpandProperty Location
    $paramAttributes.Add((New-Object ValidateSet $locations))
  }
  Catch { # See if there is a cached copy on the file system
    
  }
  
  $parameterName = "AzureLocation"
  $paramDictionary[$parameterName] = New-Object System.Management.Automation.RuntimeDefinedParameter ($parameterName, [string[]], $paramAttributes)

  Return $paramDictionary
}

function _EnsureConnected { # Ensure Connected to Azure
  [CmdletBinding()]
  Param()
  Try {
      Get-AzureRmContext -ErrorAction Stop
  }
  Catch [System.Management.Automation.PSInvalidOperationException] {
    Write-Host -ForegroundColor Yellow "Please complete your Azure login through the browser window."
    $azureRmContext = Add-AzureRmAccount -ErrorAction Stop
    Write-Host -ForegroundColor Yellow "Continuing..."
  }
  Catch [System.Management.Automation.CommandNotFoundException] {
    Throw "Please ensure that you have AzureRM module installed."
  }
  Catch [Microsoft.Azure.Commands.Common.Authentication.AadAuthenticationCanceledException] {
    Throw "Login canceled - unable to proceed without logging into Azure."
  }
  Return $azureRmContext
}
