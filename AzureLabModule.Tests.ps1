[CmdletBinding()]
param()
<#Param(
  [Switch]$Verbose,
  [Switch]$Unit,
  [Switch]$Integration
)#>

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Clear-Host
Write-Host -ForegroundColor yellow "Removing and re-importing AzureLab Module"
Remove-Module AzureLab -ErrorAction SilentlyContinue -Verbose:$false
Import-Module -name .\AzureLab.psm1 -Verbose:$false

& .\functions\_NewResourceGroup.Tests.ps1
& .\functions\_NewStorageAccount.Tests.ps1
& .\functions\_LabNameToStorageAccountName.Tests.ps1
& .\functions\_GetStoragAccountContext.Tests.ps1
& .\functions\_UploadLabFiles.Tests.ps1
& .\functions\_ConfigureArmTemplate.Tests.ps1
& .\functions\_DeployArmTemplate.Tests.ps1

Describe "New-AzureLab Unit Tests" -Tag Unit {
  BeforeAll {Copy-Item "$here\files\AzureRmLocations.xml" TestDrive:}

  $labName = "PesterTest"
  $labType = "Splunk"
  $azureLocation = "UKSouth"
  $password = ConvertTo-SecureString "P@55w0rd" -AsPlainText -Force

  Mock Get-AzureRmStorageAccountKey {@(,[PSCustomObject]@{value = "KEY1"})} -ModuleName AzureLab
  Mock _EnsureConnected {$true} -ModuleName AzureLab
  Mock Get-AzureRmLocation  {(Import-Clixml -Path "TestDrive:\AzureRmLocations.xml")} -ModuleName AzureLab
  Mock Find-AzureRmResource {} -ModuleName AzureLab
  Mock Get-AzureRmStorageAccountNameAvailability {[PSCustomObject]@{NameAvailable = $true}} -ModuleName AzureLab
  Mock New-AzureRmStorageAccount {@{StorageAccountName = "teststorage"}} -ModuleName AzureLab 
  $newAzureLab_inputTestCases_Fail = @(
    @{
      scenario = "LabName - does not accept input longer than 61 chars"
      expected = "Cannot validate argument on parameter 'LabName'. The character length of the 62 argument is too long"
      labName = "62626262626262626262626262626262626262626262626262626262626262"
      labType = "Splunk"
      azureLocation = "UKSouth"
      labPassword = $password
      shouldBlock = {}
    },
    @{
      scenario = "LabName - does not accept input with a $ sign"
      expected = "Cannot validate argument on parameter 'LabName'. The argument `"`" does not match the `"[a-zA-Z0-9_-]`" pattern."
      labName = "$ShouldNotBeValid"
      labType = "Splunk"
      azureLocation = "UKSouth"
      labPassword = $password
      shouldBlock = {}
    },      
    @{
      scenario = "AzureLocation - does not accept missing parameter"
      expected = "Cannot validate argument on parameter 'AzureLocation'. The argument is null"
      labName = "TestLab"
      labType = "Splunk"
      azureLocation = $Null
      labPassword = $password
    },
    @{
      scenario = "AzureLocation - does not accept non-existent Azure regions"
      expected = "Cannot validate argument on parameter 'AzureLocation'. The argument `"NonExistentAzureLocation`" does not belong"
      labName = "TestLab"
      labType = "Splunk"
      azureLocation = "NonExistentAzureLocation"
      labPassword = $password
    },
    @{
      scenario = "LabType - does not accept missing parameter"
      expected = "Cannot validate argument on parameter 'LabType'. The argument `"`" does not belong to the set `"Splunk`""
      labName = "TestLab"
      #labType = $Null
      azureLocation = "UKSouth"
      labPassword = $password
      },
    @{
      scenario = "LabType - does not accept non-existent LabType"
      expected = "Cannot validate argument on parameter 'LabType'. The argument `"NonExistentLabType`" does not belong"
      labName = "TestLab"
      labType = "NonExistentLabType"
      azureLocation = "UKSouth"
      labPassword = $password
      },
    @{
      scenario = "LabPassword - does not accept missing parameter"
      expected = "Cannot bind argument to parameter 'LabPassword' because it is null."
      labName = "TestLab"
      labType = "Splunk"
      ezureLocation = "UKSouth"
      labPassword = $Null
    },
    @{
      scenario = "LabPassword - does not accept wrong type"
      expected = "Cannot process argument transformation on parameter 'LabPassword'. Cannot convert the `"AStringPassword`" value of type `"System.String`" to type `"System.Security.SecureString`"."
      labName = "TestLab"
      labType = "Splunk"
      azureLocation = "UKSouth"
      labPassword = "AStringPassword"
    }
  )

  $newAzureLab_inputTestCases_Pass = @(
    @{
      scenario = "LabName - accepts input with hyphens and underscores"
      labName = "_Underscores-and-Hyphens_"
      labType = "Splunk"
      azureLocation = "UKSouth"
      labPassword = $password
    }
  )

  # New-AzureLab input tests
  It "[Input:     ] Should Fail: <scenario>" -TestCases $newAzureLab_inputTestCases_Fail {
    param ($labName, $labType, $azureLocation, $labPassword, $expected)
    {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $labPassword} | Should throw $expected
  }

  It "[Input:     ] Should Pass: <scenario>" -TestCases $newAzureLab_inputTestCases_Pass {
    param ($labName, $labType, $azureLocation, $labPassword)
    Mock  Get-AzureRmResourceGroup  {$false} -ModuleName AzureLab
    Mock  New-AzureRmResourceGroupDeployment  {$true} -ModuleName AzureLab
    Mock  New-AzureRmResourceGroup  {[PSCustomObject]@{ResourceGroupName = $LabName; Tags = @{AutoLab = $LabName;}}} -ModuleName AzureLab
    {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $labPassword} |
     Should not throw 
  }      

  # New-AzureLab execution tests
  It "[Execution: ] Does not throw when provided example parameters" {
    {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $password} |
     Should not throw
  }

  # New-AzureLab output tests
  It -Pending "Output - Returns the proper type"

} # Describe New-AzureLAb

Describe "Remove-AzureLab Unit Tests" -Tag Unit {
  # Mocks - overwritten in It statements as required
  Mock  _EnsureConnected  {
    #TODO: Simulate return data properly
    Return $true
  } -ModuleName AzureLab

  Mock  Get-AzureRmLocation  {
    $returnData = Import-Clixml -Path "TestDrive:\AzureRmLocations.xml"
    Return $returnData
  } -ModuleName AzureLab

  # Variables - overwritten in It statements as required
  $labName = "PesterTest"
  $labType = "Splunk"
  $azureLocation = "UKSouth"
  $password = ConvertTo-SecureString "P@55w0rd" -AsPlainText -Force

  # Context block TestCases
  $removeAzureLab_inputTestCases_Fail = @(
    @{
      scenario = "LabName - does not accept input longer than 61 chars"
      expected = "Cannot validate argument on parameter 'LabName'. The character length of the 62 argument is too long"
      labName = "62626262626262626262626262626262626262626262626262626262626262"
    },
    @{
      scenario = "LabName - does not accept input with a $ sign"
      expected = "Cannot validate argument on parameter 'LabName'. The argument `"`" does not match the `"[a-zA-Z0-9_-]`" pattern."
      labName = "$ShouldNotBeValid"
    }
  )

  $removeAzureLab_inputTestCases_Pass = @(
    @{
      scenario = "LabName - accepts input with hyphens and underscores"
      labName = "_Underscores-and-Hyphens_"
    }
  )

  # INPUT TESTS
  It "[Input:     ] Should Fail: <scenario>" -TestCases $removeAzureLab_inputTestCases_Fail {
    param ($labName, $labType, $azureLocation, $labPassword, $expected)
    {Remove-AzureLab -LabName $labName} | Should throw $expected
  }

  It "[Input:     ] Should Pass: <scenario>" -TestCases $removeAzureLab_inputTestCases_Pass {
    param ($labName, $labType, $azureLocation, $labPassword)
    Mock  Remove-AzureRmResourceGroup  {
      Return $true
    } -ModuleName AzureLab

    Mock  Get-AzureRmResourceGroup  {
      $returnData = @{
        ResourceGroupName = $LabName
        Tags = @{
          AutoLab = $LabName
        }
      }
      Return [PSCustomObject]$returnData
    } -ModuleName AzureLab

    {Remove-AzureLab -LabName $labName } | Should not throw 
  }

  # EXECUTION TESTS
  It "[Execution: ] Should throw if the specified Resource Group does not exist" {
    Mock  Get-AzureRmResourceGroup  {
      Return $Null
    } -ModuleName AzureLab
    {Remove-AzureLab -LabName $labName} |
      Should throw "Cannot remove Resource Group $labName - it does not exist."
  }

  It "[Execution: ] Should throw if specified Resource Group does not have appropriate tag 'AutoLab'" {
    Mock  Get-AzureRmResourceGroup  {
      $returnData = @{
        ResourceGroupName = $LabName
        Tags = @{}
      }
      Return [PSCustomObject]$returnData
    } -ModuleName AzureLab
    {Remove-AzureLab -LabName $labName} |
      Should throw "Cannot remove Resource Group $labName - does not have the correct tag, 'AutoLab'."
  }

  # OUTPUT TESTS
  It "[Output:    ] Returns $false if ResourceGroup does exist after remove attempt" {
    Mock  Get-AzureRmResourceGroup  {
      $returnData = @{
        ResourceGroupName = $LabName
        Tags = @{
          AutoLab = $LabName
        }
      }
      Return [PSCustomObject]$returnData
    } -ModuleName AzureLab

    Mock  Remove-AzureRmResourceGroup  {
      Return $false
    } -ModuleName AzureLab

    Remove-AzureLab -LabName $labName | Should be $false
  }

}

Describe "Azure Lab Integration Tests" -Tag Integration {
  It -Pending "Execution - should remove  specified Resource Group" {
    Remove-AzureLab -LabName $labName | Should be $true
  }

  It -Pending "Output - should return $true if ResourceGroup does not exist after remove attempted" {
    Mock  Get-AzureRmResourceGroup  {
      Return $Null
    } -ParameterFilter {$Name -and $Name -eq $LabName} -ModuleName AzureLab
    Remove-AzureLab -LabName "$labName" | Should Be $true
  }
}

$Global:VerbosePreference = "SilentlyContinue"

Write-Host -ForegroundColor yellow "Removing AzureLab Module"
Remove-Module AzureLab -Verbose:$false