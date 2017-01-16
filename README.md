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
A bare minimum of functionality required is one line provisioning / de-provisioning of the lab. 

##Functions
###New-AzureLab###
Essentially a public function that the user will call, that accepts customization of the desired Lab through parameterization.

####Parameters
**-Name**
The name of the lab - this will also define the ResourceGroup to create in Azure, and be used to generate some of the names for underlying resources e.g. storage accounts etc. Takes *String* input.

**-LabType**
Used to select a pre-defined config for a lab, that can be further customized by specifying other parameters on this function. In the background, this will specify which ARM template to use - may also use this to define parameter sets. Takes a *String* as input - but will need to be constrained in some way to ensure only options for which a template exists are available.

**-WindowsHostsCount**
A simple count of the number of windows servers to deploy in the lab, in addition to any core infrastructure required for the lab to function (e.g., domain controller). Takes an *Int* as input.

**-LinuxHostsCount**
The equivalent of the **-WindowsHostsCount** parameter, for Linux. Takes an *Int* as input.

**-ADUsersFile**
Used to define a csv file containing a list of users to provision within AD. This parameter needs some additional thought, as it may not be appropriate for some of the ARM templates that are generated later on - which may not have AD. Takes a *String* as an argument.

**-ProvisionSMBShare**
Another parameter that requires additional thought. It will be useful to provision an SMB share within the lab, and may even something that is done as part of the deployment to enable customization of the environment. Will be a *Switch*  parameter.

####Example Syntax
New-AzureLab -Name [string] -LabType [string] -WindowsHostsCount [int] -LinuxHostsCount [int] -ADUsersFile [string] -ProvisionSMBShare

###Set-AzureLabConfig
Function that will be used to configure hosts in the lab once they are deployed. Initially plan to make this a public function that users can choose to leverage. 

####Example Syntax 
Set-AzureLabConfig -LabName [string] -DSCFile [string] 

