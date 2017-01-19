
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
# . "$here\$sut"

Describe "AzureLab Unit Tests" -Tag Unit {
  BeforeAll {Copy-Item "$here\..\files\AzureRmLocations.xml" TestDrive:}

  # Describe block mocks
  Mock -CommandName Get-AzureRmLocation -MockWith {
    $returnData = Import-Clixml -Path "TestDrive:\AzureRmLocations.xml"
    Return $returnData
  } -ModuleName AzureLab

  Mock -CommandName Get-AzureRmResourceGroup -MockWith {
      $true
  } -ModuleName AzureLab

  Mock -CommandName New-AzureRmResourceGroup -MockWith {
    $returnData = @{
      ResourceGroupName = $LabName
      Tags = @{
        AutoLab = $LabName
      }
    }

    Return [PSCustomObject]$returnData
  } -ModuleName AzureLab

  Mock -CommandName New-AzureRmResourceGroupDeployment -MockWith {
    #TODO: Update to better reflect returned object
    Return $true
  } -ModuleName AzureLab
  
  # Describe block Variables
  $labName = "PesterTest"
  $labType = "Splunk"
  $azureLocation = "UKSouth"
  $password = ConvertTo-SecureString "P@55w0rd" -AsPlainText -Force

  Context "New-AzureLab Tests" {
    # TestCases
    $inputTestCases_Fail = @(
      @{
        scenario = "LabName - does not accept input longer than 61 chars"
        expected = "Cannot validate argument on parameter 'LabName'. The character length of the 62 argument is too long"
        labName = "62626262626262626262626262626262626262626262626262626262626262"
        labType = "Splunk"
        azureLocation = "UKSouth"
        labPassword = $password
        shouldBlock = {}
      },
      @{
        scenario = "LabName - does not accept input with a $ sign"
        expected = "Cannot validate argument on parameter 'LabName'. The argument `"`" does not match the `"[a-zA-Z0-9_-]`" pattern."
        labName = "$ShouldNotBeValid"
        labType = "Splunk"
        azureLocation = "UKSouth"
        labPassword = $password
        shouldBlock = {}
      },      
      @{
        scenario = "AzureLocation - does not accept missing parameter"
        expected = "Cannot validate argument on parameter 'AzureLocation'. The argument is null"
        labName = "TestLab"
        labType = "Splunk"
        azureLocation = $Null
        labPassword = $password
      },
      @{
        scenario = "AzureLocation - does not accept non-existent Azure regions"
        expected = "Cannot validate argument on parameter 'AzureLocation'. The argument `"NonExistentAzureLocation`" does not belong"
        labName = "TestLab"
        labType = "Splunk"
        azureLocation = "NonExistentAzureLocation"
        labPassword = $password
      },
      @{
        scenario = "LabType - does not accept missing parameter"
        expected = "Cannot validate argument on parameter 'LabType'. The argument `"`" does not belong to the set `"Splunk`""
        labName = "TestLab"
        #labType = $Null
        azureLocation = "UKSouth"
        labPassword = $password
        },
      @{
        scenario = "LabType - does not accept non-existent LabType"
        expected = "Cannot validate argument on parameter 'LabType'. The argument `"NonExistentLabType`" does not belong"
        labName = "TestLab"
        labType = "NonExistentLabType"
        azureLocation = "UKSouth"
        labPassword = $password
        },
      @{
        scenario = "LabPassword - does not accept missing parameter"
        expected = "Cannot bind argument to parameter 'LabPassword' because it is null."
        labName = "TestLab"
        labType = "Splunk"
        ezureLocation = "UKSouth"
        labPassword = $Null
      },
      @{
        scenario = "LabPassword - does not accept wrong type"
        expected = "Cannot process argument transformation on parameter 'LabPassword'. Cannot convert the `"AStringPassword`" value of type `"System.String`" to type `"System.Security.SecureString`"."
        labName = "TestLab"
        labType = "Splunk"
        azureLocation = "UKSouth"
        labPassword = "AStringPassword"
      }
    )

    $inputTestCases_Pass = @(
      @{
        scenario = "LabName - accepts input with hyphens and underscores"
        labName = "_Underscores-and-Hyphens_"
        labType = "Splunk"
        azureLocation = "UKSouth"
        labPassword = $password
      }
    )

    # INPUT TESTS
    It "[Input:     ] Should Fail: <scenario>" -TestCases $inputTestCases_Fail {
      param ($labName, $labType, $azureLocation, $labPassword, $expected)
      {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $labPassword} | Should throw $expected
    }

    It "[Input:     ] Should Pass: <scenario>" -TestCases $inputTestCases_Pass {
      param ($labName, $labType, $azureLocation, $labPassword)
      {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $labPassword} | Should not throw 
    }      

    # EXECUTION TESTS
    It "[Execution: ] - Does not re-create ResourceGroup if already exists" {
      $returned = New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $password
      $($returned.RGCreated) | Should be $false
    }

    It "[Execution: ] - Creates the required ResourceGroup if it does not exist" {
        Mock -CommandName Get-AzureRmResourceGroup -MockWith {
            $false
        } -ModuleName AzureLab

        $returned = New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $password 
        $($returned.RGCreated) | Should be $true
    }        

    # OUTPUT TESTS
    It -Pending "Output - Returns the proper type"

  }

  Context "Remove-AzureLab Tests" {
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
  } -ModuleName AzureLab

  Mock -CommandName Remove-AzureRmResourceGroup -Verifiable -MockWith {
    Return $true
  } -ParameterFilter {$LabName -eq $LabName}

    It "Input - accepts valid input for LabName: <TestScenario>" -TestCases $labNameCases {
      {New-AzureLab -LabName $testLabName -AzureLocation $azureLocation -LabPassword $password} |
        should throw "Cannot validate argument on parameter"
    }

    It "Execution - should remove a specified Resource Group" {
        $returnData = @{
            ResourceGroupName = $LabName
            Tags = @{
                AutoLab = $LabName
            }
        }
        Remove-AzureLab -LabName $LabName
        Assert-MockCalled Remove-AzureRmResourceGroup -Times 1
    }

    It "Execution - should throw if the specified Resource Group does not exist" {
        $LabName = "DoesNotExist"
        $returnData = $null
        {Remove-AzureLab -LabName $LabName} |
          Should throw "Cannot remove Resource Group $LabName - it does not exist."
    }
    
    It "Execution - should throw if specified Resource Group does not have appropriate tag 'AutoLab'" {
        $returnData = @{
                ResourceGroupName = $LabName
                Tags = @{}
        }
        {Remove-AzureLab -LabName $LabName} |
            Should throw "Cannot remove Resource Group $LabName - does not have the correct tag, 'AutoLab'."
    }

    It "Output - Returns $false if ResourceGroup does exist after remove attempt" {
    Remove-AzureLab -LabName $LabName | Should be $false
      Assert-VerifiableMocks
    }

    It "Output - should return $true if ResourceGroup does not exist after remove attempted" {
      Mock -CommandName Get-AzureRmResourceGroup -MockWith {
        Return $Null
      } -ParameterFilter {$Name -and $Name -eq $LabName} -ModuleName AzureLab
      Remove-AzureLab -LabName "$LabName" | Should Be $true
    }
  }
}

Describe "Azure Lab Integration Tests" -Tag Integration {

}