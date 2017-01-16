function New-AzureLab {
  [CmdletBinding()]
  param(
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]{1,61}")]
    [string]$LabName,
    [string]$AzureLocation,
    [Parameter(Mandatory)]
    [securestring]$LabPassword
  )
  # TODO: Set-up the relevant parameters to pass to the template
  $deploymentHash = @{
    labPassword = $LabPassword
  }
  # Create ResourceGroup if required
  $LabResourceGroup = New-AzureRmResourceGroup -Name "$LabName" -Location $AzureLocation -Tag @{AutoLab=$true}

  # Deploy the template
  New-AzureRmResourceGroupDeployment -ResourceGroupName $LabResourceGroup.ResourceGroupName -TemplateParameterObject $deploymentHash -TemplateFile .\files\SplunkLab.json

  # TODO: Return a PSCustomObject that represents the end state of the objects deployed

}

