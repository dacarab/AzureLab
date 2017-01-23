$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}
$targetFunction = $sut -replace '\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
    $labName = "PesterTest"
    $storageAccount = @{StorageAccountName = "teststorage"}
    Mock Get-AzureRmStorageAccountKey {@(,[PSCustomObject]@{value = "KEY1"})}
    Mock New-AzureStorageContext {$storageAccount}
    $returned =  _GetStorageAccountContext -LabName $labName -StorageAccount $storageAccount

    It "[Execution: ] Retrieves a storage account key" {
        Assert-MockCalled Get-AzureRmStorageAccountKey -Times 1 
    }

    It "[Execution: ] Creates a storage account context" {
        Assert-MockCalled New-AzureStorageContext -Times 1 
    }

    It "[Output:    ] Returns expected object" {
        $returned.StorageAccountName | Should be $StorageAccount.StorageAccountName
    }
}