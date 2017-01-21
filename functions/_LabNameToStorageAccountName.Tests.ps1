$targetFunction = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {

}