function _EnsureConnected { # Ensure Connected to Azure
  [CmdletBinding()]
  Param()
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    If (!$PSBoundParameters.ContainsKey("Verbose")) {
          $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }

  Try {
      Get-AzureRmContext -ErrorAction Stop
  }
  Catch [System.Management.Automation.PSInvalidOperationException] {
    Write-Host -ForegroundColor Yellow "Please complete your Azure login through the browser window."
    $azureRmContext = Add-AzureRmAccount -ErrorAction Stop
    Write-Host -ForegroundColor Yellow "Continuing..."
  }
  Catch [System.Management.Automation.CommandNotFoundException] {
    Throw "Please ensure that you have AzureRM module installed."
  }
  Catch [Microsoft.Azure.Commands.Common.Authentication.AadAuthenticationCanceledException] {
    Throw "Login canceled - unable to proceed without logging into Azure."
  }
  Return $azureRmContext
}