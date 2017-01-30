begin {
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}

    # Default test variables
    $labName = "PesterTest"
    $labType = "Splunk"
    $azureLocation = "UKSouth"
    $labPassword = ConvertTo-SecureString "P@55w0rd" -AsPlainText -Force
    $failInputTest = @(
        @{
        scenario = "LabName - does not accept input longer than 61 chars"
        expected = "Cannot validate argument on parameter 'LabName'. The character length of the 62 argument is too long"
        labName = "62626262626262626262626262626262626262626262626262626262626262"
        labType = "Splunk"
        azureLocation = "UKSouth"
        labPassword = $labPassword
        shouldBlock = {}
        },
        @{
        scenario = "LabName - does not accept input with a $ sign"
        expected = "Cannot validate argument on parameter 'LabName'. The argument `"`" does not match the `"[a-zA-Z0-9_-]`" pattern."
        labName = "$ShouldNotBeValid"
        labType = "Splunk"
        azureLocation = "UKSouth"
        labPassword = $labPassword
        shouldBlock = {}
        },      
        @{
        scenario = "AzureLocation - does not accept missing parameter"
        expected = "Cannot validate argument on parameter 'AzureLocation'. The argument is null"
        labName = "TestLab"
        labType = "Splunk"
        azureLocation = $Null
        labPassword = $labPassword
        },
        @{
        scenario = "AzureLocation - does not accept non-existent Azure regions"
        expected = "Cannot validate argument on parameter 'AzureLocation'. The argument `"NonExistentAzureLocation`" does not belong"
        labName = "TestLab"
        labType = "Splunk"
        azureLocation = "NonExistentAzureLocation"
        labPassword = $labPassword
        },
        @{
        scenario = "LabType - does not accept missing parameter"
        expected = "Cannot validate argument on parameter 'LabType'. The argument `"`" does not belong to the set `"Splunk`""
        labName = "TestLab"
        #labType = $Null
        azureLocation = "UKSouth"
        labPassword = $labPassword
        },
        @{
        scenario = "LabType - does not accept non-existent LabType"
        expected = "Cannot validate argument on parameter 'LabType'. The argument `"NonExistentLabType`" does not belong"
        labName = "TestLab"
        labType = "NonExistentLabType"
        azureLocation = "UKSouth"
        labPassword = $labPassword
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
    $passInputTest = @(
        @{
        scenario = "LabName - accepts input with hyphens and underscores"
        labName = "_Underscores-and-Hyphens_"
        labType = "Splunk"
        azureLocation = "UKSouth"
        labPassword = $labPassword
        }
    )
}

end {
    Describe "New-AzureLab Unit Tests" -Tag Unit {
    BeforeAll {Copy-Item "$here\..\files\AzureRmLocations.xml" TestDrive:}

    # Mocks 
    Mock _NewResourceGroup {}
    Mock _NewStorageAccount {@{StorageAccountName = "SomeStorageAccount"}}
    Mock _GetStorageAccountContext {}
    Mock _UploadLabFiles {@{File1 = @{uri = "www"; SasKey = "SomeSasKey"}}}
    Mock _GenerateTemplateParamHash {}
    Mock _DeployArmTemplate {}
    Mock _EnsureConnected {}
    Mock _GetRealIP {"3.3.3.3"}
    Mock Get-AzureRmLocation {[PSCustomObject]@{Location = "UKSouth"}} 

    It "[Input:     ] Should Fail: <scenario>" -TestCases $failInputTest {
        param ($labName, $labType, $azureLocation, $labPassword, $expected)
        {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $labPassword} | Should throw $expected
    }

    It "[Input:     ] Should Pass: <scenario>" -TestCases $passInputTest {
        param ($labName, $labType, $azureLocation, $labPassword)
        Mock  Get-AzureRmResourceGroup  {$false}
        Mock  New-AzureRmResourceGroupDeployment  {$true}
        Mock  New-AzureRmResourceGroup  {[PSCustomObject]@{ResourceGroupName = $LabName; Tags = @{AutoLab = $LabName;}}}
        {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $labPassword} |
        Should not throw 
    }      

    It "[Execution: ] Does not throw when provided example parameters" {
        {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $labPassword} |
        Should not throw
    }

    It -Pending "Output - Returns the proper type"

    } # Describe New-AzureLab
}