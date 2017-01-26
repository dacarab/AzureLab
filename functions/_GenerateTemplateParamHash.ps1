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
        $BlobInfo
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
                $sasKeyPlainText = "'" +$BlobInfo.where({$_.Name -eq "dsc.zip"}).SasKey + "'"
                $sasKeySecureString = ConvertTo-SecureString -String $sasKeyPlainText -AsPlainText -Force

                $paramHash = @{
                    ManagementIP = $RealIp
                    LabPassword = $LabPassword
                    ModulesUrl = $BlobInfo.where({$_.Name -eq "dsc.zip"}).uri
                    DomainController_DSCFunction = $LabConfigData.$LabType.DomainController_DSCFunction
                    SasToken = ""# $sasKeyPlainText
                    LabName = $LabName
                    SplunkSetupScript = "splunk_setup"
                    SplunkSetupScriptURL = $BlobInfo.where({$_.Name -eq "splunk_setup.sh"}).uri
                    StorageAccountName = ""
                    }
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