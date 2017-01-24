$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}
$targetFunction = $sut -replace '\.ps1', ''

# Default testing variables
$LabName = "PesterTest"
$LabType = "Splink"
$RealIP = "2.2.2.2"
$labpassword = ConvertTo-SecureString -String "P@55word" -AsPlainText -Force

Describe "Private function $targetFunction Unit Tests" -tag unit {
    It "[Execution: ] Does not throw" {
        {_GenerateTemplateParamHash -LabName $LabName -LabType $labType -RealIP $RealIP -LabPassword $labPassword} | Should not throw
    }
    It "[Output:    ] returns a  hash" {
        _GenerateTemplateParamHash -LabName $LabName -LabType $labType -RealIP $RealIP -LabPassword $labPassword |
         Should BeofType [HashTable]
    
  }
}