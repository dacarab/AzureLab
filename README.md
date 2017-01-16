#AzureLab Module ReadMe
This module is intended to allow quick and easy deployment to Azure of a splunk lab for testing. In time, it is expected that it will provide functionality to provision labs tailored to other specific testing scenarios on Azure.

##Initial Problem Statement
> I'm looking to develop some Splunk apps that would monitor and alert on a domain,as well as #nix stuff.
> So Splunk on ubuntu is fine... but would need a domain controller to pull data from, and experiment with audit policy.
> A couple of member servers for the same.
> A few scrips that crete a bunch of users and groups.
> A few scripts that make changes on a periodic basis that I can report and alert against .
> And I guess a desktop that I can use from within the environment to do the do. 

##Module Overview
A bare minium of funtionality required is one line provisioning / deprovisioning of the lab. 

##Functions
###New-AzureLab###
Essentially a public function that the user will call, that accepts customisation of the desired Lab through parametisation.

####Parameters


####Example Syntax
New-SplunkLab -Name [string] -LabType [string] -WindowsHostsCount [int] -LinuxHostsCount [int] -ADUsersFile [string] -ProvisionSMBShare




