$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "New-AzureLab" {
    Context "Input" {
        # TestCases
        $labNameCases = @(
            @{
                testLabName = "61616161616161616161616161616161616161616161616161616161616161"
                TestScenario = "throws if input longer than 61 characters"
            },
            @{
                testLabName = '$Wibbler'
                TestScenario = "throws if input contains a $ sign"
            }
        )

        # Parameter Variables
        $labName = "PesterTest"
        $azureLocation = "UKSouth"
        $badAzureLocation = "Biggleswade"
        $password = ConvertTo-SecureString "P@55w0rd" -AsPlainText -Force

        # Mocks 
        Mock -CommandName New-AzureRmResourceGroupDeployment -MockWith {
            #TODO - Return data
        }

        It "accepts valid input for LabName: <TestScenario>" -TestCases $labNameCases {
            {New-AzureLab -LabName $testLabName -AzureLocation $azureLocation -LabPassword $password} |
                should throw "Cannot validate argument on parameter"
        }

        It "accepts existing Azure regions as input for AzureLocation" {
            {New-AzureLab -LabName $labName -AzureLocation $badAzureLocation -LabPassword $password} |
                should throw "Cannot validate argument on parameter"
        }

        It "does not accept invalid Azure regions as input for AzureLocation" {
            {New-AzureLab -LabName $labName -AzureLocation $azureLocation -LabPassword $password} |
                should throw "Cannot validate argument on parameter"
        }

    }

    Context Execution {
        It -Pending "Creates the required ResourceGroup if it does not exist" {

        }

        It -Pending "Does not throw if the ResourceGroup already exists" {

        }

        It -Pending "does not throw when called" {
            $password = ConvertTo-SecureString "P@55w0rd" -AsPlainText -Force
            {New-AzureLab -LabName TestLab -AzureLocation UKSouth -LabPassword $password} | Should not throw
        }

    }

    Context Output {
        It -Pending "Returns the proper type"

    }
}

Describe "Remove-AzureLab" {
    Context Input {
        It -Pending "accepts valid parameters" {

        }
    }

    Context Execution {
        It -Pending "does not throw"  {
            New-AzureRmResourceGroup -Name PesterTest -Location UKSouth -Tag @{AutoLab=$true} | Out-Null
            {Remove-AzureLab -LabName PesterTest} | Should Not throw
        }
    }

    Context Output {


    }

}