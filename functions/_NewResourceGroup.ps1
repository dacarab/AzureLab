function _NewResourceGroup {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$Location,

    [Parameter(Mandatory)]
    [string]$LabType
  )

  Begin {
    Write-Verbose "+ENTERING        _NewResourceGroup"
  }

  End {
    # Create ResourceGroup if required
    Write-Verbose "Get          AzureRmResourceGroup -Name $LabName"
    $rgState = Get-AzureRmResourceGroup -Name $LabName -ErrorAction SilentlyContinue
    Write-Verbose "Get          AzureRmResourceGroup returns $rgState"

    If (!$rgState) {
      Write-Verbose "New          AzureRmResourceGroup -Name $LabName -Location $AzureLocation -Tag @{AutoLab = $LabName}"
      $labResourceGroup = New-AzureRmResourceGroup -Name $LabName -Location $AzureLocation -Tag @{AutoLab = $LabName}
      Write-Verbose "New          AzureRmResourceGroup returns $labResourceGroup"
    }
    ElseIf (!($rgState.Tags.AutoLab -eq "$Name")) {
      Throw "The underpinnin resource group for $Name already exists,`
       but does not have the appropriate AutoLab tag.`
       Try using a different LabName."
    }
    Else {
      Write-Warning "Resource Group $LabName exists, and has the appropriate tags. Do you wish to continue?"
      $confirm = Read-Host "Press 'y' then enter to continue"
      if ($confirm -ne "y") {
        Throw "Lab creation terminated by user. Try using a different LabName."
      }
    }

    Write-Verbose "-EXITING        _NewResourceGroup"
    Return $rgState
  } # End
} # Function _NewResourceGroup
