# AzureLab Module ReadMe

This module is intended to allow quick and easy deployment to Azure of a splunk lab for testing. In time, it is expected that it will provide functionality to provision labs tailored to other specific testing scenarios on Azure.

## Initial Problem Statement

> I'm looking to develop some Splunk apps that would monitor and alert on a domain,as well as #nix stuff.
> So Splunk on ubuntu is fine... but would need a domain controller to pull data from, and experiment with audit policy.
> A couple of member servers for the same.
> A few scrips that create a bunch of users and groups.
> A few scripts that make changes on a periodic basis that I can report and alert against .

## Module Overview

A bare minimum of functionality required is one line provisioning / de-provisioning of the lab.

## Desired Enhancements

1. Provide easy way of customising machine count
1. Add Generic lab config
1. Add cmdlet to list all deployed labs
1. Add auto shutdown feature to vms
1. Add json template customisation feature

## Functions

### New-AzureLab

Essentially a public function that the user will call, that accepts customization of the desired Lab through parameterization.

#### Parameters

**-Name**
The name of the lab - this will also define the ResourceGroup to create in Azure, and be used to generate some of the names for underlying resources e.g. storage accounts etc. Takes *String* input.

**-LabType**
Used to select a pre-defined config for a lab, that can be further customized by specifying other parameters on this function. In the background, this will specify which ARM template to use - may also use this to define parameter sets. Takes a *String* as input - but will need to be constrained in some way to ensure only options for which a template exists are available.

**-LabPassword**
SecureString - Password to be used 

#### Example New-AzureLab Syntax

New-AzureLab -Name [string] -LabType [string] -WindowsHostsCount [int] -LinuxHostsCount [int] -ADUsersFile [string] -ProvisionSMBShare

### Set-AzureLabConfig

function that will be used to configure hosts in the lab once they are deployed. Initially plan to make this a public function that users can choose to leverage.

#### Example Set-AzureLab Syntax

Set-AzureLabConfig -LabName [string] -DSCFile [string]

## Credits

Using the technique outlined by **Dave Wyatt**  for allowing verbose preference to be picked up during Pester tests - see <https://blogs.technet.microsoft.com/heyscriptingguy/2014/04/26/weekend-scripter-access-powershell-preference-variables/>
