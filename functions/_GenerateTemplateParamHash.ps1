function _GenerateTemplateParamHash{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $LabType,

        [Parameter(Mandatory)]
        [String]
        $LabName,

        [Parameter(Mandatory)]
        [String]
        $RealIp,

        [Parameter(Mandatory)]
        [Securestring]
        $LabPassword,

        [Parameter(Mandatory)]
        [Object[]]
        $BlobInfo,

        [Parameter(Mandatory)]
        [String]
        $StorageAccount
    )
    
    begin {
        # Temporary fix for VerbosePreference from calling scope not being honoured 
        If (!$PSBoundParameters.ContainsKey("Verbose")) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
        }

        "+[Entering]  _GenerateTemplateParamHash  $($PSBoundParameters.GetEnumerator()) $($BlobInfo.Count)" | Write-Verbose 
    }

    end {
        switch ($LabType) {
            Splunk {
                $sasKeyPlainText = "'" + $BlobInfo.where({$_.Name -eq "dsc.zip"}).SasKey + "'"
                $sasKeySecureString = ConvertTo-SecureString -String $sasKeyPlainText -AsPlainText -Force

                $paramHash = @{
                    LabAdmin = $LabConfigData.$LabType.LabAdmin
                    ManagementIP = $RealIp
                    LabPassword = $LabPassword
                    DomainControllerDscUri = $BlobInfo.where({$_.Name -eq "dsc.zip"}).uri
                    #DomainControllerDscSasToken = ""# $sasKeyPlainText
                    DomainControllerDscScript = $LabConfigData.$LabType.DomainControllerDscScript
                    DomainControllerDscFunction = $LabConfigData.$LabType.DomainControllerDscFunction
                    LabName = $LabName
                    SplunkSetupScript = "splunk_setup"
                    SplunkSetupScriptURL = $BlobInfo.where({$_.Name -eq "splunk_setup.sh"}).uri
                    StorageAccount = $StorageAccount
                }

            }

            Default { 
                Throw "Problem generating parameters for ARM template - can't determine lab type."
            }

        }
        "-[Exiting] _GenerateTemplateParamHash returning $([PSCustomObject]$paramHash)" | Write-Verbose
        $paramHash
    }
}