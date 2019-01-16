. "$PSScriptRoot\..\Logger.ps1"
. "$PSScriptRoot\GroupManager.ps1"
function find-existingAccount([String]$username) {
    try {
        log("Looking for user ${username}")
        return (Get-ADUser -Filter "SamAccountName -eq ""$username""" -SearchBase "OU=$global:userOU,OU=$global:mainOU,DC=m122g,DC=local" -Properties MemberOf)
    }
    catch {
        log("Acces denied to search in AD")
    }
}
function add-Account([String]$username, [String]$name, [String]$prename) {
    $domain = $global:domain.Split(".")
    $result = (find-existingAccount($username))
    if ([bool] $result -and $result.Enabled -eq $false) {
        log("User ${username} already exist!");
        enable-Account($username)
    }
    elseif ([bool] $result -and $result.Enabled -eq $true) {
        log("User ${username} already has been registered and enabled")
    }
    else {
        try {
            New-ADUser -Name ($prename + " " + $name) -GivenName $prename -Surname $name -SamAccountName $username -UserPrincipalName ($username + "@" + $global:domain) -AccountPassword (ConvertTo-SecureString -AsPlainText $global:defaultPassword -Force) -Path "OU=$global:userOU,OU=$global:mainOU,DC=m122g,DC=local" -Enabled $true
            log("Added User ${username}")
        }
        catch {
            log("Couldn't add ${username}")
        }
    }
}
function disable-Account([String]$username) {
    try {
        find-existingAccount($username) | Disable-ADAccount
        log("Disabled User account ${username}")
    }
    catch {
        log("Couldn't disable")
    }
}
function enable-Account([String]$username) {
    try {
        find-existingAccount($username) | Enable-ADAccount
        log("Enabled User account ${username}")
    }
    catch {
        log("Couldn't enable ${username}")
    }
}
function add-AccountToGroup([String]$username, [String]$groupname) {
    <# }
catch {
    log("Couldn't add ${userName} to ${groupName}")
} #>
    $group = find-ExistingGroup($groupname)
    $user = find-existingAccount($username)
    Add-ADGroupMember -Identity $group -Members $user
    log("Added ${username} to group GISO_${groupname}")
    
}
function remove-AccountFromGroup([String]$username, [String]$groupname) {
    <# }
catch {
  log("Couldn't add ${userName} to ${groupName}")
} #>
    $group = find-ExistingGroup($groupname)
    $user = find-existingAccount($username)
    Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false
    log("Added ${username} to group GISO_${groupname}")
  
}
function retrieve-AllADUsers() {
    try {
        log("Getting all users")
        return (Get-ADUser -Filter * -SearchBase "OU=$global:userOU,OU=$global:mainOU,DC=m122g,DC=local")
    }
    catch {
        log("Couldn't get all AD Users")
    }
}
function getGroupsofUser([String]$username) {
    log("Getting groups of ${username}")
    $groups = @()
    foreach ($group in (find-existingAccount($username)).MemberOf) {
        $groups += find-byIdentity($group)
    }
    return $groups
}