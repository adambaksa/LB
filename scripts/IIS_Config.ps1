# Importáljuk a szükséges modult és telepítjük a webszerver szerepkört
Import-Module ServerManager
Add-WindowsFeature Web-Server -IncludeAllSubFeature
Add-WindowsFeature Web-Asp-Net45
Add-WindowsFeature NET-Framework-Features

$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title> WebApp </title>
    <style>
        body {
            background-color: #f0f0f0;
            color: #333;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body>
    <div class="container">
	<h1> The website is currently running on the following server: $($env:computername)</h1>
    <h2> This is a website backed by two load balancer servers. Their purpose is to distribute incoming network and application traffic, thereby improving the availability and performance of applications.</h2>
    </div>
</body>
</html>
"@

# A HTML tartalmat beállítjuk a Default.html fájlba a C:\inetpub\wwwroot könyvtárban
Set-Content -Path "C:\inetpub\wwwroot\Default.html" -Value $htmlContent
