$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}
$targetFunction = $sut -replace '\.ps1', ''

# Default testing variables
$LabName = "PesterTest"
$LabType = "Splunk"
$RealIP = "2.2.2.2"
$ModulesUrl
$labpassword = ConvertTo-SecureString -String "P@55word" -AsPlainText -Force
$blobInfo = @{File1 = @{uri = "www"; SasKey = "SomeSasKey"}}

Describe "Private function $targetFunction Unit Tests" -tag unit {
    It "[Execution: ] Does not throw" {
        {_GenerateTemplateParamHash -LabName $LabName -LabType $labType -RealIP $RealIP -LabPassword $labPassword -BlobInfo $blobInfo} | Should not throw
    }

    # Need better checking on the output to ensure SasKey and uri are passed
    It "[Output:    ] returns a  hash" {
        _GenerateTemplateParamHash -LabName $LabName -LabType $labType -RealIP $RealIP -LabPassword $labPassword -BlobInfo $blobInfo |
         Should BeofType [HashTable]
    
  }
}