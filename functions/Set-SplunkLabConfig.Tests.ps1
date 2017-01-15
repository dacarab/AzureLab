$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Set-SplunkLabConfig" {
    Context Input {
        It -pending "Accepts parameters in the correct format" {

        }
    }

    Context Execution {
        It -pending "Processes the input parameters correctly" {
            
        }
    }

    Context Output {
        It -Pending "Returns the correct type of Output" {

        }

    }
}
