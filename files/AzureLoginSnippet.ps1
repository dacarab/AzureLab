Function Helper_Ensure_Connected {
    [CmdletBinding()]
    Param()
    Try {
        Get-AzureRmContext
    }
    Catch [System.Management.Automation.PSInvalidOperationException] {
        $azureRmContext = Add-AzureRmAccount 
    }

    Return $azureRmContext
}

Helper_Ensure_Connected -Verbose