function _DeployArmTemplate {
  [CmdletBinding()]
  param(
    $ResourceGroupName,
    $LabType,
    [SecureString] $LabPassword
  )
  Begin {
    Write-Verbose "+ENTERING        _DeployArmTemplate"
  }

  End{
    $paramHash = @{
      LabPassword = $LabPassword
    }
    
    # Deploy the template
    New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateParameterObject $paramHash -TemplateFile .\files\SplunkLab.json

    # Return a PSCustomObject that represents the end state of the objects deployed
    $returnData = @{
      ResourceGroup = $labResourceGroup
      RGCreated = $rgCreated
    }

    Write-Verbose "-EXITING         _NewResourceGroup           Returning $([PSCustomObject]$returnData.RGCreated)"
    Return [PSCustomObject]$returnData
  }
}
