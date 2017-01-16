<#
  Remove-AzureLab -LabName 
#>


function Remove-AzureLab {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string]$LabName
  )

  # Get the resource group
  $labRG = Get-AzureRmResourceGroup -Name $LabName

  if ($labRG.Tags.AutoLab -eq $true) {
    Remove-AzureRmResourceGroup -Name $LabName -Force
  }

  
}
