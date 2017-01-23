function _NewStorageAccount {
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
    $returnedStorageAccounts = Get-AzureRmStorageAccount -ResourceGroupName $LabName
    "Get-AzureRmStorageAccount returns $returnedStorageAccounts" | Write-Verbose

    ForEach ($storageAccount in $returnedStorageAccounts) {
        If ($storageAccount.Tags.AutoLab -eq "$LabName") {
            Write-Warning "A storage account for  $LabName exists, and has the appropriate tags. Do you wish to continue?"
            $confirm = Read-Host "Press 'y' then enter to continue"
            if ($confirm -ne "y") {
                Throw "Lab creation terminated by user. A storage account for this lab already exists."
            }
            Else {
                $labStorageAccount = $storageAccount
            }
        }
    }

    If (!$labStorageAccount) {
      Try {
        $labStorageAccountName = _LabNameToStorageAccountName -LabName $LabName
      }
     Catch {
        Throw "Unable to generate a valid storage account name. $($_.Exception.Message)."
      }
      $labStorageAccount = New-AzureRmStorageAccount -ResourceGroupName $LabName -Name $labStorageAccountName -SkuName Standard_LRS -Location $AzureLocation -Tag @{AutoLab = $LabName}
      "New                   AzureStorageAccount $storageAccountName    RETURNS $returnedStorageAccounts" | Write-Verbose
    }
    
    "-EXITING _NewStorageAccount          RETURNS $labStorageAccount" | Write-Verbose
    $labStorageAccount
  }
}


