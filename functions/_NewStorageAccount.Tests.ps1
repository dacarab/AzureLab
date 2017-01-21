$targetFunction = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
  $labName = "TestLab"
  $azureLocation = "UKSouth"
  Mock Get-AzureRmResourceGroup {[PSCustomObject] @{ResourceGroupName = $LabName; Tags = @{AutoLab = $LabName}}} -ModuleName AzureLab
  Mock New-AzureRmStorageAccount {} -ModuleName AzureLab
  Mock Write-Warning {} -ModuleName AzureLab
  Mock Get-AzureRmStorageAccountNameAvailability {[PSCustomObject]@{NameAvailable = $true}} -ModuleName AzureLab
  Mock Find-AzureRmResource {} -ModuleName AzureLab
  Mock Read-Host {"y"} -ModuleName AzureLab

  It "[Execution: ] Should create a storage account when one doesn't exist" {
    _NewStorageAccount -LabName $labName -AzureLocation $azureLocation
    Assert-MockCalled New-AzureRmStorageAccount -ModuleName AzureLab -Times 1
  }

  Mock Find-AzureRmResource {[PSCustomObject] @{ResourceGroupName = $LabName}} -ModuleName AzureLab
  It "[Execution: ] Should throw if the storage account exists without correct tags" {
    {_NewStorageAccount -LabName $labName -AzureLocation $azureLocation} |
     Should throw "A storage account for TestLab already exists, but does not have the appropriate AutoLab tag."
  }

  Mock Find-AzureRmResource {[PSCustomObject] @{ResourceGroupName = $LabName; Tags = @{AutoLab = $LabName}}} -ModuleName AzureLab
  It "[Execution: ] Should NOT create a storage account when one DOES exist" {
    _NewStorageAccount -LabName $labName -AzureLocation $azureLocation
    Assert-MockCalled New-AzureRmStorageAccount -ModuleName AzureLab -Times 1
  }

  It "[Execution: ] Should Warn if storage account with the correct tags already exists" {
      _NewStorageAccount -LabName $labName -AzureLocation $azureLocation
      Assert-MockCalled Write-Warning -ModuleName AzureLab -Times 1
  }
}

<#
Describe "Private function $targetFunction Integration Tests" -Tag Integration {
  It -Pending "[Execution: ] Should create storage account with the proper tags"
  It -Pending "[Execution: ] Should create the storage account in the correct Azure region"
}
#>