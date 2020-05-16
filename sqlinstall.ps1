# Downloading SQL Server
(New-Object System.Net.WebClient).DownloadFile($ENV:SQL, "c:\SQL.exe")
Start-Process -Wait -FilePath .\SQL.exe -ArgumentList /Q, /MT:CAB, /ACTION:Download, /Mediapath:c:\setup
Start-Process -Wait -FilePath c:\setup\SQLServer2019-DEV-x64-ENU.exe -ArgumentList /Q
new-item -Path C:\SQLServer2019-DEV-x64-ENU\ -Name update -ItemType Directory
# Downloading update
(New-Object System.Net.WebClient).DownloadFile($ENV:SQLCU, "C:\SQLServer2019-DEV-x64-ENU\update\SQLServer2019-KB4548597-x64.exe")
# install SQL
.\SQLServer2019-DEV-x64-ENU\setup.exe /q /ACTION=Install /UpdateSource=".\update" /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=1 /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS
# perform clean up
Remove-Item -Recurse -Force SQL.exe, Setup, SQLServer2019-DEV-x64-ENU, 'C:\Program Files\Microsoft SQL Server\150\Setup Bootstrap\Update Cache', 'C:\Users\ContainerAdministrator\AppData\Local\Temp'