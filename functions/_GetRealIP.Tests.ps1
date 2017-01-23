$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}
$targetFunction = $sut -replace '\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
    It "[Execution: ] Does not throw" {
        {_GetRealIP} | Should Not throw
    }
    It "[Output:    ] Returns a correctly formatted ip address" {
        $returnData = _GetRealIP 
        $returnData -match "^\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b$"| Should be $true
    }
}