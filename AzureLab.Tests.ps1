$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = "AzureLab.psm1"
#. "$here\$sut"

Describe "AzureLab" {
    It -Pending "does something useful" {
        $true | Should Be $false
    }
}
