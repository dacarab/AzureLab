$targetFunction = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
    $labName = "PesterTest"
    $storageAccount = @{StorageAccountName = "teststorage"}
    Mock Get-AzureRmStorageAccountKey {@(,[PSCustomObject]@{value = "KEY1"})} -ModuleName AzureLab
    Mock New-AzureStorageContext {$storageAccount} -ModuleName AzureLab
    $returned =  _GetStorageAccountContext -LabName $labName -StorageAccount $storageAccount

    It "[Execution: ] Retrieves a storage account key" {
        Assert-MockCalled Get-AzureRmStorageAccountKey -Times 1 -ModuleName AzureLab
    }

    It "[Execution: ] Creates a storage account context" {
        Assert-MockCalled New-AzureStorageContext -Times 1 -ModuleName AzureLab
    }

    It "[Output:    ] Returns expected object" {
        $returned.StorageAccountName | Should be $StorageAccount.StorageAccountName
    }
}