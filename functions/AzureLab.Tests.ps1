
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
    $returnData = @{
      ResourceGroupName = $LabName
      Tags = @{
        AutoLab = $LabName
      }
    }
    Return [PSCustomObject]$returnData
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
  
  Mock -CommandName Remove-AzureRmResourceGroup -MockWith {
    Return $true
  } -ModuleName AzureLab

  Mock -CommandName _EnsureConnected -MockWith {
    #TODO: Simulate return data properly
    Return $true
  } -ModuleName AzureLab
  
  # Describe block variables
  $labName = "PesterTest"
  $labType = "Splunk"
  $azureLocation = "UKSouth"
  $password = ConvertTo-SecureString "P@55w0rd" -AsPlainText -Force

  Context "New-AzureLab Tests" {
    # Context block testcases
    $newAzureLab_inputTestCases_Fail = @(
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

    $newAzureLab_inputTestCases_Pass = @(
      @{
        scenario = "LabName - accepts input with hyphens and underscores"
        labName = "_Underscores-and-Hyphens_"
        labType = "Splunk"
        azureLocation = "UKSouth"
        labPassword = $password
      }
    )

    # New-AzureLab input tests
    It "[Input:     ] Should Fail: <scenario>" -TestCases $newAzureLab_inputTestCases_Fail {
      param ($labName, $labType, $azureLocation, $labPassword, $expected)
      {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $labPassword} | Should throw $expected
    }

    It "[Input:     ] Should Pass: <scenario>" -TestCases $newAzureLab_inputTestCases_Pass {
      param ($labName, $labType, $azureLocation, $labPassword)
      {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $labPassword} | Should not throw 
    }      

    # New-AzureLab execution tests
    It "[Execution: ] Does not re-create ResourceGroup if already exists" {
      $returned = New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $password
      $($returned.RGCreated) | Should be $false
    }

    It "[Execution: ] Creates the required ResourceGroup if it does not exist" {
        Mock -CommandName Get-AzureRmResourceGroup -MockWith {
            $false
        } -ModuleName AzureLab

        $returned = New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $password 
        $($returned.RGCreated) | Should be $true
    }        

    # New-AzureLab output tests
    It -Pending "Output - Returns the proper type"

  } # Context

  Context "Remove-AzureLab Tests" {
    # Context block TestCases
    $removeAzureLab_inputTestCases_Fail = @(
      @{
        scenario = "LabName - does not accept input longer than 61 chars"
        expected = "Cannot validate argument on parameter 'LabName'. The character length of the 62 argument is too long"
        labName = "62626262626262626262626262626262626262626262626262626262626262"
      },
      @{
        scenario = "LabName - does not accept input with a $ sign"
        expected = "Cannot validate argument on parameter 'LabName'. The argument `"`" does not match the `"[a-zA-Z0-9_-]`" pattern."
        labName = "$ShouldNotBeValid"
      }
    )

    $removeAzureLab_inputTestCases_Pass = @(
      @{
        scenario = "LabName - accepts input with hyphens and underscores"
        labName = "_Underscores-and-Hyphens_"
      }
    )

    # INPUT TESTS
    It "[Input:     ] Should Fail: <scenario>" -TestCases $removeAzureLab_inputTestCases_Fail {
      param ($labName, $labType, $azureLocation, $labPassword, $expected)
      {Remove-AzureLab -LabName $labName} | Should throw $expected
    }

    It "[Input:     ] Should Pass: <scenario>" -TestCases $removeAzureLab_inputTestCases_Pass {
      param ($labName, $labType, $azureLocation, $labPassword)
      {Remove-AzureLab -LabName $labName} | Should not throw 
    }

    # EXECUTION TESTS
    It "[Execution: ] Should throw if the specified Resource Group does not exist" {
      Mock -CommandName Get-AzureRmResourceGroup -MockWith {
        Return $Null
      } -ModuleName AzureLab
      {Remove-AzureLab -LabName $labName} |
        Should throw "Cannot remove Resource Group $labName - it does not exist."
    }

    It "[Execution: ] Should throw if specified Resource Group does not have appropriate tag 'AutoLab'" {
      Mock -CommandName Get-AzureRmResourceGroup -MockWith {
        $returnData = @{
          ResourceGroupName = $LabName
          Tags = @{}
        }
        Return [PSCustomObject]$returnData
      } -ModuleName AzureLab
      {Remove-AzureLab -LabName $labName} |
       Should throw "Cannot remove Resource Group $labName - does not have the correct tag, 'AutoLab'."
    }

    # OUTPUT TESTS
    It "[Output:    ] Returns $false if ResourceGroup does exist after remove attempt" {
      Mock -CommandName Get-AzureRmResourceGroup -MockWith {
        $returnData = @{
          ResourceGroupName = $LabName
          Tags = @{
            AutoLab = $LabName
          }
        }
        Return [PSCustomObject]$returnData
      } -ModuleName AzureLab

      Mock -CommandName Remove-AzureRmResourceGroup -MockWith {
        Return $false
      } -ModuleName AzureLab

      Remove-AzureLab -LabName $labName | Should be $false
    }
  }
}

Describe "Azure Lab Integration Tests" -Tag Integration {
  It -Pending "Execution - should remove  specified Resource Group" {
    Remove-AzureLab -LabName $labName -verbose | Should be $true
  }

  It -Pending "Output - should return $true if ResourceGroup does not exist after remove attempted" {
    Mock -CommandName Get-AzureRmResourceGroup -MockWith {
      Return $Null
    } -ParameterFilter {$Name -and $Name -eq $LabName} -ModuleName AzureLab
    Remove-AzureLab -LabName "$labName" | Should Be $true
  }
}