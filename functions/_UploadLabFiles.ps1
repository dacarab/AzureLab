function _UploadLabFiles {
    [CmdletBinding()]
    param (
        $LabType,
        $StorageAccount
    )
    
    begin {
        # Temporary fix for VerbosePreference from calling scope not being honoured 
        If (!$PSBoundParameters.ContainsKey("Verbose")) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
        }
    }
    
    end {
        # Get storage context

        # Create a blob container for lab files

        # Grab the local location of blobs to upload

        # Upload the blobs

        # Return 

    }
}
