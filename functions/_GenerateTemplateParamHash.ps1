function _GenerateTemplateParamHash{
    [CmdletBinding()]
    param (
        [Parameter(AttributeValues)]
        [ParameterType]
        $LabType,

        [Parameter(AttributeValues)]
        [ParameterType]
        $RealIP
    )
    
    begin {
        # Temporary fix for VerbosePreference from calling scope not being honoured 
        If (!$PSBoundParameters.ContainsKey("Verbose")) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
        }

        Write-Verbose "+[Entering]  _GenerateTemplateParamHash  $($PSBoundParameters.GetEnumerator())"
    }
    
    process {
    }
    
    end {
    }
}