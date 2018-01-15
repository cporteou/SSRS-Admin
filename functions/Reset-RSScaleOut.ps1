function Reset-RSScaleOut {
    [CmdletBinding()]
    param (
        [string]
        $targetInstance,

        [string]
        $targetDatabase,

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
            Write-Verbose "Delete all Scale Out Keys where  "
            Invoke-DbaSqlCmd -SqlInstance $targetInstance -Query "DELETE FROM [$($targetDatabase)].[dbo].[Keys] WHERE MachineName NOT IN ($($serverlist))"
        }
        catch {
            throw (New-Object System.Exception("Error Cleaning Keys Table! $($_.Exception.Message)", $_.Exception))
        }
    }
  
    end {
    }
}