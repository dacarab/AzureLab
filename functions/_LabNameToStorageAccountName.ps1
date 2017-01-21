Function _LabNameToStorageAccountName {
  [CmdletBinding()]
  Param(
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]")]
    [Parameter(Mandatory)]
    [String]$LabName
  )

  Begin{
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    If (!$PSBoundParameters.ContainsKey("Verbose")) {
          $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }
    Write-Verbose "+ENTERING        _LabNameToStorageAccountName $($PSBoundParameters.GetEnumerator())"
  }

  End{
    $alphaNumeric = "[^a-zA-Z0-9]"
    $storageAccountNamePrefix = $LabName.ToLower() -replace $alphaNumeric, ''

    If ($storageAccountNamePrefix.Length -gt 18){
      $storageAccountNamePrefix = $storageAccountNamePrefix.Substring(0,18)
    }

    Do {
      $suffix = Get-Random -Maximum 999999 -Minimum 100000
      $storageAccountName = $storageAccountNamePrefix + $suffix
      $result = Get-AzureRmStorageAccountNameAvailability -Name $storageAccountName
      If (!$($result.NameAvailable)) {
        Write-Warning "Naming clash when trying to use storage Account Name $storageAccountName"
        Write-Warning "Trying again..."
      }
    } while (!$($result.NameAvailable))

    Write-Verbose "-EXITING _LabNameToStorageAccountName RETURNS $storageAccountName"
    Return $storageAccountName
  }
}
