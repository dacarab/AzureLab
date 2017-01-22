function _GetStorageAccountContext {
  [CmdletBinding()]
  param (
    $LabName,
    $StorageAccount
  )
  
  begin {
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    If (!$PSBoundParameters.ContainsKey("Verbose")) {
          $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }
    Write-Verbose "+ENTERING        _GetStorageAccountContext $($PSBoundParameters.GetEnumerator())"
  }

  end {
    $storageAccountkeys = Get-AzureRmStorageAccountKey -name $StorageAccount.StorageAccountName -ResourceGroupName $LabName
    Write-Verbose "[Returned:] Get                   AzureRmStorageAccountKey                    $storageAccountkeys"

    $storageAccountContext = New-AzureStorageContext  -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey $storageAccountKeys[0].Value
    Write-Verbose "[Returned:] New                   AzureStorageContext                          $storageAccountContext"

    Write-Verbose "-[Exiting:]  $storageAccountContext"
    $storageAccountContext 
  }
}
