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

  End {
    $alphaNumeric = "[^a-zA-Z0-9]"
    $storageAccountNamePrefix = $LabName.ToLower() -replace $alphaNumeric, ''

    If ($storageAccountNamePrefix.Length -gt 18){
      $storageAccountNamePrefix = $storageAccountNamePrefix.Substring(0,18)
    }

    $i = 0
    Do {
      $i++
      $suffix = Get-Random -Maximum 999999 -Minimum 100000
      $storageAccountName = $storageAccountNamePrefix + $suffix
      $result = Get-AzureRmStorageAccountNameAvailability -Name $storageAccountName
      If ($i -ge 10) {Throw  "Cannot find valid storage account name."}
    } until ($result.NameAvailable -or $i -ge 10)

    Write-Verbose "-EXITING _LabNameToStorageAccountName RETURNS $storageAccountName"
    Return $storageAccountName
  }
}
