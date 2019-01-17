. "$PSScriptRoot\..\Logger.ps1"

function Find-ExistingGroup([String]$name) {
    Logger("Looking for group GISO_${name}")
    return (Get-ADGroup -Filter "SamAccountName -eq ""GISO_$name""" -SearchBase "OU=$global:GroupOU,OU=$global:MainOU,DC=m122g,DC=local")
}
function Find-ByIdentity([String]$identity) {
    Logger("Looking for ${identity}")
    return (Get-ADGroup -Identity $identity)
}
function Add-Group([String] $name) {
    if ([bool] (Find-ExistingGroup $name)) {
        Logger("Group GISO_${name} already exists")
    }
    else {
        New-ADGroup -Name "GISO_${name}" -GroupScope DomainLocal -Path "OU=$global:GroupOU,OU=$global:MainOU,DC=m122g,DC=local"
        Logger("Group GISO_${name} created")
    }
}
function Remove-Group([String] $name) {
    Get-ADGroup -Filter {name -eq $name} -SearchBase "OU=$global:GroupOU,OU=$global:MainOU,DC=m122g,DC=local" | Remove-ADGroup -Confirm:$false
    Logger("Group GISO_${name} deleted")
}
function Get-AllADGroups() {
    return (Get-ADGroup -Filter * -SearchBase "OU=$global:GroupOU,OU=$global:MainOU,DC=m122g,DC=local")
}
function Get-AllGroupsFromCSV() {
    $groups = @()
    foreach ($schueler in $global:csvContent) {
        if (-not $groups.Contains($schueler.stammklasse)) {
            $groups += "GISO_$($schueler.stammklasse)"
        }
        if (-not $groups.Contains($schueler.zweitausbildung_stammklasse) -and $schueler.zweitausbildung_stammklasse) {
            $groups += "GISO_$($schueler.zweitausbildung_stammklasse)"
        }
    }
    return $groups
}