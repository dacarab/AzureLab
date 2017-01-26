Configuration DomainController {
    param (
        [string]$LabName,
        [pscredential]$AdminCred
    )
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Modulename xDnsServer
    
    node LocalHost {
        # Enable RDP connection without NLA
        Registry DisableNLA {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
            ValueName = "SecurityData"
            ValueData = "0"
        }

        WindowsFeature DNS {
            Name = "DNS"
            Ensure = "Present"
        }

        WindowsFeature AD-Domain-Services {
            Name = "AD-Domain-Services"
            Ensure = "Present"
        }

        xADDomain LabName.Local {
            DomainAdministratorCredential = [PSCredential]$AdminCred
            DomainName = "$LabName.Local"
            SafemodeAdministratorPassword = $AdminCred
            DependsOn = "[WindowsFeature]AD-Domain-Services","[WindowsFeature]DNS"
        }
    }
}

