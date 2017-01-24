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
        [securestring]
        $LabPassword
    )
    
    begin {
        # Temporary fix for VerbosePreference from calling scope not being honoured 
        If (!$PSBoundParameters.ContainsKey("Verbose")) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
        }

        "+[Entering]  _GenerateTemplateParamHash  $($PSBoundParameters.GetEnumerator())" | Write-Verbose 
    }

    end {
        $dataToReturn = @{
            ManagementIP = $RealIp
            LabPassword = $LabPassword
            ModulesURL = $ModuleURL
            DomainController_DSCFunction = $DomainController_DSCFunction
            SasToken = $SasToken
            LabName = $LabName
        }

        "-[Exiting] _GenerateTemplateParamHash returning $dataToReturn" | Write-Verbose
        $dataToReturn
    }
}