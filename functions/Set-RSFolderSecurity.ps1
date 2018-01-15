
function Set-RSFolderSecurity {
    [CmdletBinding()]
    param (
        [Alias('ItemPath', 'Path')]
        [Parameter(Mandatory = $True)]
        [string]
        $RsFolder,

        [string]
        $Identity,

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
        $folders += $RsFolder

        try{
            if($Recurse){
                Write-Verbose "List out all sub-folders under the $($RsFolder) directory"
                $folders = Get-RsFolderContent -Proxy $proxy -Path $RSFolder -Recurse | Where-Object{$_.TypeName -eq 'Folder'} | Select-Object Path
            }
            Write-Verbose "Adding Folder Parameter to Array"
            $folders += $RsFolder
           
            foreach($folder in $folders){

                If($Action -eq 'Add'){
                    Write-Verbose "Granting $($Identity) $($role) permissions on $($folder)"
                    Grant-RsCatalogItemRole -Proxy $proxy -Identity $Identity -RoleName $Role -Path $folder
                }
                Elseif($Action -eq 'Remove'){
                    Write-Verbose "Removing $($Identity) permissions from $($folder)"
                    Revoke-RsCatalogItemAccess -Proxy $proxy -Identity $Identity -Path $folder
                }
                ElseIf($Action -eq 'Inherit'){
                    Write-Verbose "Setting $($folder) to Inherit Parent Security"
                    $Proxy.InheritParentSecurity($folder)
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