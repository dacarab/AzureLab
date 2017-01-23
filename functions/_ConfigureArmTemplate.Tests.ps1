$targetFunction = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
  It "[Input:       ] Takes the correct arguments" {}
  It "[Execution:   ] Generates a parameter hash" {}
  It "[Output:      ] returns a valid parameter hash" {}
}