function _GenerateTemplateParamHash{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $LabType,

        [Parameter(Mandatory)]
        [String]
        $RealIp,

        [Parameter(Mandatory)]
        [securestring]
        $LabPassword
    )
    
    begin {
        # Temporary fix for VerbosePreference from calling scope not being honoured 
        If (!$PSBoundParameters.ContainsKey("Verbose")) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
        }

        Write-Verbose "+[Entering]  _GenerateTemplateParamHash  $($PSBoundParameters.GetEnumerator())"
    }

    end {
        $dataToReturn = @{
            ManagementIP = $RealIp
            LabPassword = $LabPassword
        }

        "-[Exiting] _GenerateTemplateParamHash returning $returnData" | Write-Verbose
        $dataToReturn
    }
}