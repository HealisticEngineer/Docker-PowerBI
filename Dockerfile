FROM mcr.microsoft.com/windows/servercore:ltsc2019
LABEL  Name=PowerBI Version=0.1.11 maintainer="John Hall"
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
    pbirs_password_path="C:\ProgramData\Docker\secrets\pbirs-password"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# make install files accessible
COPY start.ps1 /
COPY SQLInstall.ps1 /
COPY PbiInstall.ps1 /
COPY configurePBIRS.ps1 /
COPY sqlstart.ps1 /
COPY newadmin.ps1 /
WORKDIR /

# Install SQL Server 2019
RUN .\sqlinstall
#  PowerBI Report Server
RUN .\pbiinstall

#HEALTHCHECK CMD [ "sqlcmd", "-Q", "select 1" ]
HEALTHCHECK --interval=5s \
 CMD powershell -command try { $response = iwr http://localhost/reports -UseBasicParsing -UseDefaultCredentials; \
     if ($response.StatusCode -eq 200) { return 0} else {return 1}; \
    } catch { return 1 }

CMD .\start -sa_password $env:sa_password -ACCEPT_EULA $env:ACCEPT_EULA -attach_dbs \"$env:attach_dbs\" -pbirs_user $env:pbirs_user -pbirs_password $env:pbirs_password -Verbose