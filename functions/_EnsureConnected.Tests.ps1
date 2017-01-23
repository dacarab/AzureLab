begin {
    # Default test variables
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}
}

end {
    Describe "Private function $targetFunction Unit Tests" -tag unit {
        Mock Add-AzureRmAccount {"Connected"}
        $exception = New-MockObject System.Management.Automation.PSInvalidOperationException
        Mock Get-AzureRmContext {$exception}
        It "[Execution: ] Prompt user to connect to Azure" {
            _EnsureConnected -verbose
            Assert-VerifiableMocks 
        }
    }
<#    Describe "Private function $targetFunction Unit Tests" -tag integration {
        It "[Execution: ] " {}
    }#>
}
