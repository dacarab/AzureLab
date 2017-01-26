$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
$targetFunction = $sut -replace '\.ps1', ''

$LabFilesPath = "$here\..\files\LabFiles"
$LabConfigData = @{
    LabFilesPath = $LabFilesPath
    Splunk = @{
        TemplatePath = "$LabFilesPath\Splunk\SplunkLab.json"
        DomainController_DSCFunction = "SplunkLab.ps1//DomainController"
    }
}


Describe "Private function $targetFunction Unit Tests" -tag unit {
    $labType = "Splunk"
    $labName = "PesterTest"
    $storageAccount = @{StorageAccountName = "teststorage"}
    $storageContext = New-MockObject  Microsoft.WindowsAzure.Commands.Common.Storage.AzureStorageContext

    Mock New-AzureStorageContainer {@(,@{Name = "test";uri="someuri";SasToken = "someSasToken"})}
    Mock Set-AzureStorageBlobContent {@{Name = "someBlob" ;ICloudBlob = @{uri = "www"}}}
    Mock Get-ChildItem {[PSCustomObject]@{FullName = "File1"}}
    Mock Get-AzureStorageContainer {}
    Mock Read-Host {"y"}
    Mock New-AzureStorageBlobSASToken {"someSasToken"}
    Mock Write-Warning {}

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
        $returned = _UploadLabFiles -LabType $labType -StorageContext $storageContext 
        $returned.where({$_.Name -eq "someBlob"}).name | Should be "someBlob"
    }

}

<#Describe "Private function $targetFunction Unit Tests" -tag Integration {
    It "[Execution: ] Should create blob container for lab file"
    It "Should not throw when attempting to access the local files"
    It "Should upload the files"
    It "Should return the expected output"

}#>