function _DeployArmTemplate {
  [CmdletBinding()]
  param(
    $LabName,
    $LabType,
    $TemplateParamHash,
    [SecureString] $LabPassword
  )
  Begin {
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    If (!$PSBoundParameters.ContainsKey("Verbose")) {
          $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }

    Write-Verbose "+ENTERING        _DeployArmTemplate $($PSBoundParameters.GetEnumerator())"
  }

  End {
    $dataToReturn = New-AzureRmResourceGroupDeployment -ResourceGroupName $LabName -TemplateParameterObject $TemplateParamHash -TemplateFile $Labs.$LabType.TemplatePath

    Write-Verbose "-EXITING         _DeployArmTemplate           returning $([PSCustomObject]$dataToReturn)"
    $dataToReturn
  }
}
