function find-existingAccount() {}
function add-Account([String]$name) {
    $domain = $global:domain.Split(".")
    Write-Host "DC=" + $domain[0] + ", DC=" + $domain[1]

    if([bool] (Get-ADUser -Identity $name)) {
        Write-Host "User does already exist!"
    } else {
        New-ADUser -Name $name -AccountPassword (ConvertTo-SecureString -AsPlainText $global:defaultPassword -Force) -Path "OU=$global:userOU,OU=$global:mainOU,DC=$domain[0],DC=$domain[1]" -PassThru | Enable-ADAccount
    }
}
function disable-Account() {}
function enable-Account() {}
function update-Account() {}
function add-AccountToGroup([String]$userName, [String]$accountName) {
    Add-ADGroupMember -Identity $accountName -Members $userName
}