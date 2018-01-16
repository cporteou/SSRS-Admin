

<#
.SYNOPSIS
Removes all subscriptions from a provided folder

.DESCRIPTION
This removes all subscriptions in a provided folder with a Recurse flag to include all sub folders.

.PARAMETER RsFolder
Target folder. This should be preceded by a /. Eg. '/Sales Reports'. It is possible to set the Root folder using '/'

.PARAMETER Recurse
Flag to determine if all sub folders should be included or only the target folder

.PARAMETER Proxy
Proxy object provided by using the New-RsWebServiceProxy command. Eg. New-RsWebServiceProxy -ReportServerUri 'http://ReportServerURL/ReportServer/ReportService2010.asmx?wsdl'

.EXAMPLE
Remove-RSSubscription -RSfolder '/' -Recurse -proxy $Proxy

This will remove all subscriptions in an entire instance

.EXAMPLE
Remove-RSSubscription -RSfolder '/Sales Reports' -proxy $Proxy -Confirm

This will remove all subscriptions in the Sales Reports folder only. It will not affect sub folders. It will also prompt before each subscription deletion

.NOTES
General notes
#>
function Remove-RSSubscription{

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
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
                if ($pscmdlet.ShouldProcess($sub.Path, "Delete Subscription with ID: $($sub.SubscriptionID)")) {
                    $Proxy.DeleteSubscription($sub.SubscriptionID)
                }                
                
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
    
