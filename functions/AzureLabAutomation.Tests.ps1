$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Initialize-AzureLabAutomation" {
    Context Inputs {
        $labNameCases = @(
            @{
                LabName = "62626262626262626262626262626262626262626262626262626262626262"
                TestScenario = "throws if input longer than 61 characters"
            },
            @{
                LabName = '$Wibbler'
                TestScenario = "throws if input contains a $ sign"
            }
        )

        $dscSourceFolderCases = @(
            @{
                testDSCSourceFolder = "C:\AMadeUpFolderName"
                TestScenario = "throws if folder does not exist"
            }
        )

        It "accepts valid input for LabName: <TestScenario>" -TestCases $labNameCases {
            {Initialize-AzureLabAutomation -LabName $LabName} | should throw "Cannot validate argument on parameter"
        }

        It "accepts valid input for DSCSourceFolder: <TestScenario>" -TestCases $dscSourceFolderCases {
            {Initialize-AzureLabAutomation -LabName "TestLab" -DSCSourceFolder $testDSCSourceFolder} | Should throw "Cannot validate argument on parameter"
        }

    }

    Context Execution {
        It -Pending "throws if not connected to Azure ARM" {

        }

       It -Pending "creates an Automation account if one does not exist for lab" {

       }

       It -Pending "does not try and create an Automation account if one does exist" {

       }

       It -Pending "uploads DSC configs from the specified source folder" {

       }


    }

    Context Outputs {

        It -Pending "outputs a correctly formatted object to indicate lab automation config" {

        }

    }
}
