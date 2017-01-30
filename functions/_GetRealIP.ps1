function _GetRealIP {
    [CmdletBinding()]
    param ()
    
    begin {
        # Temporary fix for VerbosePreference from calling scope not being honoured 
        If (!$PSBoundParameters.ContainsKey("Verbose")) {
            $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
        }

        Write-Verbose "+ENTERING        _GetRealIP $($PSBoundParameters.GetEnumerator())"
    }
    
    end {
        $response = Invoke-WebRequest -Uri http://canihazip.com/s -DisableKeepAlive -UseBasicParsing
        $simpleIPParse = "^\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b$"
        If ($response.content -match $simpleIPParse ){
            $dataToReturn = $response.content
        }

        "-[Exiting] _GetRealIP returning $dataToReturn" | Write-Verbose
        $dataToReturn
    }
}