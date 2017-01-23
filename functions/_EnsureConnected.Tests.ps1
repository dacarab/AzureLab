begin {
    # Default test variables
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}
}

end {
    Describe "Private function $targetFunction Unit Tests" -tag unit {
        It "[Execution: ] Prompt user to connect to Azure" {}
    }
<#    Describe "Private function $targetFunction Unit Tests" -tag integration {
        It "[Execution: ] " {}
    }#>
}
