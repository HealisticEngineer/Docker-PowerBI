param(
    
    [Parameter(Mandatory = $true)]
    [string]$username,

    [Parameter(Mandatory = $true)]
    [string]$password

)
if ($username -eq "_") {
   
    Write-Verbose "ERR: No PowerBi user specified"
    exit 1
}


if ($password -eq "_") {
    if (Test-Path $env:ssrs_password_path) {
        $password = Get-Content -Raw $secretPath
    }
    else {
        Write-Verbose "ERR: No PowerBi user password specified and secret file not found at: $secretPath"
        exit 1
    }
}
$secpass = ConvertTo-SecureString  -AsPlainText $password -Force
New-LocalUser "$username" -Password $secpass -FullName "$username" -Description "Local admin $username"
Add-LocalGroupMember -Group "Administrators" -Member "$username"
#net user %$username%/expires:never
Get-LocalGroupMember -Group "Administrators"
