$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Initialize-AzureLabAutomation" {
    Context Inputs {
        It -Pending "takes an appropriately formated LabName"{

        }

        It -Pending "throws custom error if DSCSourceFolder is inaccessible" {

        }

        It -Pending "only accepts valid AzureLocations" {

        }
    }

    Context Execution {
        It -Pending "initiates Add-AzureAccount if not connected to Azure" {

        }

       It -Pending "creates an Automation account if one does not exist for lab" {

       }

       It -Pending "does not try and create an Automation account if one does exist" {

       }

       It -Pending "uploads DSC configs from the specified source folder" {

       }


    }

    Context Outputs {

        It -Pending "outputs a correctly formatted object to indicate lab automation config" {

        }

    }
}
