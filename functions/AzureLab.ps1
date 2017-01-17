Function New-AzureLab {
  [CmdletBinding()]
  param(
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]")]
    [string]$LabName,
    [Parameter(Mandatory)]
    [securestring]$LabPassword
  )
    # Block to ensure only valid AzureLocations are selected
    DynamicParam {
      Helper_DynamicParamAzureLocation
    }

    Begin {}

    Process {}

    End {
      # TODO: Set-up the relevant parameters to pass to the template
      $deploymentHash = @{
        labPassword = $LabPassword
      }
      # Create ResourceGroup if required
      If (!(Get-AzureRmResourceGroup -Name $LabName)) {
        $LabResourceGroup = New-AzureRmResourceGroup -Name $LabName -Location $AzureLocation
      }
      # Deploy the template
      New-AzureRmResourceGroupDeployment -ResourceGroupName $LabName -TemplateParameterObject $deploymentHash -TemplateFile .\files\SplunkLab.json

      # TODO: Return a PSCustomObject that represents the end state of the objects deployed
  }
}

Function Remove-AzureLab {
  [CmdletBinding()]
  param(
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]")]
    [Parameter(Mandatory)]
    [string]$LabName
  )

  # Get the resource group
  $labRG = Get-AzureRmResourceGroup -Name $LabName

  if ($labRG.Tags.AutoLab -eq $true) {
    Remove-AzureRmResourceGroup -Name $LabName -Force
  }

  
}
