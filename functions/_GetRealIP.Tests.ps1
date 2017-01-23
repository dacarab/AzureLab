$targetFunction = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
    It "[Execution: ] Does not throw" {
        {_GetRealIP} | Should Not throw
    }
    It "[Output:    ] Returns a correctly formatted ip address" {
        $returnData = _GetRealIP 
        $returnData -match "^\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b$"| Should be $true
    }
}