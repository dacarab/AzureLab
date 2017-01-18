$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"



Describe "Remove-AzureLab" {

  # Describe Block Variables
  $LabName = "RemoveLabTest"


  # Remove-AzureLab Describe Block Mocks
  Mock -CommandName Get-AzureRmResourceGroup -MockWith {
    $returnData = @{
      ResourceGroupName = "RemoveLabTest"
      Tags = @{
        AutoLab = "RemoveLabTest"
      }
    } 
    Return [PSCustomObject]$returnData
  }

  Mock -CommandName Remove-AzureRmResourceGroup -Verifiable -MockWith {
    Return $true
  } -ParameterFilter {$Name -and $Name -eq $LabName}

  Context Output {
    It "Returns $false if ResourceGroup does exist after remove attempt" {
    Remove-AzureLab -LabName $LabName | Should be $false
      Assert-VerifiableMocks
    }

    It "should return $true if ResourceGroup does not exist after remove attempted" {
      Mock -CommandName Get-AzureRmResourceGroup -MockWith {
        Return $Null
      } -ParameterFilter {$Name -and $Name -eq $LabName} 
      Remove-AzureLab -LabName "$LabName" | Should Be $true
    }
  }
}