function _UploadLabFiles {
    [CmdletBinding()]
    param (
        $LabType,
        $StorageContext
    )
    
    begin {

        If (!$PSBoundParameters.ContainsKey("Verbose")) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
        }

        Write-Verbose "+ENTERING    _UploadLabFiles $($PSBoundParameters.GetEnumerator())"
    }
    
    end {

        $returnedStorageContainer = Get-AzureStorageContainer -name "labfiles" -Context $StorageContext -ErrorAction SilentlyContinue
        "Get-AzureStorageContainer returned $returnedStorageContainer" | Write-Verbose 

        If ($returnedStorageContainer) {
            Write-Warning "A storage container for labfiles already exists. Continuing will overwrite any old file data. Continue?"
            $confirm = Read-Host "Press 'y' then enter to continue"

            if ($confirm -ne "y") {
                Throw "Lab creation terminated by user."
            }

            Else {
                $labStorageContainer = $returnedStorageContainer
            }

        }

        Else {
            $labStorageContainer = New-AzureStorageContainer -Name "labfiles" -Context $StorageContext -Permission Container
            "New                  AzureStorageContainer Returns $storageContainer" | Write-Verbose
        }

        # Upload the blobs
        $labFilePath = "$($LabConfigData.LabFilesPath)\$LabType\Config"
        Write-Verbose "Labfilepath $labFilePath"
        $filesExist = Test-Path -path   $labFilePath\*.zip
        
        ForEach ($exist in $filesExist) {

            If (!$exist) {
                Throw "Required files not present in '$labFilePath'."
            }

        }

        $uploadedBlobs = Get-ChildItem -Path $labFilePath | Set-AzureStorageBlobContent -Container $labStorageContainer.Name -Context $StorageContext
        Write-Verbose "Set-AzureStorageBlobContent returned $uploadedBlobs"

        # Grab a Uri and SAS key for each uploaded file
        $blobInfo = New-Object System.Collections.ArrayList

        ForEach ($blob in $uploadedBlobs) {
            $uri = $blob.ICloudBlob.uri 
            $sasKey = New-AzureStorageBlobSASToken -Container labfiles -Blob $blob.Name -Permission r -Context $StorageContext
            $blobInfo.Add([PSCustomObject]@{Name = $blob.Name ;uri = $uri; SasKey = $sasKey}) | Out-Null
        }

        Write-Verbose "-[Exiting] _UploadLabFiles returning $blobInfo"
        Return ,$blobInfo

    }
}
