# Install PowerBI
new-item -Path C:\ -Name PBIRS_TEMP -ItemType Directory
(New-Object System.Net.WebClient).DownloadFile($ENV:PowerBI, "c:\PBIRS_TEMP\PowerBIReportServer.exe")
Start-Process -Wait -FilePath c:\PBIRS_TEMP\PowerBIReportServer.exe -ArgumentList /quiet, /norestart, /IAcceptLicenseTerms, /Edition=$ENV:pbirs_edition
# perform clean up
Remove-Item -Recurse -Force PBIRS_TEMP, 'C:\Users\ContainerAdministrator\AppData\Local\Temp'