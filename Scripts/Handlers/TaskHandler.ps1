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
        if (-not $groups.Contains($schueler.stammklasse)) {
            add-Group($schueler.stammklasse);
        }
        if (-not $groups.Contains($schueler.zweitausbildung_stammklasse) -and $schueler.zweitausbildung_stammklasse -not $null) {
            add-Group($schueler.zweitausbildung_stammklasse);
        }
    }
    log("Finished task creating groups");
}
function deactivateNotMentionedUsers {
    $ADUsers = retrieve-AllAdUsers
    Write-Host $ADGroups

    foreach ($adUser in $ADUsers) {
        $mentioned = $false
        foreach ($schueler in $global:csvContent) {
            if (-not $mentioned -and $schueler.username -eq $adUser.username) {
                $mentioned = $true
            }
        }
        if (-not $mentioned) {
            disable-Account($adUser.username);
        }
    }
}
function deleteNotMentionedGroups {
    $groups = @()
    foreach ($schueler in $global:csvContent) {
        if (-not $groups.Contains($schueler.stammklasse)) {
            $groups += $schueler.stammklasse
        }
        if (-not $groups.Contains($schueler.zweitausbildung_stammklasse) -and $schueler.zweitausbildung_stammklasse) {
            $groups += $schueler.zweitausbildung_stammklasse
        }
    }
    $ADGroups = retrieveAllGroups

    foreach ($group in $ADGroups) {
        if (-not $groups.Contains($group.name)) {

        }
    }

}
function assosiateAccountsToGroups {
    foreach ($user in retrieve-AllADUsers) {
        getGroupsofUser $user.SamAccountName
    }
}
function createGroupDirectory {}
function setGroupDirectoryPermissions {}
function createUserDirectory {}
function setUserDirectoryPermissions {}
function renameUnusedDirectories {}
