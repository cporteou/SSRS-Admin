<#
.SYNOPSIS
This will set the security on a specified folder. This can be adding or removing a user, or setting to inherit from parent

.DESCRIPTION
Sets security on a specified folder. Use of the Action variable will allow the addition or removal of a specified user or group. Using 'Inherit' will return the folder security
to that of the parent folder.

.PARAMETER RsFolder
Target folder. This should be preceded by a /. Eg. '/Sales Reports'. It is possible to set the Root folder using '/'

.PARAMETER Identity
This is the username of the user or group to be added or removed. This should include a domain prefix where relevant

.PARAMETER Role
The chosen Role for the addition of a new user. This should be one of the set roles within the target instance

.PARAMETER Action
This should be one of 3 options. ADD a provided user & role. REMOVE a provided user. Set the folder to Inherit from Parent

.PARAMETER Recurse
Flag to determine if all sub folders should be included or only the target folder

.PARAMETER proxy
Proxy object provided by using the New-RsWebServiceProxy command. Eg. New-RsWebServiceProxy -ReportServerUri 'http://ReportServerURL/ReportServer/ReportService2010.asmx?wsdl'

.EXAMPLE
Set-RSFolderSecurity -Proxy $proxy -RsFolder '/' -Action Add -Identity 'DOMAIN\User' -Role 'Content Manager'

This will grant DOMAIN\User Content Manager permissions on the root folder Only.

.NOTES
NOTE: The user executing this function will need the permissions within SSRS to perform these security changes
#>
function Set-RSFolderSecurity {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Alias('ItemPath', 'Path')]
        [Parameter(Mandatory = $True)]
        [string]
        $RsFolder,

        [Alias('GroupUserName')]
        [string]
        $Identity,

        [Alias('RoleName')]
        [string]
        $Role,
        
        [ValidateSet('Add','Remove','Inherit')]
        [string]
        $Action,

        [switch]
        $Recurse,

        $proxy
    )
    
    begin {
        If($Identity -eq $null -and (($Action -eq 'Add' -and $role -eq $null) -or ($Action -eq 'Remove'))){
            throw (New-Object System.Exception("Missing Parameters!"))        
        }

    }
    
    process {
        $folders = @()        

        try{
            if($Recurse){
                Write-Verbose "List out all sub-folders under the $($RsFolder) directory"
                $RSFolders = Get-RsFolderContent -Proxy $proxy -Path $RSFolder -Recurse | Where-Object{$_.TypeName -eq 'Folder'}
                $folders = $RSFolders.Path
            }
            Write-Verbose "Adding Folder Parameter to Array"
            $folders += $RsFolder
           
            foreach($folder in $folders){                
                
                If($Action -eq 'Add'){
                    Write-Verbose "Granting $($Identity) $($role) permissions on $($folder)"
                    if ($pscmdlet.ShouldProcess($folder, "Granting $($Identity) $($role) permissions on $($folder)")) {
                        Grant-RsCatalogItemRole -Proxy $proxy -Identity $Identity -RoleName $Role -Path $folder
                    }                    
                }
                Elseif($Action -eq 'Remove'){
                    Write-Verbose "Removing $($Identity) permissions from $($folder)"
                    if ($pscmdlet.ShouldProcess($folder, "Remove $($Identity) permissions from $($folder)")) {
                        Revoke-RsCatalogItemAccess -Proxy $proxy -Identity $Identity -Path $folder
                    }                    
                }
                ElseIf($Action -eq 'Inherit'){
                    $InheritParent = $true
                    Write-Verbose "Setting $($folder) to Inherit Parent Security"
                    $Proxy.GetPolicies($folder, [ref]$InheritParent)
                    if(-not $InheritParent -and $folder -ne '/') #Cant revert perms on Root folder
	                {
                        if ($pscmdlet.ShouldProcess($folder, "Set $($folder) to Inherit from Parent")) {
                            $Proxy.InheritParentSecurity($folder)
                        }
                    }
                }
                Else{
                    throw (New-Object System.Exception("No Valid Action provided! Use Add | Remove | Inherit"))
                }
            }
        }
        catch{
            throw (New-Object System.Exception("Error Updating Permissions! $($_.Exception.Message)", $_.Exception))
        
        }
    }
    
    end {
    }
}