begin {
    # Default test variables
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}
}

end {
    Describe "Private function $targetFunction Unit Tests" -tag unit {
        Mock Get-AzureRmLocation {[PSCustomObject]@{Location = "UKSouth"}} -AzureLab

        It "[Execution: ] Should add a dynamic parameter to the script" {
            $returnedData = _DynamicParamAzureLocation 
            $returnedData.ContainsKey("AzureLocation") | Should be $true
        }
    }
<#    Describe "Private function $targetFunction Unit Tests" -tag integration {
        It "[Execution: ] Should retrieve valid Azure Locations" {}
    }#>
}

