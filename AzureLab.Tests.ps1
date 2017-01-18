$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = "AzureLab.psm1"
#. "$here\$sut"

Remove-Module AzureLab
Import-Module -name .\AzureLab.psm1
Describe "AzureLab" {
    It -Pending "does something useful" {
        $true | Should Be $false
    }
}
