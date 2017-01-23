function Remove-AzureLab {
  [CmdletBinding()]
  param(
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]")]
    [Parameter(Mandatory)]
    [string]$LabName
  )

  Begin {
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')

    Write-Verbose "+ENTERING        Remove-AzureLab $($PSBoundParameters.GetEnumerator())"
    $azureContext = _EnsureConnected 
  }

  End {
    $removeResult = $false
     Write-Verbose "Get          AzureRMResourceGroup $LabName"
    $returnedResourceGroup = Get-AzureRmResourceGroup -Name $LabName -ErrorAction SilentlyContinue
    Write-Verbose "Get          AzureRmResourceGroup          returns $returnedResourceGroup"
    If ($returnedResourceGroup) {
      if ($returnedResourceGroup.Tags.AutoLab -eq $LabName) {
        Write-Verbose "Remove        AzureRMResourceGroup $LabName"
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
} 