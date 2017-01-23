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
  # Block to ensure only valid AzureLocations are selected (if connected to Azure)
  DynamicParam {
    _DynamicParamAzureLocation
  }

  Begin { 
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    If (!$PSBoundParameters.ContainsKey("Verbose")) {
          $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }
    
    Write-Verbose "+ENTERING        New-AzureLab $($PSBoundParameters.GetEnumerator())"
    $azureContext = _EnsureConnected
    
    # Assign AzureLocation dynamic parameter value to $AzureLocation for use in script
    $AzureLocation = $($PSBoundParameters.AzureLocation)
  }

  End {
    $newRgState = _NewResourceGroup -LabName $LabName -AzureLocation $AzureLocation -LabType $LabType
    $storageAccount = _NewStorageAccount -LabName $LabName -AzureLocation $AzureLocation
    $storageAccountContext = _GetStorageAccountContext -LabName $LabName -StorageAccount $StorageAccount
    $uploadLabFilesState = _UploadLabFiles -LabType $LabType -StorageContext $storageAccountContext
    $templateParamHash = _GenerateTemplateParamHash -LabType -RealIP
    $deployState = _DeployArmTemplate -LabName $LabName -LabType $LabType -TemplateParamHash $templateParamHash -LabPassword $LabPassword

    Write-Verbose "-EXITING         New-AzureLab          Returning $deployState"
    Return $deployState
  }
  
}