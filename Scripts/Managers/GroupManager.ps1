. "$PSScriptRoot\..\Logger.ps1"

function find-ExistingGroup([String]$name) {
    log("Looking for group GISO_${name}")
    return (Get-ADGroup -Filter "SamAccountName -eq ""GISO_$name""" -SearchBase "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local")
}
function find-byIdentity([String]$identity) {
    log("Looking for ${identity}")
    return (Get-ADGroup -Identity $identity)
}
function add-Group([String] $name) {
    if ([bool] (find-ExistingGroup $name)) {
        log("Group GISO_${name} already exists")
    }
    else {
        New-ADGroup -Name "GISO_${name}" -GroupScope DomainLocal -Path "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local"
        log("Group GISO_${name} created")
    }
}
function remove-Group([String] $name) {
    Get-ADGroup -Filter {name -eq $name} -SearchBase "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local" | Remove-ADGroup -Confirm:$false
    log("Group GISO_${name} deleted")
}
function retrieveAllGroups() {
    return (Get-ADGroup -Filter {name -like "*"} -SearchBase "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local")
}
function get-AllGroupsFromCSV() {
    $groups = @()
    foreach ($schueler in $global:csvContent) {
        if (-not $groups.Contains($schueler.stammklasse)) {
            $groups += $schueler.stammklasse
        }
        if (-not $groups.Contains($schueler.zweitausbildung_stammklasse)) {
            $groups += $schueler.zweitausbildung_stammklasse
        }
    }
    return $groups
}