# Dotsource all the script files from functions folder that are not pester tests
get-childitem $PSScriptRoot\functions -Exclude "*tests*" | ForEach-Object {. $_.FullName}
$LabFilesPath = "$PSScriptRoot\files\LabFiles"

# Module Variables
$LabConfigData = @{
    LabFilesPath = $LabFilesPath
    Splunk = @{
        TemplatePath = "$LabFilesPath\Splunk\SplunkLab.json"
        DomainController_DSCFunction = "DomainController"
        DomainController_Script = "SplunkLab.ps1"
    }
}
