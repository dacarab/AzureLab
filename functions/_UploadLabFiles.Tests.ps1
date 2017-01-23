$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
$targetFunction = $sut -replace '\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
    $labType = "Splunk"
    $labName = "PesterTest"
    $storageAccount = @{StorageAccountName = "teststorage"}
    $storageContext = New-MockObject  Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext

    Mock New-AzureStorageContainer {@{Name = "test"}}
    Mock Set-AzureStorageBlobContent {@(,"File1")}
    Mock Get-ChildItem {[PSCustomObject]@{FullName = "File1"}} 
    
    $returned = _UploadLabFiles -LabType $labType -StorageContext $storageContext 
    It "[Execution: ] Should create blob container for lab file" {
        Assert-MockCalled New-AzureStorageContainer 
    }

    It "[Execution: ] Should upload the files" {
        {_UploadLabFiles -LabType $labType -StorageContext $storageContext} |
        Should not throw
        #Assert-MockCalled Set-AzureStorageBlobContent 
    }

    It "[Output:    ] Should return the expected output" {
        $returned | Should be "File1"
    }

}

<#Describe "Private function $targetFunction Unit Tests" -tag Integration {
    It "[Execution: ] Should create blob container for lab file"
    It "Should not throw when attempting to access the local files"
    It "Should upload the files"
    It "Should return the expected output"

}#>