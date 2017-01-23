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