


function Remove-RSSubscription{

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Alias('ItemPath', 'Path')]
        [Parameter(Mandatory = $True)]
        [string]
        $RsFolder,

        [switch]
        $Recurse,

        $Proxy
    )

    begin {
        #$Proxy = New-RsWebServiceProxyHelper -BoundParameters $PSBoundParameters
    }
    
    process {
        try {
            if($Recurse){
                Write-Verbose "Recurse flag set. Return all subscriptions in Folder:$($RsFolder) and sub-folders"
                $subs = $Proxy.ListSubscriptions($RsFolder)
            }
            else{
                Write-Verbose "Recurse flag not set. Return all subscriptions in Folder:$($RsFolder) only"
                $subs = $Proxy.ListSubscriptions($RSFolder) | Where-Object {$_.Path -eq "$($RsFolder)/$($_.Report)"}                        
            }
        }
        catch {
            throw (New-Object System.Exception("Failed to retrieve items in '$RsFolder': $($_.Exception.Message)", $_.Exception))
        }
        try {
            Write-Verbose "$($subs.Count) Subscriptions will be deleted."
            foreach($sub in $subs){
                $rsProxy.DeleteSubscription($sub.SubscriptionID)
                Write-Verbose "Subscription Deleted: $($sub.SubscriptionID)"
            }
        }
        catch {
            throw (New-Object System.Exception("Failed to delete items in '$RsFolder': $($_.Exception.Message)", $_.Exception))
        }  
    }
    
    end {

    }
}
    
