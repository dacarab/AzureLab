# Default test variables
$targetFunction = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.ps1', ''
$labName = "PesterTest"
$labType = "Splunk"
$labpassword = ConvertTo-SecureString -String "P@55word" -AsPlainText -Force
$templateParamHash = @{
    ManagementIP = "2.2.2.2"
    LabPassword = $labpassword
}

Describe "Private function $targetFunction Unit Tests" -tag unit {
    Mock New-AzureRmResourceGroupDeployment {"Deployed"} -ModuleName AzureLab

    It "[Execute:   ] Should not throw" {
        {_DeployArmTemplate -LabName $LabName -LabType $LabType -TemplateParamHash $templateParamHash} |
         Should not throw
    }
    It "[Output:    ] Should return the expected data" {
        _DeployArmTemplate -LabName $LabName -LabType $LabType -TemplateParamHash $templateParamHash | 
        Should be "Deployed"
    }
}