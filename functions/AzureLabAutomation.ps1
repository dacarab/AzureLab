<#
  Function to configure an automation account to configure lab machines, and upload DSC Configs

  Expected Syntax:
  Initialize-AzureLabAutomation -LabName SplunkLab -DSCSourceFolder Folder

#>

Function New-AzureLabAutomation {
  [cmdletbinding()]
  param(
    [string]$LabName,
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$DSCSourceFolder
  )

  # Check if automation account exists.

  # Create Automation Account
  $LabAutomationAccount = New-AzureRmAutomationAccount -Name $LabName -Location $Location -ResourceGroupName $LabName -Plan Free -Tags

  # Upload DSC config files

  # Return object detailing end state of automation config

}

Function Remove-AzureLabAutomation {

}

Function Helper_NewBlockStorage {

}

Function Helper_UploadFiles {

}