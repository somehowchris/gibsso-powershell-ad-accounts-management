. "$PSScriptRoot\..\Logger.ps1"
. "$PSScriptRoot\GroupManager.ps1"
function Find-ExistingAccount([String]$username) {
    try {
        Logger("Looking for user ${username}")
        return (Get-ADUser -Filter "SamAccountName -eq ""$username""" -SearchBase "OU=$global:UserOU,OU=$global:MainOU,DC=m122g,DC=local" -Properties MemberOf)
    }
    catch {
        return $false
        Logger("Access denied to search in AD")
    }
}
function Add-Account([String]$username, [String]$name, [String]$prename) {
    $domain = $global:Domain.Split(".")
    $result = (Find-ExistingAccount($username))
    if ([bool] $result -and $result.Enabled -eq $false) {
        Logger("User ${username} already exist!");
        Enable-Account($username)
    }
    elseif ([bool] $result -and $result.Enabled -eq $true) {
        Logger("User ${username} already has been registered and is enabled")
    }
    else {
        try {
            New-ADUser -Name ($prename + " " + $name) -GivenName $prename -Surname $name -SamAccountName $username -UserPrincipalName ($username + "@" + $global:Domain) -AccountPassword (ConvertTo-SecureString -AsPlainText $global:DefaultPassword -Force) -Path "OU=$global:UserOU,OU=$global:MainOU,DC=m122g,DC=local" -Enabled $true
            Logger("Added User ${username}")
        }
        catch {
            Logger("Couldn't add ${username}")
        }
    }
}
function Disable-Account([String]$username) {
    try {
        Find-ExistingAccount($username) | Disable-ADAccount
        Logger("Disabled User account ${username}")
    }
    catch {
        Logger("Couldn't disable")
    }
}
function Enable-Account([String]$username) {
    try {
        Find-ExistingAccount($username) | Enable-ADAccount
        Logger("Enabled User account ${username}")
    }
    catch {
        Logger("Couldn't enable ${username}")
    }
}
function Add-AccountToGroup([String]$username, [String]$groupname) {
    try {
        $group = Find-ExistingGroup($groupname)
        $user = Find-ExistingAccount($username)
        Add-ADGroupMember -Identity $group -Members $user
        Logger("Added ${username} to group GISO_${groupname}")
    }
    catch {
        Logger("Couldnt add ${username} to ${groupname}")
    }
}
function Remove-AccountFromGroup([String]$username, [String]$groupname) {
    try{
        $group = Find-ExistingGroup($groupname)
        $user = Find-ExistingAccount($username)
        Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false
        Logger("Removed ${username} from group GISO_${groupname}")
    }catch{
        Logger("Couldnt remove ${username} from ${groupname}")
    }
}
function Get-AllADUsers() {
    try {
        Logger("Getting all users")
        return (Get-ADUser -Filter * -SearchBase "OU=$global:UserOU,OU=$global:MainOU,DC=m122g,DC=local")
    }
    catch {
        Logger("Couldn't get all AD Users")
    }
}
function Get-GroupsOfUser([String]$username) {
    try{
        Logger("Getting groups of ${username}")
        $groups = @()
        foreach ($group in (Find-ExistingAccount($username)).MemberOf) {
            $groups += Find-ByIdentity($group)
        }
        return $groups
    }catch{
        Logger("Failed getting group ${username}")
    }
}

function Get-AllUserNamesFromCSV() {
    try{
        Logger("Collecting usernames of csv")
        $usernames = @()
        foreach ($schueler in $global:csvContent) {
            $usernames += $schueler.username
        }
        return $usernames
    }catch {
        Logger("Failed getting all users of csv")
    }
}