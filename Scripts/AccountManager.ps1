function find-existingAccount() {}
function create-Account([String $name]) {
    New-ADUser -Name $name -AccountPassword $global:defaultPassword
}
function deactivate-Account() {}
function activate-Account() {}
function update-Account() {}
function add-AccountToGroup() {}
