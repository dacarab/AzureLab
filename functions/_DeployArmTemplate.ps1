function _DeployArmTemplate {
  [CmdletBinding()]
  param(
    $ResourceGroupName,
    $LabType,
    [SecureString] $LabPassword
  )
  Begin {
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    If (!$PSBoundParameters.ContainsKey("Verbose")) {
          $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }

    Write-Verbose "+ENTERING        _DeployArmTemplate"
  }

  End {
    $paramHash = @{
      LabPassword = $LabPassword
    }
    
    # Deploy the template
    $deploymentState = New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateParameterObject $paramHash -TemplateFile .\files\SplunkLab.json

    # Return a PSCustomObject that represents the end state of the objects deployed
    $returnData = $deploymentState

    Write-Verbose "-EXITING         _DeployArmTemplate           returning $([PSCustomObject]$returnData.RGCreated)"
    Return $returnData
  }
}
