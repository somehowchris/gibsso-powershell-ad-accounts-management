. "$PSScriptRoot\..\Managers\FileManager.ps1"
. "$PSScriptRoot\..\Managers\AccountManager.ps1"
. "$PSScriptRoot\..\Managers\GroupManager.ps1"
. "$PSScriptRoot\..\Managers\DirectoryManager.ps1"
. "$PSScriptRoot\..\Logger.ps1"

function XMLtoCSV {
    Logger("Converting XML to CSV");
    Convert-XmlToCsv
}
function Load-CSV {
    Logger("Loading CSV");
    Read-CSV
}
function Create-Users {
    foreach ($schueler in $global:csvContent) {
        Add-Account $($schueler).username $($schueler).name $($schueler).vorname
    }
}
function Create-Groups {
    $groups = @()
    foreach ($schueler in $global:csvContent) {
        if (-not $groups.Contains($schueler.stammklasse) -and -not ([string]::IsNullOrEmpty($schueler.stammklasse))) {
            Add-Group($schueler.stammklasse);
        }
        if (-not $groups.Contains($schueler.zweitausbildung_stammklasse) -and -not ([string]::IsNullOrEmpty($schueler.zweitausbildung_stammklasse))) {
            Add-Group($schueler.zweitausbildung_stammklasse);
        }
    }
    Logger("Finished task creating groups");
}
function Deactivate-NotRequieredUsers {
    $ADUsers = Get-AllADUsers

    foreach ($adUser in $ADUsers) {
        $mentioned = $false
        foreach ($schueler in $global:csvContent) {
            if (-not $mentioned -and $schueler.username -eq $adUser.SamAccountName) {
                $mentioned = $true
            }
        }
        if (-not $mentioned -and $adUser.SamAccountName.Contains(".") -and $adUser.Enabled) {
            Disable-Account($adUser.SamAccountName);
        }
    }
}
function Delete-NotRequieredGroups {
    $groups = Get-AllGroupsFromCSV
    $ADGroups = Get-AllADGroups
    foreach ($group in $ADGroups) {
        if (-not $groups.Contains($group.name)) {
            Remove-Group($group.name)
        }
    }

}
function Assosiate-UsersToGroups {
    $GroupsPerPerson = @{}
    foreach ($schueler in $global:csvContent) {
        Add-AccountToGroup $schueler.username $schueler.stammklasse 
        $GroupsPerPerson[$schueler.username] = @()
        $GroupsPerPerson[$schueler.username] += "GISO_$($schueler.stammklasse)"
        if (-not ([string]::IsNullOrEmpty($schueler.zweitausbildung_stammklasse))) {
            Add-AccountToGroup $schueler.username $schueler.zweitausbildung_stammklasse
            $GroupsPerPerson[$schueler.username] += "GISO_$($schueler.zweitausbildung_stammklasse)"
        }
    }
    foreach ($user in Get-AllADUsers) {
        $groups = Get-GroupsOfUser $user.SamAccountName
        foreach ($group in $groups) {
            if ($GroupsPerPerson.ContainsKey($user.SamAccountName)) {
                if (-not $GroupsPerPerson[$user.SamAccountName].Contains($group.SamAccountName)) {
                    Remove-AccountFromGroup $user.SamAccountName $group.SamAccountName
                }
            }
            else {
                Remove-AccountFromGroup $user.SamAccountName $group.SamAccountName
            }
        }
    }
}
function Create-GroupDirectories {
    $groups = Get-AllGroupsFromCSV
    foreach ($group in $groups) {
        Create-GroupDirectory($group)
    }
}
function Create-UserDirectories {
    foreach ($schueler in $global:csvContent) {
        Create-UserDirectory($schueler.username)
    }
}
function Rename-OldDirectories {
    $dirUsers = Get-AllUsersByDirectories
    $dirGroups = Get-AllGroupsByDirectorie
    $csvGroups = Get-AllGroupsFromCSV
    $csvUsers = Get-AllUserNamesFromCSV

    foreach ($group in $dirGroups) {
        if (-not ($csvGroups.Contains($group)) -and -not ($group.Contains("unused_"))) {
            Set-GroupDirectoryUnused($group)
        }
    }

    foreach ($user in $dirUsers) {
        if (-not ($csvUsers.Contains($user)) -and -not ($user.Contains("unused_"))) {
            Set-UserDirectoryUnused($user)
        }
    }

}
