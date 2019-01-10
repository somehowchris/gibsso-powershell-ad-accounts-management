function find-existingAccount() {}
function create-Account([String] $name) {
    New-ADUser -Name $name -AccountPassword $global:defaultPassword -path "OU=Lernende, DC=GIBS, DC=m122g, DC=local"
}
function deactivate-Account() {}
function activate-Account() {}
function update-Account() {}
function add-AccountToGroup() {}
