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

    DynamicParam {
    Helper_DynamicParamAzureLocation
  }

  End {
    # Create Automation Account if it does not exist
    Helper_NewAutomationAccount

    # Upload DSC config files

    # Return object detailing end state of automation config
  }
}

Function Remove-AzureLabAutomation {

}

Function Helper_NewBlockStorage {

}

Function Helper_UpDSCloadFiles {

}

Function Helper_NewAutomationAccount {
  [CmdletBinding()]
  param(

  )



  End {
    $automationAccount = Get-AzureRmAutomationAccount -ResourceGroupName $LabName | Where-Object AutomationAccountName -eq "$LabName_AA"
    If ($automationAccount) {
      $automationAccount = $automationAccount | Get-AzureRmAutomationAccount -ResourceGroupName $LabName
        If ($automationAccount.Tags.AutoLab -ne $LabName) {
            Throw "Automation Account $LabName already exists, but does not have correct Tag"
        }
    }
    Else {
      $automationAccount = New-AzureRmAutomationAccount -Name $LabName_AA -Location $Location -ResourceGroupName $LabName -Plan Free -Tags @{AutoLab = $LabName}
    }

    Return $automationAccount
  }
}