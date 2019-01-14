. "$PSScriptRoot\..\Logger.ps1"
. "$PSScriptRoot\GroupManager.ps1"
function find-existingAccount([String]$username) {
    log("Looking for user ${username}")
    return (Get-ADUser -Filter { SamAccountName -eq $username })
}
function add-Account([String]$username, [String]$name, [String]$prename) {
    $domain = $global:domain.Split(".")
    
    if ([bool] (find-existingAccount($username))) {
        log("User ${username} already exist!");
        enable-Account($username);
    }
    else {
        New-ADUser -Name ($prename + " " + $name) -GivenName $prename -Surname $name -SamAccountName $username -UserPrincipalName ($username + "@" + $global:domain) -AccountPassword (ConvertTo-SecureString -AsPlainText $global:defaultPassword -Force) -Path "OU=$global:userOU,OU=$global:mainOU,DC=m122g,DC=local" -Enabled $true
        log("Added User ${username}")
        enable-Account $username
    }
}
function disable-Account([String]$username) {
    find-existingAccount($username) | Disable-ADAccount
    log("Disabled User account ${username}")
}
function enable-Account([String]$username) {
    find-existingAccount($username) | Enable-ADAccount
    log("Enabled User account ${username}")
}
function add-AccountToGroup([String]$userName, [String]$groupName) {
    Add-ADGroupMember -Identity "GISO_${groupName}" -Members $userName
    log("Added ${userName} to group GISO_${groupName}")
}
function retrieve-AllADUsers() {
    log("Getting all users")
    return (Get-ADUser -Filter {name -like "*"})
}
function getGroupsofUser([String]$username) {
    log("Getting groups of ${username}");
    $groups = @()
    foreach ($group in retrieveAllGroups) {
        $user = Get-ADUser -Filter {GroupScope -eq "DomainLocal" -and SamAccountName -eq $username} -SearchBase "OU=$global:userOU,OU=$global:mainOU,DC=m122g,DC=local"
        if ([bool]$user) {
            $groups += $group
            Write-Host $group
        }
    }
    return $groups
}