# Get latetst PowerBI Report Server
$url = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=57270"
$PBRS = (iwr $url -UseBasicParsing).links | Where-Object {$_ -match "https://download.microsoft.com/download"} 
$ENV:PowerBI  = ($PBRS | Where-Object {$_.href -match "Powerbireportserver.exe"} |Select-Object -first 1).href
# Install PowerBI
new-item -Path C:\ -Name PBIRS_TEMP -ItemType Directory
(New-Object System.Net.WebClient).DownloadFile($ENV:PowerBI, "c:\PBIRS_TEMP\PowerBIReportServer.exe")
Start-Process -Wait -FilePath c:\PBIRS_TEMP\PowerBIReportServer.exe -ArgumentList /quiet, /norestart, /IAcceptLicenseTerms, /Edition=$ENV:pbirs_edition
# perform clean up
Remove-Item -Recurse -Force PBIRS_TEMP, 'C:\Users\ContainerAdministrator\AppData\Local\Temp'
