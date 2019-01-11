function find-existingAccount() {}
function add-Account([String]$name, [String]$prename) {
    # Does not work yet
    New-ADUser -Organization $global:userOU -Name $name -AccountPassword (ConvertTo-SecureString -AsPlainText $global:defaultPassword -Force) -PassThru | Enable-ADAccount
}
function disable-Account() {}
function enable-Account() {}
function update-Account() {}
function add-AccountToGroup() {}