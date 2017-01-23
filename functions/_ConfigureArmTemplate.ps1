function _ConfigureArmTemplate {
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

        Write-Verbose "+[Entering]  _ConfigureArmTemplate   $($PSBoundParameters.GetEnumerator())"
    }
    
    process {
    }
    
    end {
    }
}