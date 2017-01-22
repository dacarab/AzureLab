$targetFunction = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
    $labType = "Splunk"
    $labName = "PesterTest"
    $storageAccount = @{StorageAccountName = "teststorage"}
    $storageContext = New-MockObject  Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext

    Mock New-AzureStorageContainer {@{Name = "test"}} -ModuleName AzureLab
    Mock Set-AzureStorageBlobContent {@(,"File1")} -ModuleName AzureLab
    Mock Get-ChildItem {[PSCustomObject]@{FullName = "File1"}} -ModuleName AzureLab 
    
    $returned = _UploadLabFiles -LabType $labType -StorageContext $storageContext 
    It "[Execution: ] Should create blob container for lab file" {
        Assert-MockCalled New-AzureStorageContainer -ModuleName AzureLab
    }

    It "[Execution: ] Should upload the files" {
        {_UploadLabFiles -LabType $labType -StorageContext $storageContext} |
        Should not throw
        #Assert-MockCalled Set-AzureStorageBlobContent -ModuleName AzureLab
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