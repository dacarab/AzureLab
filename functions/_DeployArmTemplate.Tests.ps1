begin {
    # Default test variables
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
    get-childitem $PSScriptRoot -Exclude "*tests*" | ForEach-Object {. $_.FullName}
    $targetFunction = $sut -replace '\.ps1', ''
    $labName = "PesterTest"
    $labType = "Splunk"
    $labpassword = ConvertTo-SecureString -String "P@55word" -AsPlainText -Force
    $templateParamHash = @{
        ManagementIP = "2.2.2.2"
        LabPassword = $labpassword
    }
    $LabTemplatePath = "$PSScriptRoot\files\LabFiles"
    $Labs = @{
        Splunk = @{
            LabType = "Splunk"
            TemplatePath = "$LabTemplatePath\Splunk\Splunk.json"
        }
    }
}

end {
    Describe "Private function $targetFunction Unit Tests" -tag unit {
        Mock New-AzureRmResourceGroupDeployment {"Deployed"} 

        It "[Execute:   ] Should not throw" {
            {_DeployArmTemplate -LabName $LabName -LabType $LabType -TemplateParamHash $templateParamHash} |
            Should not throw
        }
        It "[Output:    ] Should return the expected data" {
            _DeployArmTemplate -LabName $LabName -LabType $LabType -TemplateParamHash $templateParamHash | 
            Should be "Deployed"
        }
    }
}

