$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "New-AzureLab" {
    Context "Input" {
        It "should not accept more than 61 chars for ResourceGroup" {
            $longParam = "61616161616161616161616161616161616161616161616161616161616161"
            {New-SplunkLab -LabName $longParam} | should throw
        }

        It -pending "should not accept non-alphanumeric other than hyphen and underscore" {

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
