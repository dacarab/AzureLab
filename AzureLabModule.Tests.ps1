Clear-Host
Write-Host -ForegroundColor Red "Removing and re-importing AzureLab Module"
Remove-Module AzureLab -ErrorAction SilentlyContinue
Import-Module -name .\AzureLab.psm1

Describe "Module Tests"{}

Invoke-Pester -Script .\Functions

Write-Host -ForegroundColor Red "Removing AzureLab Module"
Remove-Module AzureLab

