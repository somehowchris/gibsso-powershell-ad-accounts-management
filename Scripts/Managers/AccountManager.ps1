. "$PSScriptRoot\..\Logger.ps1"
function find-existingAccount {}
function add-Account([String]$username, [String]$name, [String]$prename) {
  $domain = $global:domain.Split(".")
    
  if ([bool] (Get-ADUser -Filter { SamAccountName -eq $username })) {
    log("User ${username} already exist!");
    enable-Account($username);
  }
  else {
    New-ADUser -Name ($prename + " " + $name) -GivenName $prename -Surname $name -SamAccountName $username -UserPrincipalName ($username + "@" + $global:domain) -AccountPassword (ConvertTo-SecureString -AsPlainText $global:defaultPassword -Force) -Path "OU=$global:userOU,OU=$global:mainOU,DC=m122g,DC=local" -Enabled $true
    log("Added User ${username}")
  }
}
function disable-Account([String]$username) {
  (Get-ADUser -Filter { SamAccountName -eq $username }) | Enable-ADAccount
}
function enable-Account {
  (Get-ADUser -Filter { SamAccountName -eq $username }) | Disable-ADAccount
}
function add-AccountToGroup([String]$userName, [String]$groupName) {
  Add-ADGroupMember -Identity $groupName -Members $userName
  log("Added ${userName} to group ${groupName}")
}