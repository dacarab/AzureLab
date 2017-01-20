# Dotsource all the script files from functions folder that are not pester tests
get-childitem $PSScriptRoot\functions -Exclude "*tests*" | ForEach-Object {. $_.FullName}

Function New-AzureLab {
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
  # Block to ensure only valid AzureLocations are selected
  DynamicParam {
    _DynamicParamAzureLocation
  }
  Begin { 
    Write-Verbose "+ENTERING        New-AzureLab"
    $azureContext = _EnsureConnected
    
    # Assign AzureLocation dynamic parameter value to $AzureLocation for use in script
    $AzureLocation = $($PSBoundParameters.AzureLocation)
  }

  End {
    $newRgState = _NewResourceGroup -Name $LabName -Location $AzureLocation -LabType $LabType -Verbose

    $newSaState = _NewStorageAccount -Name -ResourceGroup

    $uploadLabFilesState = _UploadLabFiles -LabType -ResourceGroup

    $configureTemplateState = _ConfigureArmTemplate -LabType -RealIP

    $configureDeployState = _DeployArmTemplate -ResourceGroupName $LabName -LabType $LabType -LabPassword $LabPassword

    Return $configureDeployState
  }
  
}

# HelperFunctions
Function _DynamicParamAzureLocation { # Dynamic AzureLocation parameter 
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

Function _EnsureConnected { # Ensure Connected to Azure
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

