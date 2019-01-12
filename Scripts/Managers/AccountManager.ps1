function find-existingAccount {}
function add-Account([String]$username, [String]$name, [String]$prename) {
    $domain = $global:domain.Split(".")
    
    if([bool] (Get-ADUser -Filter { SamAccountName -eq $username })) {
        Write-Host "User does already exist!" -ForegroundColor Red
    } else {
        New-ADUser -Name ($prename + " " + $name) -GivenName $prename -Surname $name -SamAccountName $username -UserPrincipalName ($username + "@" + $global:domain) -AccountPassword (ConvertTo-SecureString -AsPlainText $global:defaultPassword -Force) -Path "OU=$global:userOU,OU=$global:mainOU,DC=m122g,DC=local" -Enabled $true
    }
}
function disable-Account {}
function enable-Account {}
function update-Account {}
function add-AccountToGroup([String]$userName, [String]$groupName) {
    Add-ADGroupMember -Identity $groupName -Members $userName
}