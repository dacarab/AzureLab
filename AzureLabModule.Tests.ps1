Clear-Host
Write-Host -ForegroundColor Red "Removing and re-importing AzureLab Module"
Remove-Module AzureLab -ErrorAction SilentlyContinue
Import-Module -name .\AzureLab.psm1

Describe "Module Tests" -Tag Unit {
  Context "Module Helper Functions"
  It -Pending "Connects you to Azure if not logged in"
}

Invoke-Pester -Script .\Functions 

Write-Host -ForegroundColor Red "Removing AzureLab Module"
Remove-Module AzureLab

