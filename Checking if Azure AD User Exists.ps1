#Checking if Azure AD User Exists

Function Check-AzureUser()
{
  param(
    [Parameter(Mandatory=$true)][string]$UserPrincipalName
 )
  ## check if azure AD connection is already established (if not quit function)
        try {
            Write-Host "Checking if Azure AD Connection is established..." -ForegroundColor Yellow
            $azconnect = Get-AzureADTenantDetail -ErrorAction Stop
            $displayname = ($azconnect).DisplayName
            write-host "Azure AD connection established to Tenant: $displayname " -ForegroundColor Green
            }
            catch {
            write-host "No connection to Azure AD was found. Please use Connect-AzureAD command" -ForegroundColor Red
            break
                    }
                    ## check if user exists in azure ad 
                    #check if upn is not empty    
                    if($UserPrincipalName){
                    $UserPrincipalName = $UserPrincipalName.ToString()
                    $azureaduser = Get-AzureADUser -All $true | Where-Object {$_.Userprincipalname -eq "$UserPrincipalName"}
                       #check if something found    
                       if($azureaduser){
                             Write-Host "User: $UserPrincipalName was found in $displayname AzureAD." -ForegroundColor Green
                             return $true
                             }
                             else{
                             Write-Host "User $UserPrincipalName was not found in $displayname Azure AD " -ForegroundColor Red
                             return $false
                             }
                    }
}

Check-AzureUser


#Second Type - More Advanced
$global:GetUser = Read-Host "Please Enter the email address of the user you want to copy AzureADGroups FROM"

Function Check-AzureUserVariation()
{
  ## check if azure AD connection is already established (if not quit function)
        try {
            Write-Host "Checking if Azure AD Connection is established..." -ForegroundColor Yellow
            $azconnect = Get-AzureADTenantDetail -ErrorAction Stop
            $displayname = ($azconnect).DisplayName
            write-host "Azure AD connection established to Tenant: $displayname " -ForegroundColor Green
            }
            catch {
            write-host "No connection to Azure AD was found. Please use Connect-AzureAD command and start the script again" -ForegroundColor Red
            break
                    }
                    ## check if user exists in azure ad 
                    #check if upn is not empty    
                    if($global:GetUser){
                    $global:GetUser = $global:GetUser.ToString() 
                    Do {  
                       $azureaduser = Get-AzureADUser -All $true | Where-Object {$_.Userprincipalname -eq "$global:GetUser"}
                       #check if something found  
                       if($azureaduser){
                             Write-Host "User: $global:GetUser was found in $displayname AzureAD." -ForegroundColor Green
                             $userexists = "true"
                             }
                             else
                             {
                             Write-Host "User $global:GetUser was not found in $displayname Azure AD " -ForegroundColor Red
                             $userexists = "false"
                             $global:GetUser = Read-Host "Please Enter the email address of the user you want to copy AzureADGroups FROM"
                             } 
                    } Until ($userexists -eq "true") 
                    
                }
}

Check-AzureUserVariation
