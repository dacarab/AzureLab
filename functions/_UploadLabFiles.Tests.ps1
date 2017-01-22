$targetFunction = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
    It "[Execution: ] Should create blob container for lab file"
    It "[Execution: ] Should not throw when attempting to access the local files"
    It "[Execution: ] Should upload the files"
    It "[Output:    ] Should return the expected output"

}

<#Describe "Private function $targetFunction Unit Tests" -tag Integration {
    It "[Execution: ] Should create blob container for lab file"
    It "Should not throw when attempting to access the local files"
    It "Should upload the files"
    It "Should return the expected output"

}#>