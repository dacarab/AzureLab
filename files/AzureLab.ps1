function New-AzureLab {
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
    _DynamicParamAzureLocation
  }
  Begin { 
    Write-Verbose "+ENTERING        New-AzureLab"
    $azureContext = _EnsureConnected 
  }

  End {
    $newRgState = _NewResourceGroup -Name -Location

    $newSaState = _NewStorageAccount -Name -ResourceGroup

    $uploadLabFilesState = _UploadLabFiles -LabType -ResourceGroup

    $configureTemplateState = _ConfigureArmTemplate -LabType -RealIP

    $configureDeployState = _DeployArmTemplate -LabType -LabPassword

    Return $configureDeployState
  }
  
}
function _NewResourceGroup {




}


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
    Write-Verbose "-EXITING         Remove-AzureLab Returning $([PSCustomObject]$returnData.RGCreated)"
    Return [PSCustomObject]$returnData
  } # End
} # function New-AzureLab

function Remove-AzureLab {
  [CmdletBinding()]
  param(
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]")]
    [Parameter(Mandatory)]
    [string]$LabName
  )

  Begin { 
    Write-Verbose "+ENTERING        Remove-AzureLab"
    $azureContext = _EnsureConnected 
  }

  End {
    $removeResult = $false
    $initialState = Get-AzureRmResourceGroup -Name $LabName -ErrorAction SilentlyContinue
    Write-Verbose "Get          AzureRmResourceGroup          returns $initialRGState"
    If ($initialState) {
      if ($initialState.Tags.AutoLab -eq $LabName) {
        Write-Verbose "Remove        AzureRMResourceGroup $LabName - `$removeResult = $removeResult"
        Write-Verbose "`$removeResult = $removeResult"
        $removeResult = Remove-AzureRmResourceGroup -Name $LabName -Force
        Write-Verbose "Remove        AzureRMResourceGroup returned $removeResult"        
      }
      Else {
        Throw "Cannot remove Resource Group $LabName - does not have the correct tag, 'AutoLab'."
      }
  }
  Else {
    Throw "Cannot remove Resource Group $LabName - it does not exist."
  }

  Write-Verbose "-EXITING         Remove-AzureLab Returning $removeResult"
  Return $removeResult
  }
} # function Remove-AzureLab