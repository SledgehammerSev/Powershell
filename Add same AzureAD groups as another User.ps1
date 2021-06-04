#Do this to connect to AzureAD
connect-azuread

#SET VARIABLES HERE
#GetUser - Set Variable to the user you want to Get Azure AD Group permissions FROM
#SetUser - Set Variable to the user you want to Give Azure AD Group permissions TO
$global:GetUser = Read-Host "Please Enter the email address of the user you want to copy AzureADGroups FROM"
$global:SetUser = Read-Host "Please Enter the email address of the user you want to copy AzureADGroups TO"


#FUNCTIONS HERE
#Checking if Azure AD User Exists
Function Check-GetAzureUser()
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

Function Check-SetAzureUser()
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
                    if($global:SetUser){
                    $global:SetUser = $global:SetUser.ToString() 
                    Do {  
                       $azureaduser = Get-AzureADUser -All $true | Where-Object {$_.Userprincipalname -eq "$global:SetUser"}
                       #check if something found  
                       if($azureaduser){
                             Write-Host "User: $global:SetUser was found in $displayname AzureAD." -ForegroundColor Green
                             $userexists = "true"
                             }
                             else
                             {
                             Write-Host "User $global:SetUser was not found in $displayname Azure AD " -ForegroundColor Red
                             $userexists = "false"
                             $global:SetUser = Read-Host "Please Enter the email address of the user you want to copy AzureADGroups TO"
                             } 
                    } Until ($userexists -eq "true") 
                    
                }
}

#---------------------------------------------------------------------------------------------------------
#START SCRIPT
Check-GetAzureUser
Check-SetAzureUser

#Gets ObjectID from $global:SetUser Variable
#$global:SetUserObjectID
$global:SetUserObjectID = (get-azureaduser -ObjectId $global:SetUser | Select -ExpandProperty ObjectId)
#Gets DisplayName of the Groups from Get and Set Users
$global:SetUserGroupsName = Get-AzureADUserMembership -ObjectID $global:SetUser | Select -ExpandProperty DisplayName
$GetAzureADGroupsName = Get-AzureADUserMembership -ObjectID $global:GetUser | Select -ExpandProperty DisplayName


#Get the Azure AD User
#get-azureaduser -ObjectID $global:GetUser

#Get all the group memberships that the SetUser user is a part of
Get-AzureADUserMembership -ObjectID $global:SetUser | Select -ExpandProperty DisplayName
Write-Host "
Azure Groups the User we want to copy TO is a part of" -ForegroundColor Green
Write-Host "Take a Screenshot of this before Proceeding
" -ForegroundColor Red
read-host “Screenshot, then Press ENTER to Continue...”

#Get all the group memberships that the GetUser user is a part of
Get-AzureADUserMembership -ObjectID $global:GetUser | Select -ExpandProperty DisplayName
Write-Host "
Azure Groups the User we want to copy FROM is a part of
"
#Check with the user to make sure it looks right before proceeding
$confirmFROMUser = read-host "Are you Sure You Want To Proceed? y/n"

#If the user chooses to proceed 
If ($confirmFROMUser -eq 'y' -or $confirmFROMUser -eq 'yes'-or $confirmFROMUser -eq "")
{$AzureADGroups = (Get-AzureADUserMembership -ObjectID $global:GetUser | Select -ExpandProperty ObjectId)
ForEach ($GroupID in $AzureADGroups) {
Try {add-azureadgroupmember -ObjectId $GroupID -RefObjectId $global:SetUserObjectID
write-host "
Confirmed, added the same groups to the new user..." -ForegroundColor Green
}
Catch {Write-Progress -Activity "Adding AzureADGroups..." -Status "Please wait."
}
}
write-host "
Confirmed, added the same groups to the new user..." -ForegroundColor Green
}
Else
{
[System.Windows.MessageBox]::Show('Please start over')
Remove-Variable * -ErrorAction SilentlyContinue
exit
}


#Adds an AzureADUser to a Group (ObjectID is the Group, RefObjectID is the User)
#add-azureadgroupmember -ObjectId feb0db64-2f27-4925-80f2-a1d1011ce15b -RefObjectId $global:SetUserObjectID

#Removed an AzureADUser to an Group (ObjectID is the Group, MemberId is the User)
#remove-azureadgroupmember -ObjectId feb0db64-2f27-4925-80f2-a1d1011ce15b -MemberId $global:SetUserObjectID

#Shows Groups that both users are a part of
$Compare = Compare -IncludeEqual -ExcludeDifferent $global:SetUserGroupsName $GetAzureADGroupsName | Select -ExpandProperty InputObject
$Compare
Write-Host "
Both Users now have these same groups" -ForegroundColor Green
Read-Host "Bye Bye"
Remove-Variable * -ErrorAction SilentlyContinue -Scope Global
exit

