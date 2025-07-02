# Get latetst PowerBI Report Server
$ENV:PowerBI  = "https://download.microsoft.com/download/3/7/5/3754bf6e-e422-46ec-b9f8-fb3dc3993cab/PowerBIReportServer.exe"
# Install PowerBI
new-item -Path C:\ -Name PBIRS_TEMP -ItemType Directory
(New-Object System.Net.WebClient).DownloadFile($ENV:PowerBI, "c:\PBIRS_TEMP\PowerBIReportServer.exe")
Start-Process -Wait -FilePath c:\PBIRS_TEMP\PowerBIReportServer.exe -ArgumentList /quiet, /norestart, /IAcceptLicenseTerms, /Edition=$ENV:pbirs_edition
# perform clean up
Remove-Item -Recurse -Force PBIRS_TEMP, 'C:\Users\ContainerAdministrator\AppData\Local\Temp'
