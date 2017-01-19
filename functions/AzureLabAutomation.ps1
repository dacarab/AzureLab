<#
  Function to configure an automation account to configure lab machines, and upload DSC Configs

  Expected Syntax:
  Initialize-AzureLabAutomation -LabName SplunkLab -DSCSourceFolder Folder

#>
# Public Functions
Function New-AzureLabAutomation {
  [cmdletbinding()]
  param(
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]")]
    [string]$LabName,
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$DSCSourceFolder
  )

    DynamicParam {
    Helper_DynamicParamAzureLocation
  }

  End {
    # Create Automation Account if it does not exist
    Helper_NewAutomationAccount -LabName $LabName -AzureLocation $AzureLocation -DSCSourceFolder $DSCSourceFolder

    # Upload DSC config files

    # Return object detailing end state of automation config
  }
}

Function Remove-AzureLabAutomation {

}

# Helper Functions
Function Helper_NewAutomationAccount {
  [CmdletBinding()]
  param(
    [string]$LabName,
    [string]$DSCSourceFolder,
    [string]$AzureLocation
  )
  $automationAccount = Get-AzureRmAutomationAccount -ResourceGroupName $LabName | Where-Object AutomationAccountName -eq "$LabName_AA"
  If ($automationAccount) {
    $automationAccount = $automationAccount | Get-AzureRmAutomationAccount -ResourceGroupName $LabName
      If ($automationAccount.Tags.AutoLab -ne $LabName) {
          Throw "Automation Account $LabName already exists, but does not have correct Tag"
      }
  }
  Else {
    $automationAccount = New-AzureRmAutomationAccount -Name $LabName_AA -Location $AzureLocation -ResourceGroupName $LabName -Plan Free -Tags @{AutoLab = $LabName}
  }

  Return $automationAccount
}

Function Helper_NewBlockStorage {

}

Function Helper_UpDSCloadFiles {

}
