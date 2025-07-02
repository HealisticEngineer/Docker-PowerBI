# Downloading SQL Server
(New-Object System.Net.WebClient).DownloadFile($ENV:SQL, "c:\SQL.exe")
Start-Process -Wait -FilePath .\SQL.exe -ArgumentList /Q, /MT:CAB, /ACTION:Download, /Mediapath:c:\setup
Start-Process -Wait -FilePath c:\setup\SQLServer2019-DEV-x64-ENU.exe -ArgumentList /Q
new-item -Path C:\SQLServer2019-DEV-x64-ENU\ -Name update -ItemType Directory
#finding latest 2019 CU
$downloadId = "100809"
$MajorVersion ="2019"
$response = Invoke-WebRequest -Uri "https://www.microsoft.com/en-us/download/details.aspx?id=$downloadId" -ErrorAction Ignore
$url = $response.Content | 
    Select-String -AllMatches -Pattern "(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?" | 
    ForEach-Object { $_.Matches.Value } | 
    Select-string "\.exe$" | 
    Select-Object -First 1 -ExpandProperty Line

# <meta name="description" content="Cumulative Update Package 16 for SQL Server 2022 - KB5048033"/>
if ($response.Content -match "<meta name=`"description`" content=`"Cumulative Update Package (\d+) for SQL Server $MajorVersion - KB(\d+)`"\s*\/\>") {
    $cu = $Matches[1]
    $kb = $Matches[2]
} else {
    return @{}
}

# Find full version number
if ($response.Content -match "\d+\.\d+\.\d+\.\d+") {
    $version = $Matches[0]
} else {
    return @{}
}

$v = [Version] $version
$Latest = @{ 
    URL64 = $url
    Version = $version
    KB = $kb
    CU = $cu
    Build = $v.Build
}
Write-Output $Latest
# Downloading update
(New-Object System.Net.WebClient).DownloadFile($latest.URL64, "C:\SQLServer2019-DEV-x64-ENU\update\$($Latest.KB).exe")
# install SQL
.\SQLServer2019-DEV-x64-ENU\setup.exe /q /ACTION=Install /UpdateSource=".\update" /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=1 /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS
# perform clean up
Remove-Item -Recurse -Force SQL.exe, Setup, SQLServer2019-DEV-x64-ENU, 'C:\Program Files\Microsoft SQL Server\150\Setup Bootstrap\Update Cache', 'C:\Users\ContainerAdministrator\AppData\Local\Temp'