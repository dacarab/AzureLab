# Dotsource all the script files from functions folder that are not pester tests
get-childitem $PSScriptRoot\functions -Exclude "*tests*" | ForEach-Object {. $_.FullName}
$LabFilesPath = "$PSScriptRoot\files\LabFiles"

# Module Variables
$LabConfigData = @{
    LabFilesPath = $LabFilesPath
    Splunk = @{
        TemplatePath = "$LabFilesPath\Splunk\SplunkLab.json"
        DomainControllerDscFunction = "DomainController"
        DomainControllerDscScript = "SplunkLab.ps1"
        LabAdmin = "SplunkAdmin"
    }
}
