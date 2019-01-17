. "$PSScriptRoot\..\Logger.ps1"

function Find-ExistingGroup([String]$name) {
    try {
        Logger("Looking for group GISO_${name}")
        return (Get-ADGroup -Filter "SamAccountName -eq ""GISO_$name""" -SearchBase "OU=$global:GroupOU,OU=$global:MainOU,DC=m122g,DC=local")
    }
    catch {
        Logger("Failed looking up $name in ad")
    }
}
function Find-ByIdentity([String]$identity) {
    try {
        Logger("Looking for ${identity}")
        return (Get-ADGroup -Identity $identity)
    }
    catch {
        Logger("Failed searching in ad by identity")
    }
}
function Add-Group([String] $name) {
    try {
        if ([bool] (Find-ExistingGroup $name)) {
            Logger("Group GISO_${name} already exists")
        }
        else {
            New-ADGroup -Name "GISO_${name}" -GroupScope DomainLocal -Path "OU=$global:GroupOU,OU=$global:MainOU,DC=m122g,DC=local"
            Logger("Group GISO_${name} created")
        }
    }
    catch {
        Logger("Failed adding group to ad")
    }
}
function Remove-Group([String] $name) {
    try {
        Get-ADGroup -Filter {name -eq $name} -SearchBase "OU=$global:GroupOU,OU=$global:MainOU,DC=m122g,DC=local" | Remove-ADGroup -Confirm:$false
        Logger("Group GISO_${name} deleted")
    }
    catch {
        Logger("Failed removing group $name")
    }
}
function Get-AllADGroups() {
    try {
        return (Get-ADGroup -Filter * -SearchBase "OU=$global:GroupOU,OU=$global:MainOU,DC=m122g,DC=local")
    }
    catch {
        Logger("Failed getting all groups from ad")
    }
}
function Get-AllGroupsFromCSV() {
    try {
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
    catch {
        Logger("Failed getting all groups from csv")
    }
}