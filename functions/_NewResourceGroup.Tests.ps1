$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}
$targetFunction = $sut -replace '\.ps1', ''

Describe "Private function $targetFunction Unit Tests" -tag unit {
  $labName = "TestLab"
  $azureLocation = "UKSouth"
  $labType = "Splunk"

  Mock -CommandName New-AzureRmResourceGroup -MockWith {
    $returnData = @{
      ResourceGroupName = $LabName
      Tags = @{
        AutoLab = $LabName
      }
    }
    Return [PSCustomObject]$returnData
  } 

  Mock -CommandName Get-AzureRmResourceGroup -MockWith {
    $returnData = @{
      ResourceGroupName = $LabName
      Tags = @{
        AutoLab = $LabName
      }
    }
    Return [PSCustomObject]$returnData
  }

  Mock Read-Host {"y"}

  Mock -CommandName Write-Warning -MockWith {
    # Do nothing
  }

  It  "[Execution: ] Should not create a resource group if one already exists" {
    _NewResourceGroup -LabName $labName -AzureLocation $azureLocation -LabType $labType
    Assert-MockCalled New-AzureRmResourceGroup  -Times 0
  }

  Mock -CommandName Get-AzureRmResourceGroup -MockWith {
    Return $Null
  }

  It  "[Execution: ] Should create a resource group if one does not exist" {
    _NewResourceGroup -LabName $labName -AzureLocation $azureLocation -LabType $labType
    Assert-MockCalled New-AzureRmResourceGroup  -Times 1
  }

  Mock -CommandName Get-AzureRmResourceGroup -MockWith {
    $returnData = @{
      ResourceGroupName = $LabName
      Tags = @{}
    }
    Return [PSCustomObject]$returnData
  }
  
  It  "[Execution: ] Should throw if a resource group exists without appropriate tags" {
    {_NewResourceGroup -LabName $labName -AzureLocation $azureLocation -LabType $labType} |
     Should throw "The underpinning resource group for TestLab already exists, but does not have the appropriate AutoLab tag."
  }

  Mock -CommandName Read-Host -MockWith {
    Return "n"
  }

  Mock -CommandName Get-AzureRmResourceGroup -MockWith {
    $returnData = @{
      ResourceGroupName = $LabName
      Tags = @{
        AutoLab = $LabName
      }
    }
    Return [PSCustomObject]$returnData
  }

  It  "[Execution: ] Should throw if the user chooses not to proceed when resource group with appropriate tags exists" { 
    {_NewResourceGroup -LabName $labName -AzureLocation $azureLocation -LabType $labType} |
     Should throw "Lab creation terminated by user. Try using a different LabName." 
  }

  Mock -CommandName Get-AzureRmResourceGroup -MockWith {
    Return $Null
  }

  It  "[Output:    ] Should output state of resource group" {
    $returned = _NewResourceGroup -LabName $labName -AzureLocation $azureLocation -LabType $labType 
    $($returned.ResourceGroupName) | Should Be $labName
    $($returned.Tags.AutoLab) | Should Be $labname
  }
}

<#Describe "Private function $targetFunction Integration Tests" -tag unit {
  It -Pending "[Execution: ] Should create resource group with the correct tags"
  It -Pending "[Execution: ] Should create the storage account in the correct Azure region"
}#>

