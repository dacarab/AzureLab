# Variables
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}
$targetFunction = $sut -replace '\.ps1', ''

$labName = "PesterTest"
$labType = "Splunk"
$azureLocation = "UKSouth"
$password = ConvertTo-SecureString "P@55w0rd" -AsPlainText -Force
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

Describe "Remove-AzureLab Unit Tests" -Tag Unit {

    # Mocks
    Mock  _EnsureConnected {$true}
    Mock  Get-AzureRmLocation {Import-Clixml -Path "TestDrive:\AzureRmLocations.xml"}
    Mock  Remove-AzureRmResourceGroup  {$true}
    Mock  Get-AzureRmResourceGroup {@{ResourceGroupName = $Name; Tags = @{AutoLab = $Name}}}

    It "[Input:     ] Should Fail: <scenario>" -TestCases $removeAzureLab_inputTestCases_Fail {
        param ($labName, $labType, $azureLocation, $labPassword, $expected)

        {Remove-AzureLab -LabName $labName} | Should throw $expected

    }

    It "[Input:     ] Should Pass: <scenario>" -TestCases $removeAzureLab_inputTestCases_Pass {
        param ($labName, $labType, $azureLocation, $labPassword)

        {Remove-AzureLab -LabName $labName } | Should not throw

    }

    # EXECUTION TESTS
    It "[Execution: ] Should throw if the specified Resource Group does not exist" {
        Mock  Get-AzureRmResourceGroup {}

        {Remove-AzureLab -LabName $labName} | Should throw "Cannot remove Resource Group $labName - it does not exist."

    }

    It "[Execution: ] Should throw if specified Resource Group does not have appropriate tag 'AutoLab'" {
    Mock  Get-AzureRmResourceGroup  {
        $returnData = @{
        ResourceGroupName = $LabName
        Tags = @{}
        }
        Return [PSCustomObject]$returnData
    }
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
    }

    Mock  Remove-AzureRmResourceGroup  {
        Return $false
    }

    Remove-AzureLab -LabName $labName | Should be $false
    }

}
