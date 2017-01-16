function Initialize-AzureLabAutomation {
<#
  Function to configure an automation account to configure lab machines, and upload DSC Configs

  Expected Syntax:
  Initialize-AzureLabAutomation -LabName SplunkLab -DSCSourceFolder Folder -Location UKSouth

#>
  [cmdletbinding()]
  param(
    [string]$LabName,
    [string]$DSCSourceFolder,
    [string]$Location
  )

  #TODO: Check if automation account exists.

  #Create Automation Account
  $LabAutomationAccount = New-AzureRmAutomationAccount -Name $LabName -Location $Location -ResourceGroupName $LabName -Plan Free 

  #TODO: Upload DSC config files

  #TODO: Return object detailing end state of automation config

}
