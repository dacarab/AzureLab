function _NewResourceGroup {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [string]$LabName,

    [Parameter(Mandatory)]
    [string]$AzureLocation,

    [Parameter(Mandatory)]
    [string]$LabType
  )

  Begin {
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    If (!$PSBoundParameters.ContainsKey("Verbose")) {
          $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }

    Write-Verbose "+ENTERING        _NewResourceGroup"
  }

  End {
    Write-Verbose "Get          AzureRmResourceGroup -Name $LabName"
    $rgState = Get-AzureRmResourceGroup -Name $LabName -ErrorAction SilentlyContinue
    Write-Verbose "Get          AzureRmResourceGroup returns $rgState"

    If (!$rgState) {
      Write-Verbose "New          AzureRmResourceGroup -Name $LabName -Location $AzureLocation -Tag @{AutoLab = $LabName}"
      $rgState = New-AzureRmResourceGroup -Name $LabName -Location $AzureLocation -Tag @{AutoLab = $LabName; LabType = $LabType}
      Write-Verbose "New          AzureRmResourceGroup returns $rgState"
    }
    ElseIf (!($rgState.Tags.AutoLab -eq "$LabName")) {
      Throw "The underpinning resource group for $LabName already exists, but does not have the appropriate AutoLab tag. Try using a different LabName."
    }
    Else {
      Write-Warning "Resource Group $LabName exists, and has the appropriate tags. Do you wish to continue?"
      $confirm = Read-Host "Press 'y' then enter to continue"
      if ($confirm -ne "y") {
        Throw "Lab creation terminated by user. Try using a different LabName."
      }
    }

    Write-Verbose "-EXITING        _NewResourceGroup returning $rgState"
    Return $rgState
  } # End
} # Function _NewResourceGroup
