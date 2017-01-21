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

    Write-Verbose "+ENTERING        _NewResourceGroup $($PSBoundParameters.GetEnumerator())"
  }

  End {
    $resourceGroupState = Get-AzureRmResourceGroup -Name $LabName -ErrorAction SilentlyContinue
    Write-Verbose "Get           AzureRmResourceGroup $LabName            returns $resourceGroupState"

    If ($resourceGroupState.Tags.AutoLab -eq "$LabName") {
      Write-Warning "Resource Group $LabName exists, and has the appropriate tags. Do you wish to continue?"
      $confirm = Read-Host "Press 'y' then enter to continue"
      if ($confirm -ne "y") {
        Throw "Lab creation terminated by user. Try using a different LabName."
      }
    }
    ElseIf ($resourceGroupState) {
      Throw "The underpinning resource group for $LabName already exists, but does not have the appropriate AutoLab tag. Try using a different LabName."
    }
    Else {
      $resourceGroupState = New-AzureRmResourceGroup -Name $LabName -Location $AzureLocation -Tag @{AutoLab = $LabName; LabType = $LabType}
      Write-Verbose "New          AzureRmResourceGroup $LabName            returns $resourceGroupState"
    }

    Write-Verbose "-EXITING        _NewResourceGroup returning $resourceGroupState"
    Return $resourceGroupState
  } # End
} # Function _NewResourceGroup
