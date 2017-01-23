begin {
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}

    # Default test variables
    $labName = "PesterTest"
    $labType = "Splunk"
    $azureLocation = "UKSouth"
    $password = ConvertTo-SecureString "P@55w0rd" -AsPlainText -Force
    $failInputTest = @(
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
    $passInputTest = @(
        @{
        scenario = "LabName - accepts input with hyphens and underscores"
        labName = "_Underscores-and-Hyphens_"
        labType = "Splunk"
        azureLocation = "UKSouth"
        labPassword = $password
        }
    )
}

end {
    Describe "New-AzureLab Unit Tests" -Tag Unit {
    BeforeAll {Copy-Item "$here\..\files\AzureRmLocations.xml" TestDrive:}

    # Mocks 
    Mock _NewResourceGroup {} -AzureLab
    Mock _NewStorageAccount {} -AzureLab
    Mock _GetStorageAccountContext {} -AzureLab
    Mock _UploadLabFiles {} -AzureLab
    Mock _GenerateTemplateParamHash {} -AzureLab
    Mock _DeployArmTemplate {} -AzureLab
    #Mock _DynamicParamAzureLocation {} -AzureLab
    Mock _GetRealIP {} -AzureLab

    # New-AzureLab input tests
    It "[Input:     ] Should Fail: <scenario>" -TestCases $failInputTest {
        param ($labName, $labType, $azureLocation, $labPassword, $expected)
        {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $labPassword} | Should throw $expected
    }

    It "[Input:     ] Should Pass: <scenario>" -TestCases $passInputTest {
        param ($labName, $labType, $azureLocation, $labPassword)
        Mock  Get-AzureRmResourceGroup  {$false} -ModuleName AzureLab
        Mock  New-AzureRmResourceGroupDeployment  {$true} -ModuleName AzureLab
        Mock  New-AzureRmResourceGroup  {[PSCustomObject]@{ResourceGroupName = $LabName; Tags = @{AutoLab = $LabName;}}} -ModuleName AzureLab
        {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $labPassword} |
        Should not throw 
    }      

    # New-AzureLab execution tests
    It "[Execution: ] Does not throw when provided example parameters" {
        {New-AzureLab -LabName $labName -LabType $labType -AzureLocation $azureLocation -LabPassword $password} |
        Should not throw
    }

    # New-AzureLab output tests
    It -Pending "Output - Returns the proper type"

    } # Describe New-AzureLab
}