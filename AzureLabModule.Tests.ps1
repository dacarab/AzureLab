[CmdletBinding()]
param()

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get-ChildItem .\functions -Filter *.Tests.ps1 | ForEach-Object {& $_.FullName}

$Global:VerbosePreference = "SilentlyContinue"
