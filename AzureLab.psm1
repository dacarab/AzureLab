<#
    I'm looking to develop some Splunk apps that would monitor and alert on a domain,as well as #nix stuff.
    So Splunk on ubuntu is fine... but would need a domain controller to pull data from, and experiment with audit policy.
    A couple of member servers for the same.
    A few scrips that crete a bunch of users and groups.
    A few scripts that make changes on a periodic basis that I can report and alert against .
    And I guess a desktop that I can use from within the environment to do the do. 
#>

# Dotsource all the script files from functions folder that are not pester tests
get-childitem $PSScriptRoot\functions -Exclude "*tests*" | ForEach-Object {. $_.FullName}

# HelperFunction for Dynamic AzureLocation parameter 
Function Helper_DynamicParamAzureLocation {
  $locations = Get-AzureRmLocation | Select-Object -ExpandProperty Location
  $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
  $paramAttributes = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
  $paramAttributes.Add((New-Object Parameter))
  $paramAttributes.Add((New-Object ValidateSet $locations))
  $parameterName = "AzureLocation"
  $paramDictionary[$parameterName] = New-Object System.Management.Automation.RuntimeDefinedParameter ($parameterName, [string[]], $paramAttributes)

  Return $paramDictionary
}
