$newLab_Input_TestCases_Fail = @(
  @{
    scenario = "LabName - does not accept input longer than 61 chars"
    expected = "Cannot validate argument on parameter 'LabName'"
    labName = "62626262626262626262626262626262626262626262626262626262626262"
    labtype = "Splunk"
    azureLocation = "UKSouth"
    labPassword = $password
  },
    @{
    scenario = "AzureLocation - does not accept missing parameter"
    expected = ""
    labName = "TestLab"
    labtype = "Splunk"
    azureLocation = $Null
    labPassword = $password
  },
  @{
    scenario = "AzureLocation - does not accept non-existent Azure regions"
    expected = "Cannot validate argument on parameter 'AzureLocation'."
    labName = "TestLab"
    labtype = "Splunk"
    azureLocation = "NonExistentAzureLocation"
    labPassword = $password
  },
  @{
    scenario = "LabType - does not accept missing parameter"
    expected = "Cannot validate argument on parameter 'AzureLocation'."
    labName = "TestLab"
    labtype = $Null
    azureLocation = "UKSouth"
    labPassword = $password
    },
  @{
    scenario = "LabType - does not accept non-existent LabType"
    expected = "Cannot validate argument on parameter 'AzureLocation'."
    labName = "TestLab"
    labtype = "NonExistentLabType"
    azureLocation = "UKSouth"
    labPassword = $password
    },
  @{
    scenario = "LabPassword - does not accept missing parameter"
    expected = "Cannot validate argument on parameter 'AzureLocation'."
    labName = "TestLab"
    labtype = "Splunk"
    ezureLocation = "UKSouth"
    labPassword = $Null
  },
  @{
    scenario = "LabPassword - does not accept wrong type"
    expected = "Cannot validate argument on parameter 'AzureLocation'."
    labName = "TestLab"
    labtype = "Splunk"
    azureLocation = "UKSouth"
    labPassword = $Null
  }
)

It "Input: <Scenario>" -TestCases $newAzureLabtestCases {
  {New-AzureLab -LabName -LabType -AzureLocation -LabPassword } | Should throw $expected
}

$newLab_Input_TestCases_Pass = @(
  @{
      Scenario = "AzureLocation - accepts existing Azure regions"
      labName = "TestLab"
      labtype = "Splunk"
      AzureLocation = "UKSouth"
      LabPassword = $password
    },
  @{
      Scenario = "AzureLocation - accepts existing Azure regions"
      labName = "TestLab"
      labtype = "Splunk"
      AzureLocation = "UKSouth"
      LabPassword = $password
    }
)