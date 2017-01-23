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
& .\functions\_GetRealIP.Tests.ps1
& .\functions\_GenerateTemplateParamHash.Tests.ps1
& .\functions\_DeployArmTemplate.Tests.ps1

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