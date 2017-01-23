Configuration LabAD {
    param(
        [PSCredential]$Cred,
        [string]$DC,
        [string]$LabName
    )

    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Modulename xDnsServer
    
    node $DC {    

        WindowsFeature DNS {
            Name = "DNS"
            Ensure = "Present"
        }

        WindowsFeature AD-Domain-Services {
            Name = "AD-Domain-Services"
            Ensure = "Present"
        }

        xADDomain LabName.Local {
            DomainAdministratorCredential = $Cred
            DomainName = "CannedLogic.Local"
            SafemodeAdministratorPassword = $Cred
            DependsOn = "[WindowsFeature]AD-Domain-Services","[WindowsFeature]DNS"
        }
    }
}

