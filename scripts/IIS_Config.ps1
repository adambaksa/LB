# Import the necessary module and install the Web Server role
Import-Module ServerManager
Add-WindowsFeature Web-Server -IncludeAllSubFeature
Add-WindowsFeature Web-Asp-Net45
Add-WindowsFeature NET-Framework-Features
Set-Content -Path "C:\inetpub\wwwroot\Default.html" -Value "This is the server $($env:computername) !"
