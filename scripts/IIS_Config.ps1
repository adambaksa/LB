# Import the necessary module and install the Web Server role
Import-Module ServerManager
Add-WindowsFeature Web-Server -IncludeAllSubFeature
Add-WindowsFeature Web-Asp-Net45
Add-WindowsFeature NET-Framework-Features
