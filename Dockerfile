FROM mcr.microsoft.com/windows/servercore:ltsc2019
LABEL Name=PowerBI Version=0.1.14 maintainer="John Hall"
# Download Link:
ENV SQL "https://go.microsoft.com/fwlink/?linkid=866662"
ENV sa_password="_" \
    attach_dbs="[]" \
    ACCEPT_EULA="_" \
    sa_password_path="C:\ProgramData\Docker\secrets\sa-password" \
    pbirs_user="_" \
    pbirs_password="_" \
    pbirs_edition="EVAL" \
    pbirs_password_path="C:\ProgramData\Docker\secrets\pbirs-password"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Add powershell files to container
COPY *.ps1 /
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
