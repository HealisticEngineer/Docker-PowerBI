<#
#>
Write-Verbose "SSRS Config"

function Get-ConfigSet() {
    return Get-WmiObject -namespace "root\Microsoft\SqlServer\ReportServer\RS_PBIRS\v15\Admin" -class MSReportServer_ConfigurationSetting -ComputerName localhost
}

# Allow importing of sqlps module
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Retrieve the current configuration
$configset = Get-ConfigSet

$configset

If (! $configset.IsInitialized) {
    # Get the ReportServer and ReportServerTempDB creation script
    [string]$dbscript = $configset.GenerateDatabaseCreationScript("ReportServer", 1033, $false).Script

    # Import the SQL Server PowerShell module
    Import-Module -name 'C:\Program Files (x86)\Microsoft SQL Server\150\Tools\PowerShell\Modules\sqlps'

    # Establish a connection to the 
    $conn = New-Object Microsoft.SqlServer.Management.Common.ServerConnection -ArgumentList $env:ComputerName
    $conn.ApplicationName = "SCOB Script"
    $conn.StatementTimeout = 0
    $conn.Connect()
    $smo = New-Object Microsoft.SqlServer.Management.Smo.Server -ArgumentList $conn

    # Create the ReportServer and ReportServerTempDB databases
    $db = $smo.Databases["master"]
    $db.ExecuteNonQuery($dbscript)

    # Set permissions for the databases
    $dbscript = $configset.GenerateDatabaseRightsScript($configset.WindowsServiceIdentityConfigured, "ReportServer", $false, $true).Script
    $db.ExecuteNonQuery($dbscript)

    # Set the database connection info
    $configset.SetDatabaseConnection("(local)", "ReportServer", 2, "", "")

    $configset.SetVirtualDirectory("ReportServerWebService", "ReportServer", 1033)
    $configset.ReserveURL("ReportServerWebService", "http://+:80", 1033)

    # Did the name change?
    $configset.SetVirtualDirectory("ReportServerWebApp", "Reports", 1033)
    $configset.ReserveURL("ReportServerWebApp", "http://+:80", 1033)

    $configset.InitializeReportServer($configset.InstallationID)

    # Re-start services?
    $configset.SetServiceState($false, $false, $false)
    Restart-Service $configset.ServiceName
    $configset.SetServiceState($true, $true, $true)

    # Update the current configuration
    $configset = Get-ConfigSet

    $configset.IsReportManagerEnabled
    $configset.IsInitialized
    $configset.IsWebServiceEnabled
    $configset.IsWindowsServiceEnabled
    $configset.ListReportServersInDatabase()
    $configset.ListReservedUrls();


    $inst = Get-WmiObject -namespace "root\Microsoft\SqlServer\ReportServer\RS_PBIRS\v15" -class MSReportServer_Instance -ComputerName localhost

    $inst.GetReportServerUrls()
}