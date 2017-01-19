$newLab_Input_TestCases_Fail = @(
  @{
    Scenario = "LabName - does not accept input longer than 61 chars"
    Error = "Cannot validate argument on parameter 'LabName'"
    labName = "62626262626262626262626262626262626262626262626262626262626262"
    labtype = "Splunk"
    AzureLocation = "UKSouth"
    LabPassword = $password
  },
    @{
    Scenario = "AzureLocation - does not accept missing parameter"
    Error = ""
    labName = "TestLab"
    labtype = "Splunk"
    AzureLocation = $Null
    LabPassword = $password
  },
  @{
    Scenario = "AzureLocation - does not accept non-existent Azure regions"
    Error = "Cannot validate argument on parameter 'AzureLocation'."
    labName = "TestLab"
    labtype = "Splunk"
    AzureLocation = "NonExistentAzureLocation"
    LabPassword = $password
  },
  @{
    Scenario = "LabType - does not accept missing parameter"
    Error = "Cannot validate argument on parameter 'AzureLocation'."
    labName = "TestLab"
    labtype = $Null
    AzureLocation = "UKSouth"
    LabPassword = $password
    },
  @{
    Scenario = "LabType - does not accept non-existent LabType"
    Error = "Cannot validate argument on parameter 'AzureLocation'."
    labName = "TestLab"
    labtype = "NonExistentLabType"
    AzureLocation = "UKSouth"
    LabPassword = $password
    },
  @{
    Scenario = "LabPassword - does not accept missing parameter"
    Error = "Cannot validate argument on parameter 'AzureLocation'."
    labName = "TestLab"
    labtype = "Splunk"
    AzureLocation = "UKSouth"
    LabPassword = $Null
  },
  @{
    Scenario = "LabPassword - does not accept wrong type"
    Error = "Cannot validate argument on parameter 'AzureLocation'."
    labName = "TestLab"
    labtype = "Splunk"
    AzureLocation = "UKSouth"
    LabPassword = $Null
  }
)

It "Input: <Scenario>" -TestCases $newAzureLabtestCases {
  {New-AzureLab -LabName -LabType -AzureLocation -LabPassword } | Should throw $error
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