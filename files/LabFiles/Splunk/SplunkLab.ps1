Configuration DomainController {
    param (
        [string]$LabName,
        [securestring]$LabPassword
    )
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Modulename xDnsServer
    
    node LocalHost {    

        WindowsFeature DNS {
            Name = "DNS"
            Ensure = "Present"
        }

        WindowsFeature AD-Domain-Services {
            Name = "AD-Domain-Services"
            Ensure = "Present"
        }

        xADDomain LabName.Local {
            DomainAdministratorCredential = $LabPassword
            DomainName = "$LabName.Local"
            SafemodeAdministratorPassword = $LabPassword
            DependsOn = "[WindowsFeature]AD-Domain-Services","[WindowsFeature]DNS"
        }
    }
}

