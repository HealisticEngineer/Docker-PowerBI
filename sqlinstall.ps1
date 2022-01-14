# Downloading SQL Server
(New-Object System.Net.WebClient).DownloadFile($ENV:SQL, "c:\SQL.exe")
Start-Process -Wait -FilePath .\SQL.exe -ArgumentList /Q, /MT:CAB, /ACTION:Download, /Mediapath:c:\setup
Start-Process -Wait -FilePath c:\setup\SQLServer2019-DEV-x64-ENU.exe -ArgumentList /Q
new-item -Path C:\SQLServer2019-DEV-x64-ENU\ -Name update -ItemType Directory
#finding latest 2019 CU
$url = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=100809"
$CU = (iwr $url -UseBasicParsing).links | Where-Object {$_ -match "https://download.microsoft.com/download"} 
$ENV:SQLCU  = ($cu |Select-Object -first 1).href
$file = $ENV:SQLCU -split ('/') | Select-Object -last 1
# Downloading update
(New-Object System.Net.WebClient).DownloadFile($ENV:SQLCU, "C:\SQLServer2019-DEV-x64-ENU\update\$file")
# install SQL
.\SQLServer2019-DEV-x64-ENU\setup.exe /q /ACTION=Install /UpdateSource=".\update" /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=1 /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS
# perform clean up
Remove-Item -Recurse -Force SQL.exe, Setup, SQLServer2019-DEV-x64-ENU, 'C:\Program Files\Microsoft SQL Server\150\Setup Bootstrap\Update Cache', 'C:\Users\ContainerAdministrator\AppData\Local\Temp'
