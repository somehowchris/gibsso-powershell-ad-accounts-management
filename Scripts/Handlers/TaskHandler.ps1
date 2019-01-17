. "$PSScriptRoot\..\Managers\FileManager.ps1"
. "$PSScriptRoot\..\Managers\AccountManager.ps1"
. "$PSScriptRoot\..\Managers\GroupManager.ps1"
. "$PSScriptRoot\..\Managers\DirectoryManager.ps1"
. "$PSScriptRoot\..\Logger.ps1"

function XMLtoCSV {
    Logger-WithMessage("Converting XML to CSV");
    Convert-XmlToCsv
}
function Load-CSV {
    Logger-WithMessage("Loading CSV");
    Read-CSV
}
function Create-Users {
    Logger-WithMessage("Creating user accounts");
    foreach ($schueler in $global:csvContent) {
        Logger("Create user $($schueler.username)")
        Add-Account $($schueler).username $($schueler).name $($schueler).vorname
    }
}
function Create-Groups {
    Logger-WithMessage("Creating groups");
    $groups = @()
    foreach ($schueler in $global:csvContent) {
        if (-not $groups.Contains($schueler.stammklasse) -and -not ([string]::IsNullOrEmpty($schueler.stammklasse))) {
            Logger("Creating group $($schueler.stammklasse)")
            Add-Group($schueler.stammklasse);
        }
        if (-not $groups.Contains($schueler.zweitausbildung_stammklasse) -and -not ([string]::IsNullOrEmpty($schueler.zweitausbildung_stammklasse))) {
            Logger("Creating group $($schueler.zweitausbildung_stammklasse)")
            Add-Group($schueler.zweitausbildung_stammklasse);
        }
    }
    Logger("Finished creating $($groups.Length) groups");
}
function Deactivate-NotRequieredUsers {
    Logger-WithMessage("Deactivating not mentioned users");
    $ADUsers = Get-AllADUsers
    foreach ($adUser in $ADUsers) {
        $mentioned = $false
        foreach ($schueler in $global:csvContent) {
            if (-not $mentioned -and $schueler.username -eq $adUser.SamAccountName) {
                $mentioned = $true
            }
        }
        if (-not $mentioned -and $adUser.SamAccountName.Contains(".") -and $adUser.Enabled) {
            Logger("Disabling user $($adUser.SamAccountName)")
            Disable-Account($adUser.SamAccountName);
        }
    }
}
function Delete-NotRequieredGroups {
    Logger-WithMessage("Deleting not mentioned groups");
    $groups = Get-AllGroupsFromCSV
    $ADGroups = Get-AllADGroups
    foreach ($group in $ADGroups) {
        if (-not $groups.Contains($group.name)) {
            Logger("Removing group $($group.name)")
            Remove-Group($group.name)
        }
    }
}
function Assosiate-UsersToGroups {
    Logger-WithMessage("Adding users to groups");
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
    Logger-WithMessage("Removing not permitted users from groups");
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
    Logger-WithMessage("Creating group directories");
    $groups = Get-AllGroupsFromCSV
    foreach ($group in $groups) {
        Create-GroupDirectory($group)
    }
}
function Create-UserDirectories {
    Logger-WithMessage("Creating user directories");
    foreach ($schueler in $global:csvContent) {
        Create-UserDirectory($schueler.username)
    }
}
function Rename-OldDirectories {
    Logger-WithMessage("Renaming all not needed folders to unused");
    $dirUsers = Get-AllUsersByDirectories
    $dirGroups = Get-AllGroupsByDirectories
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
