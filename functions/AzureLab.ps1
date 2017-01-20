Function New-AzureLab {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]")]
    [string]$LabName,
    [Parameter(Mandatory)]
    [ValidateSet("Splunk")]
    [string]$LabType,
    [Parameter(Mandatory)]
    [securestring]$LabPassword
  )
  # Block to ensure only valid AzureLocations are selected
  DynamicParam {
    Helper_DynamicParamAzureLocation
  }
  End {
    Helper_EnsureConnected
    # Assign AzureLocation dynamic parameter value to $AzureLocation for use in script
    $AzureLocation = $($PSBoundParameters.AzureLocation)

    # Set-up the relevant parameters to pass to the template
    $deploymentHash = @{
      labPassword = $LabPassword
    }

    # Create ResourceGroup if required
    $rgCreated = $false
    Write-Verbose "Get          AzureRmResourceGroup -Name $LabName"
    $returned = Get-AzureRmResourceGroup -Name $LabName -ErrorAction SilentlyContinue
    Write-Verbose "Get          AzureRmResourceGroup returns $returned"
    If (!$returned) {
      Write-Verbose "New          AzureRmResourceGroup -Name $LabName -Location $AzureLocation -Tag @{AutoLab = $LabName}"
      $labResourceGroup = New-AzureRmResourceGroup -Name $LabName -Location $AzureLocation -Tag @{AutoLab = $LabName}
      Write-Verbose "New          AzureRmResourceGroup returns $labResourceGroup"
      If ($labResourceGroup) {
        $rgCreated = $true
      }
    }

    # Deploy the template
    New-AzureRmResourceGroupDeployment -ResourceGroupName $LabName -TemplateParameterObject $deploymentHash -TemplateFile .\files\SplunkLab.json

    # Return a PSCustomObject that represents the end state of the objects deployed
    $returnData = @{
      ResourceGroup = $labResourceGroup
      RGCreated = $rgCreated
    }
    Write-Verbose "Returning $([PSCustomObject]$returnData.RGCreated)"
    Return [PSCustomObject]$returnData
  } # End
} # Function New-AzureLab

Function Remove-AzureLab {
  [CmdletBinding()]
  param(
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]")]
    [Parameter(Mandatory)]
    [string]$LabName
  )
  Write-Verbose "+ENTERING        Remove-AzureLab"
  $r = $false
  # Get the resource group
  $returned1 = Get-AzureRmResourceGroup -Name $LabName -ErrorAction SilentlyContinue
  Write-Verbose "Get            AzureRmResourceGroup returns $returned1"
  If ($returned1) {
    if ($returned1.Tags.AutoLab -eq $LabName) {
      Write-Verbose "Remove         AzureRmResourceGroup $LabName"
      $r = Remove-AzureRmResourceGroup -Name $LabName -Force
      Write-Verbose "Remove         AzureRmResourceGroup          returned $r"
    }
    Else {
      Throw "Cannot remove Resource Group $LabName - does not have the correct tag, 'AutoLab'."
    }
  }
  Else {
    Throw "Cannot remove Resource Group $LabName - it does not exist."
  }
  Write-Verbose "-EXITING         Remove-AzureLab"
  Return $r

<#  Write-Verbose "Checking Resource Group Removed:"
  $returned2 = Get-AzureRmResourceGroup -Name $LabName -ErrorAction SilentlyContinue
  Write-Debug "`$returned2 = $returned2"
  if (!($returned2)) {
    Write-Verbose "Get          AzureRmResourceGroup $Labname returns nothing"
    Return $true
  }
  Else {
    Write-Verbose "Get          AzureRmResourceGroup $Labname returns $returned2"
    Return $false
  }#>
} # Function Remove-AzureLab
