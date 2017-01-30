function _DeployArmTemplate {
  [CmdletBinding()]
  param(
    $LabName,
    $LabType,
    $TemplateParamHash
  )
  Begin {
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    If (!$PSBoundParameters.ContainsKey("Verbose")) {
          $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }

    Write-Verbose "+ENTERING        _DeployArmTemplate $($PSBoundParameters.GetEnumerator())"
  }

  End {
    Write-Verbose "Lab template path: $($LabConfigData.$LabType.TemplatePath) "
    $deploymentState = New-AzureRmResourceGroupDeployment -ResourceGroupName $LabName -TemplateParameterObject $TemplateParamHash -TemplateFile $LabConfigData.$LabType.TemplatePath

    Write-Verbose "-EXITING         _DeployArmTemplate           returning $deploymentState"
    $deploymentState
  }
}
