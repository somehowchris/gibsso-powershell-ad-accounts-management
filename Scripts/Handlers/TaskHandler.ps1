. "$PSScriptRoot\..\Managers\FileManager.ps1"
. "$PSScriptRoot\..\Managers\AccountManager.ps1"
. "$PSScriptRoot\..\Managers\GroupManager.ps1"
. "$PSScriptRoot\..\Managers\DirectoryManager.ps1"

function XMLtoCSV {
    convert-XmlToCsv
}
function loadCSV {
    read-Csv
}
function createOrUpdateUsers {
    foreach ($schueler in $global:csvContent) {
        add-Account $($schueler).username $($schueler).name $($schueler).vorname

        add-AccountToGroup $($schueler).username $($schueler).stammklasse
        if ($($schueler).zweitausbildung_stammklasse -ne ""){
            add-AccountToGroup $($schueler).username $($schueler).zweitausbildung_stammklasse
        }
    }
}
function createOrUpdateGroups {
    $groupsHT = @{}
    $groupsHTValue = @()
    foreach ($schueler in $global:csvContent) {
        $groupsHTValue = @();
        if ($groupsHT.ContainsKey($($schueler).stammklasse)) {
            $groupsHTValue = $groupsHT[$($schueler).stammklasse]
            $groupsHTValue += $schueler
        } else {
            $groupsHTValue = $schueler
        }
        $groupsHT.$($schueler).stammklasse = $schueler
    }
}
function deactivateNotMentionedUsers {}
function deleteNotMentionedGroups {}
function assosiateAccountsToGroups {}
function createGroupDirectory {}
function setGroupDirectoryPermissions {}
function createUserDirectory {}
function setUserDirectoryPermissions {}
function renameUnusedDirectories {}
