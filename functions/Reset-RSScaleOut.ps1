<#
.SYNOPSIS
Removes all but the specified servers from Reporting Services Scale Out deployment

.DESCRIPTION
Using dbatools Invoke-DbaSqlCmd command, removes all servers except the specified servers from the dbo.keys table in the SSRS database. 
This removes them from the Scale Out deployment. This is intended to be used in Migration situations

.PARAMETER targetInstance
This is the target database instance. For default instances you do not need to specify the instance. Eg. DBSERVER  Eg. DBSERVER\INSTANCE2

.PARAMETER targetDatabase
This is the target Database for the Report Server. This defaults to ReportServer if no DB is provided

.PARAMETER ssrsServer
This is the machine name for the target servers. These can be passed as an array or a single machine

.EXAMPLE
Reset-RSScaleOut -targetInstance 'DBSERVER' -targetDatabase ReportServerClient1 -ssrsServer 'SSRS01'

This will remove all other machines from the Scale Out, leaving only SSRS01

.NOTES
General notes
#>
function Reset-RSScaleOut {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [string]
        $targetInstance,

        [string]
        $targetDatabase = 'ReportServer',

        [string[]]
        $ssrsServer

    )
    
    begin {
        $serverlist = $null
        foreach($server in $ssrsServer){
            $serverlist += "'$($server)',"
        }
        $serverlist = $serverlist.TrimEnd(",")
    }
    
    process {

        try {
            Write-Verbose "Delete all Scale Out Keys not attributed to servers: $($serverlist)"
            $command = "DELETE FROM [$($targetDatabase)].[dbo].[Keys] WHERE MachineName NOT IN ($($serverlist))"
            Write-Verbose "Command: $($command)"
            if ($pscmdlet.ShouldProcess($command, "Delete Machines from Scale Out deployment (dbo.Keys table)")) {
                Invoke-DbaSqlCmd -SqlInstance $targetInstance -Query $command
            } 
            Invoke-DbaSqlCmd -SqlInstance $targetInstance -Query $command
        }
        catch {
            throw (New-Object System.Exception("Error Cleaning Keys Table! $($_.Exception.Message)", $_.Exception))
        }
    }
  
    end {
    }
}