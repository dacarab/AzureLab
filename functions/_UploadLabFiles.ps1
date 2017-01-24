function _UploadLabFiles {
    [CmdletBinding()]
    param (
        $LabType,
        $StorageContext
    )
    
    begin {
        # Temporary fix for VerbosePreference from calling scope not being honoured 
        If (!$PSBoundParameters.ContainsKey("Verbose")) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
        }

        Write-Verbose "+ENTERING    _UploadLabFiles $($PSBoundParameters.GetEnumerator())"
    }
    
    end {

        $returnedStorageContainer = Get-AzureStorageContainer -name "labfiles" -Context $StorageContext
        "Get-AzureStorageContainer returned $returnedStorageContainer" | Write-Verbose 

        If ($returnedStorageContainer) {
            $labStorageContainer = $returnedStorageContainer
        }
        Else {
            # Create a blob container for lab files
            $labStorageContainer = New-AzureStorageContainer -Name "labfiles" -Context $StorageContext
            Write-Verbose "New                  AzureStorageContainer Returns $storageContainer"
        }
        
        # Upload the blobs
        $labFilePath = "C:\Users\david\OneDrive - Carabott\Code\AzureLab\files\LabFiles\$LabType"
        Write-Verbose "Labfilepath $labFilePath"

        # Check the correct files are in $labFilePath
        Test-Path -path  $labFilePath\*.json, $labFilePath\*.ps1, $labFilePath\*.psd1 | ForEach-Object {
            If (!$_) {
                Throw "Required files not present in '$labFilePath'."
            }
        }


        $uploadedBlobs = Get-ChildItem -Path $labFilePath | Set-AzureStorageBlobContent -Container $labStorageContainer.Name -Context $StorageContext
        Write-Verbose "Set-AzureStorageBlobContent returned $uploadedBlobs"
        
        Write-Verbose "-[Exiting] _UploadLabFiles returning $uploadedBlobs"
        $uploadedBlobs

        #TODO: Grab the URL and SAS Token for the uploaded DSC config
    }
}
