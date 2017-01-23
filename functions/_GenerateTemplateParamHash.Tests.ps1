$targetFunction = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
  It "[Execution:   ] Does not throw" {
      {_}
  }
  It "[Output:      ] returns a valid parameter hash" {}
}