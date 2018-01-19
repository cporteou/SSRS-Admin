
[CmdLetBinding()]
param
(
    [string]
    $reportServer,

    [string]
    $targetInstance,

    [string]
    $targetDatabase,
    
    [string]
    $backupLocation,
    
    [string]
    $ssrsServer
)

$InformationPreference = 'Continue'
#-----------------------------------------------------------------
Write-Information "Migrate the DB using dbaTools"
#-----------------------------------------------------------------

try {
    Write-Verbose "Restoring Database from $($backupLocation)"
    Restore-DbaDatabase -SqlServer $targetInstance -Path $backupLocation -WithReplace
    Write-Verbose "Database restored to $($targetDatabase) on $($targetInstance)"

}
catch {
    throw (New-Object System.Exception("Error restoring from backup! $($_.Exception.Message)", $_.Exception))
}

#-----------------------------------------------------------------
Write-Information "Set RS Database"
#-----------------------------------------------------------------

try {
    Write-Verbose "Get SQL Version for $($targetInstance)"
    $SQLVersion = Get-DbaSqlInstanceProperty -SqlInstance $targetInstance | Where-Object{$_.Name -eq 'VersionMajor'}
    Write-Verbose "Connecting to $($reportServer)'s default instance"
    Connect-RsReportServer -ComputerName $ssrsServer -ReportServerInstance 'MSSQLSERVER' -ReportServerUri $reportServer
    
    Write-Verbose "Setting up RS Database $($targetDatabase) Version:$($SQLVersion.Value) on $($targetInstance)"
    Set-RsDatabase -DatabaseServerName $targetInstance -Name $targetDatabase -IsExistingDatabase -DatabaseCredentialType ServiceAccount -ReportServerVersion $SQLVersion.Value
}
catch {
    throw (New-Object System.Exception("Error setting RS Database! $($_.Exception.Message)", $_.Exception))
}

#-----------------------------------------------------------------
Write-Information "Restore the Encryption Key"
#-----------------------------------------------------------------

try{
    Write-Verbose "Restoring Encryption Key from Source"
    $encKey = Read-Host "Please provide local encryption key for Database Source (E.g. C:\Encrypt_Key.snk)"
    $encKeyPass = Read-Host "Please provide the Password for the Encryption Key"
    Write-Debug "Encryption Key location: $($encKey)"
    Restore-RSEncryptionKey -Password $encKeyPass -KeyPath $encKey -ReportServerVersion $SQLVersion.Value

    Write-Information  "Please remember to update the Scaled out servers in SSRS"
}
catch{
    throw (New-Object System.Exception("Error restoring Encryption Key! $($_.Exception.Message)", $_.Exception))
}

$InformationPreference = 'Silently Continue'