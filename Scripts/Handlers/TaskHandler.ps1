. "$PSScriptRoot\..\Managers\FileManager.ps1"
. "$PSScriptRoot\..\Managers\AccountManager.ps1"
. "$PSScriptRoot\..\Managers\GroupManager.ps1"
. "$PSScriptRoot\..\Managers\DirectoryManager.ps1"
. "$PSScriptRoot\..\Logger.ps1"

function XMLtoCSV {
    log("Converting XML to CSV");
    convert-XmlToCsv
}
function loadCSV {
    log("Loading CSV");
    read-Csv
}
function createOrUpdateUsers {
    foreach ($schueler in $global:csvContent) {
        add-Account $($schueler).username $($schueler).name $($schueler).vorname
    }
}
function createOrUpdateGroups {
    $groups = @()
    foreach ($schueler in $global:csvContent) {
        if (-not $groups.Contains($schueler.stammklasse) -and -not ([string]::IsNullOrEmpty($schueler.stammklasse))) {
            add-Group($schueler.stammklasse);
        }
        if (-not $groups.Contains($schueler.zweitausbildung_stammklasse) -and -not ([string]::IsNullOrEmpty($schueler.zweitausbildung_stammklasse))) {
            add-Group($schueler.zweitausbildung_stammklasse);
        }
    }
    log("Finished task creating groups");
}
function deactivateNotMentionedUsers {
    $ADUsers = retrieve-AllAdUsers

    foreach ($adUser in $ADUsers) {
        $mentioned = $false
        foreach ($schueler in $global:csvContent) {
            if (-not $mentioned -and $schueler.username -eq $adUser.SamAccountName) {
                $mentioned = $true
            }
        }
        if (-not $mentioned -and $adUser.SamAccountName.Contains(".") -and $adUser.Enabled) {
            disable-Account($adUser.SamAccountName);
        }
    }
}
function deleteNotMentionedGroups {
    $groups = get-AllGroupsFromCSV
    $ADGroups = retrieveAllGroups
    foreach ($group in $ADGroups) {
        if (-not $groups.Contains($group.name)) {
            remove-Group($group.name)
        }
    }

}
function assosiateAccountsToGroups {
    $GroupsPerPerson = @{}
    foreach ($schueler in $global:csvContent) {
        add-AccountToGroup $schueler.username $schueler.stammklasse 
        $GroupsPerPerson[$schueler.username] = @()
        $GroupsPerPerson[$schueler.username] += "GISO_$($schueler.stammklasse)"
        if (-not ([string]::IsNullOrEmpty($schueler.zweitausbildung_stammklasse))) {
            add-AccountToGroup $schueler.username $schueler.zweitausbildung_stammklasse
            $GroupsPerPerson[$schueler.username] += "GISO_$($schueler.zweitausbildung_stammklasse)"
        }
    }
    foreach ($user in retrieve-AllADUsers) {
        $groups = getGroupsofUser $user.SamAccountName
        foreach ($group in $groups) {
            if ($GroupsPerPerson.ContainsKey($user.SamAccountName)) {
                if (-not $GroupsPerPerson[$user.SamAccountName].Contains($group.SamAccountName)) {
                    remove-AccountFromGroup $user.SamAccountName $group.SamAccountName
                }
            }
            else {
                remove-AccountFromGroup $user.SamAccountName $group.SamAccountName
            }
        }
    }
}
function createGroupDirectories {
    $groups = get-AllGroupsFromCSV
    foreach ($group in $groups) {
        createGroupDirectory($group)
    }
}
function createUserDirectories {
    foreach ($schueler in $global:csvContent) {
        createUserDirectory($schueler.username)
    }
}
function renameUnusedDirectories {
    $dirUsers = get-AllUsersByDirectories
    $dirGroups = get-AllGroupsByDirectories
    $csvGroups = get-AllGroupsFromCSV
    $csvUsers = get-AllUserNamesFromCSV

    foreach ($group in $dirGroups) {
        if (-not ($csvGroups.Contains($group)) -and -not ($group.Contains("unused_"))) {
            setGroupDirectoryUnused($group)
        }
    }

    foreach ($user in $dirUsers) {
        if (-not ($csvUsers.Contains($user)) -and -not ($user.Contains("unused_"))) {
            setUserDirectoryUnused($user)
        }
    }

}
