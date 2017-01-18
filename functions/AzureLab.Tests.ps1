$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "New-AzureLab" {

    # Parameter Variables
    $labName = "PesterTest"
    $azureLocation = "UKSouth"
    $password = ConvertTo-SecureString "P@55w0rd" -AsPlainText -Force

    # Mocks
    Mock -CommandName New-AzureRmResourceGroupDeployment  -MockWith {
        #TODO - Return data
    } 
    Mock -CommandName New-AzureRmResourceGroup -Verifiable -MockWith {
        #TODO - Return Data
    } 

    Context "Input" {
        # TestCases
        $labNameCases = @(
            @{
                testLabName = "61616161616161616161616161616161616161616161616161616161616161"
                TestScenario = "throws if input longer than 61 characters"
            },
            @{
                testLabName = '$Wibbler'
                TestScenario = "throws if input contains a $ sign"
            }
        )

        # Parameter Variables
        $badAzureLocation = "Biggleswade"

        It "accepts valid input for LabName: <TestScenario>" -TestCases $labNameCases {
            {New-AzureLab -LabName $testLabName -AzureLocation $azureLocation -LabPassword $password} |
                should throw "Cannot validate argument on parameter"
        }

        It "accepts existing Azure regions as input for AzureLocation" {
            {New-AzureLab -LabName $labName -AzureLocation $badAzureLocation -LabPassword $password} |
                should throw "Cannot validate argument on parameter"
        }

        It "does not accept invalid Azure regions as input for AzureLocation" {
            {New-AzureLab -LabName $labName -AzureLocation $badAzureLocation -LabPassword $password} |
                should throw "Cannot validate argument on parameter"
        }
    }

    Context Execution {
        It "Does not re-create ResourceGroup if already exists" {
            Mock -CommandName Get-AzureRmResourceGroup -Verifiable -MockWith {
                $true
            }
            New-AzureLab -LabName $labName -AzureLocation $azureLocation -LabPassword $password
            Assert-MockCalled New-AzureRmResourceGroup -times 0
        }

        It "Creates the required ResourceGroup if it does not exist" {
            Mock -CommandName Get-AzureRmResourceGroup -Verifiable -MockWith {
                $false
            }
            New-AzureLab -LabName $labName -AzureLocation $azureLocation -LabPassword $password
            Assert-MockCalled New-AzureRmResourceGroup -Times 1
        }        
    }

    Context Output {
        It -Pending "Returns the proper type"

    }
}

Describe "Remove-AzureLab" {
  # TestCases
  $labNameCases = @(
      @{
          testLabName = "61616161616161616161616161616161616161616161616161616161616161"
          TestScenario = "throws if input longer than 61 characters"
      },
      @{
          testLabName = '$Wibbler'
          TestScenario = "throws if input contains a $ sign"
      }
  )

  # Describe Block Variables
  $LabName = "RemoveLabTest"
  $returnData = @{
    ResourceGroupName = "RemoveLabTest"
    Tags = @{
      AutoLab = "RemoveLabTest"
    }
  }

  # Remove-AzureLab Describe Block Mocks
  Mock -CommandName Get-AzureRmResourceGroup -MockWith {
    Return [PSCustomObject]$returnData
  }

  Mock -CommandName Remove-AzureRmResourceGroup -Verifiable -MockWith {
    Return $true
  } -ParameterFilter {$LabName -eq $LabName}

  Context Input {
    It "accepts valid input for LabName: <TestScenario>" -TestCases $labNameCases {
      {New-AzureLab -LabName $testLabName -AzureLocation $azureLocation -LabPassword $password} |
        should throw "Cannot validate argument on parameter"
    }
  }

  Context Execution {
    It "should remove a specified Resource Group" {
        $returnData = @{
            ResourceGroupName = $LabName
            Tags = @{
                AutoLab = $LabName
            }
        }
        Remove-AzureLab -LabName $LabName
        Assert-MockCalled Remove-AzureRmResourceGroup -Times 1
    }

    It "should throw if the specified Resource Group does not exist" {
        $LabName = "DoesNotExist"
        $returnData = $null
        {Remove-AzureLab -LabName $LabName} |
          Should throw "Cannot remove Resource Group $LabName - it does not exist."
    }
    
    It "should throw if specified Resource Group does not have appropriate tag 'AutoLab'" {
        $returnData = @{
                ResourceGroupName = $LabName
                Tags = @{}
        }
        {Remove-AzureLab -LabName $LabName} |
            Should throw "Cannot remove Resource Group $LabName - does not have the correct tag, 'AutoLab'."
    }
  }

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