# Dotsource all the script files from functions folder that are not pester tests
get-childitem $PSScriptRoot\functions -Exclude "*tests*" | ForEach-Object {. $_.FullName}

# HelperFunctions
# Dynamic AzureLocation parameter 
Function Helper_DynamicParamAzureLocation {
  $locations = Get-AzureRmLocation | Select-Object -ExpandProperty Location
  $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
  $paramAttributes = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
  $parameterAttribute = New-Object Parameter 
  $parameterAttribute.Mandatory = $true
  $parameterAttribute.ParameterSetName = "Default"
  $parameterAttribute.Position = 1
  $paramAttributes.Add($parameterAttribute)
  $paramAttributes.Add((New-Object ValidateSet $locations))
  $parameterName = "AzureLocation"
  $paramDictionary[$parameterName] = New-Object System.Management.Automation.RuntimeDefinedParameter ($parameterName, [string[]], $paramAttributes)

  Return $paramDictionary
}

# Ensure Connected to Azure
Function Helper_EnsureConnected {
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