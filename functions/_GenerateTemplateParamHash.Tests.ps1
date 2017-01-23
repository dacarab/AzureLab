$targetFunction = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''

# Default testing variables
$LabType = "Splink"
$RealIP = "2.2.2.2"
$labpassword = ConvertTo-SecureString -String "P@55word" -AsPlainText -Force

Describe "Private function $targetFunction Unit Tests" -tag unit {
  It "[Execution:   ] Does not throw" {
      {_GenerateTemplateParamHash -LabType $labType -RealIP $RealIP -LabPassword $labPassword} | Should not throw
  }
  It "[Output:      ] returns a  hash" {
    _GenerateTemplateParamHash -LabType $labType -RealIP $RealIP -LabPassword $labPassword |
     Should BeofType [HashTable]
    
  }
}