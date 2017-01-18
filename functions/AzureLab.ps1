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
  Write-Verbose "Checking ResourceGroup Exists:"
  $labRG = Get-AzureRmResourceGroup | Where-Object ResourceGroupName -eq $LabName
  Write-Verbose "Get          AzureRmResourceGroup returns $labRg"
  If ($labRG) {
    if ($labRG.Tags.AutoLab -eq $LabName) {
      Write-Verbose "Remove         AzureRMResourceGroup $LabName"
      Remove-AzureRmResourceGroup -Name $LabName -Force | Out-Null
    }
    Else {
      Throw "Cannot remove Resource Group $LabName - does not have the correct tag, 'AutoLab'."
    }
  }
  Else {
    Throw "Cannot remove Resource Group $LabName - it does not exist."
  }

  # Adding ErrorAction param to enable targeted mocking in Pester tests
  Write-Verbose "Checking Resource Group Removed:"
  $r = Get-AzureRmResourceGroup -Name $LabName
  Write-Debug "`$r = $r"
  if (!($r)) {
    Write-Verbose "Get          AzureRmResourceGroup $Labname returns nothing"
    Return $true
  }
  Else {
    Write-Verbose "Get          AzureRmResourceGroup $Labname returns $r"
    Return $false
  }
}
