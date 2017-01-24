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
    Mock Get-AzureStorageContainer {}

    It "[Execution: ] Should throw if Lab files do not exist" {
        {_UploadLabFiles -LabType "wibbler" -StorageContext $storageContext } | should throw
    }

    It "[Execution: ] Should create blob container for lab files if one DOES NOT exist" {
        $returned = _UploadLabFiles -LabType $labType -StorageContext $storageContext 
        Assert-MockCalled New-AzureStorageContainer -times 1
    }

    Mock Get-AzureStorageContainer {@{Name = "labfiles"}}
    It "[Execution: ] Should NOT create blob container for lab files if one DOES exist" {
        _UploadLabFiles -LabType $labType -StorageContext $storageContext 
        Assert-MockCalled New-AzureStorageContainer -Times 1
    }

    It "[Execution: ] Should upload the files" {
        Assert-MockCalled Set-AzureStorageBlobContent 
    }

    It "[Output:    ] Should return the expected output" {
        _UploadLabFiles -LabType $labType -StorageContext $storageContext | Should be "File1"
    }

}

<#Describe "Private function $targetFunction Unit Tests" -tag Integration {
    It "[Execution: ] Should create blob container for lab file"
    It "Should not throw when attempting to access the local files"
    It "Should upload the files"
    It "Should return the expected output"

}#>