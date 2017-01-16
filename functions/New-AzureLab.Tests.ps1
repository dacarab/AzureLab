$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "New-AzureLab" {
    Context "Input" {
        It "should not accept more than 61 chars for ResourceGroup" {
            $longParam = "61616161616161616161616161616161616161616161616161616161616161"
            {New-SplunkLab -ResourceGroup $longParam} | should throw
        }

        It -pending "should not accept non-alphanumeric other than hyphen and underscore" {

        }
    }

    Context Execution {
        It -Pending "Processes the passed inputs correctly" {

        }

    }

    Context Output {
        It -Pending "Returns the proper type"

    }
}
