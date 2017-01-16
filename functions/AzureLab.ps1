function New-AzureLab {
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
      $locations = Get-AzureRmLocation | Select-Object -ExpandProperty Location

      $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

      $paramAttributes = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
      $paramAttributes.Add((New-Object Parameter))
      $paramAttributes.Add((New-Object ValidateSet $locations))
      
      $parameterName = "AzureLocation"
      $paramDictionary[$parameterName] = New-Object System.Management.Automation.RuntimeDefinedParameter ($parameterName, [string[]], $paramAttributes)

      Return $paramDictionary
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
        $LabResourceGroup = New-AzureRmResourceGroup -Name "$LabName" -Location $AzureLocation
      }
      # Deploy the template
      New-AzureRmResourceGroupDeployment -ResourceGroupName $LabResourceGroup.ResourceGroupName -TemplateParameterObject $deploymentHash -TemplateFile .\files\SplunkLab.json

      # TODO: Return a PSCustomObject that represents the end state of the objects deployed
  }
}


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
