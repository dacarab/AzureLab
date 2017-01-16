$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Remove-AzureLab" {
    Context Input {
        It -Pending "accepts valid parameters" {

        }
    }

    Context Execution {
        It "does not throw"  {
            New-AzureRmResourceGroup -Name PesterTest -Location UKSouth -Tag @{AutoLab=$true} | Out-Null
            {Remove-AzureLab -LabName PesterTest} | Should Not throw
        }
    }

    Context Output {


    }

}
