$targetFunction = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
    $labName = "TestLab"
    Mock Get-AzureRmResourceGroup {[PSCustomObject] @{ResourceGroupName = $LabName; Tags = @{AutoLab = $LabName}}} -ModuleName AzureLab
    Mock New-AzureRmStorageAccount {} -ModuleName AzureLab
    Mock Write-Warning {} -ModuleName AzureLab
    Mock Get-AzureRmStorageAccountNameAvailability {[PSCustomObject]@{NameAvailable = $false}} -ModuleName AzureLab
    Mock Find-AzureRmResource {} -ModuleName AzureLab
    Mock Read-Host {"y"} -ModuleName AzureLab

    It "[Execution: ] Should throw if unable to create valid storage account name after 10 attempts" {
        {_LabNametoStorageAccountName -LabName $labName} | Should throw "Cannot find valid storage account name."
    }

    Mock Get-AzureRmStorageAccountNameAvailability {[PSCustomObject]@{NameAvailable = $true}} -ModuleName AzureLab
    It "[Output:    ] Should return a string containing only alpha-numeric characters" {
        $return = _LabNametoStorageAccountName -LabName $labName
        $alphaNumeric = "[^a-zA-Z0-9]"
        $return -replace $alphaNumeric, '' | Should be $return
    }

    It "[Output:    ] Should return a string not containing upper case characters" {
        $return = _LabNametoStorageAccountName -LabName $labName
        $return.ToLower() | Should Be $return
    }

    It "[Output:    ] Should return a string with a 6 digit suffix" {
        $return = _LabNametoStorageAccountName -LabName $labName
        $return -match "\d{6}$" | Should Be $true
    }
}

<#Describe "Private function $targetFunction Unit Tests" -tag unit {
  It "[Execution: ] Should return a valid storage account name"

}#>