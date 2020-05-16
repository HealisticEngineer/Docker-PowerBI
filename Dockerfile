FROM mcr.microsoft.com/windows/servercore:ltsc2019
LABEL  Name=SSRS Version=0.0.11 maintainer="John Hall"

# Download Links:
ENV SQL "https://go.microsoft.com/fwlink/?linkid=866662"
ENV SQLCU "https://download.microsoft.com/download/6/e/7/6e72dddf-dfa4-4889-bc3d-e5d3a0fd11ce/SQLServer2019-KB4548597-x64.exe"
ENV PowerBI "https://download.microsoft.com/download/7/0/A/70AD68EF-5085-4DF2-A3AB-D091244DDDBF/PowerBIReportServer.exe"

ENV sa_password="_" \
    attach_dbs="[]" \
    ACCEPT_EULA="_" \
    sa_password_path="C:\ProgramData\Docker\secrets\sa-password" \
    pbirs_user="_" \
    pbirs_password="_" \
    pbirs_edition="EVAL" \
    ssrs_password_path="C:\ProgramData\Docker\secrets\ssrs-password"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# make install files accessible
COPY start.ps1 /
#COPY configureSSRS2017.ps1 /
COPY configurePBIRS.ps1 /
COPY sqlstart.ps1 /
COPY newadmin.ps1 /
WORKDIR /

# Install SQL Server 2019
RUN (New-Object System.Net.WebClient).DownloadFile($ENV:SQL, "c:\SQL.exe") ; \
    Start-Process -Wait -FilePath .\SQL.exe -ArgumentList /Q, /MT:CAB, /ACTION:Download, /Mediapath:c:\setup ; \
    Start-Process -Wait -FilePath c:\setup\SQLServer2019-DEV-x64-ENU.exe -ArgumentList /Q  ; \
    new-item -Path C:\SQLServer2019-DEV-x64-ENU\ -Name update -ItemType Directory ; \
    # Downloading update
    (New-Object System.Net.WebClient).DownloadFile($env:SQLCU, "C:\SQLServer2019-DEV-x64-ENU\update\SQLServer2019-KB4548597-x64.exe") ; \
    # install SQL
    .\SQLServer2019-DEV-x64-ENU\setup.exe /q /ACTION=Install /UpdateSource=".\update" /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=1 /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS ; \
    # perform clean up
    Remove-Item -Recurse -Force SQL.exe, Setup, SQLServer2019-DEV-x64-ENU, 'C:\Program Files\Microsoft SQL Server\150\Setup Bootstrap\Update Cache'

# Install PowerBI
RUN (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/7/0/A/70AD68EF-5085-4DF2-A3AB-D091244DDDBF/PowerBIReportServer.exe", "c:\SQLServerReportingServices.exe") ; \
    Start-Process -Wait -FilePath .\SQLServerReportingServices.exe -ArgumentList "/quiet", "/norestart", "/IAcceptLicenseTerms", "/Edition=$env:pbirs_edition" -PassThru -Verbose

#HEALTHCHECK CMD [ "sqlcmd", "-Q", "select 1" ]
HEALTHCHECK --interval=5s \
 CMD powershell -command \
    try { \
     $response = iwr http://localhost/reports -UseBasicParsing -UseDefaultCredentials; \
     if ($response.StatusCode -eq 200) { return 0} \
     else {return 1}; \
    } catch { return 1 }

CMD .\start -sa_password $env:sa_password -ACCEPT_EULA $env:ACCEPT_EULA -attach_dbs \"$env:attach_dbs\" -pbirs_user $env:pbirs_user -pbirs_password $env:pbirs_password -Verbose