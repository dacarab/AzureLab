Function _NewStorageAccount {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$LabName,

    [Parameter(Mandatory)]
    [string]$AzureLocation
  )
  
  Begin {
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    If (!$PSBoundParameters.ContainsKey("Verbose")) {
          $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }
    Write-Verbose "+ENTERING        _NewStorageAccount $($PSBoundParameters.GetEnumerator())"
  }

  End {
    $storageAccountState = Find-AzureRmResource -ResourceGroupNameEquals $LabName -ResourceType "Microsoft.Storage/storageAccounts"

    If ($storageAccountState.Tags.AutoLab -eq "$LabName") {
      Write-Warning "A storage account for  $LabName exists, and has the appropriate tags. Do you wish to continue?"
      $confirm = Read-Host "Press 'y' then enter to continue"
      if ($confirm -ne "y") {
        Throw "Lab creation terminated by user. A storage account for this lab already exists."
      }
    }
    ElseIf ($storageAccountState){
      Throw "A storage account for $LabName already exists, but does not have the appropriate AutoLab tag."
    }
    Else {
      Try {
        $storageAccountName = _LabNameToStorageAccountName -LabName $LabName
      }
      catch {
        Throw "Unable to generate a valid storage account name. $($_.Exception.Message)."
      }
      $storageAccountState = New-AzureRmStorageAccount -ResourceGroupName $LabName -Name $storageAccountName -SkuName Standard_LRS -Location $AzureLocation
      Write-Verbose "New                   AzureStorageAccount $storageAccountName    RETURNS $storageAccountState"
    }
    Write-Verbose "-EXITING _NewStorageAccount          RETURNS $storageAccountState"
    Return $storageAccountState
  }
}

Function _LabNameToStorageAccountName {
  [CmdletBinding()]
  Param(
    [ValidateLength(1,61)]
    [ValidatePattern("[a-zA-Z0-9_-]")]
    [Parameter(Mandatory)]
    [String]$LabName
  )

  Begin{
    Write-Verbose "+ENTERING        _LabNameToStorageAccountName $($PSBoundParameters.GetEnumerator())"
  }

  End{
    $alphaNumeric = "[^a-zA-Z0-9]"
    $storageAccountNamePrefix = $LabName -replace $alphaNumeric, ''
    If ($($storageAccountNamePrefix.Length -gt 18)){
      $storageAccountNamePrefix = $storageAccountName.Substring(0,18)
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
