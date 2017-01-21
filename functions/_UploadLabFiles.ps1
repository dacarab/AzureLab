function _UploadLabFiles {
    # Temporary fix for VerbosePreference from calling scope not being honoured 
    If (!$PSBoundParameters.ContainsKey("Verbose")) {
          $VerbosePreference = $PSCmdlet.GetVariableValue('VerbosePreference')
    }
}
