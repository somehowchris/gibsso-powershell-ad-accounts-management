. "$PSScriptRoot\TaskHandler.ps1"

function initial-userInput(){
    # TODO ask user to run selected Tasks or whole script
    Clear-Host
    do {
        Write-Host "================ Menu ================`n"

        Write-Host "1: Press '1' to run all Scripts."
        Write-Host "2: Press '2' to run selectable Script"
        Write-Host "Q: Press 'Q' to quit."

        $selection = Read-Host "`nPlease make a selection"
        switch ($selection) {
            '1' {
                Clear-Host
                run-fullScript
                return
            }
            '2' {
                Clear-Host
                run-selectableScript
                return
            }
            'q' {
                Clear-Host
                return
            }
            Default {
                Clear-Host
                Write-Host "You didn't enter a valid option`n" -ForegroundColor Red
            }
        }
    } until ($input -eq 'q')
}
function run-selectableScript {
    # TODO convert XML to CSV
    XMLtoCSV
    loadCSV

    # TODO ask user to select Script & run it
    Clear-Host
    do {
        Write-Host "================ Script selection ================`n"

        Write-Host "1: Press '1' to create or update users"
        Write-Host "2: Press '2' to create Or update groups"
        Write-Host "3: Press '3' to deactivate not mentioned users"
        Write-Host "4: Press '4' to delete not mentioned groups"
        Write-Host "5: Press '5' to assosiate accounts to groups"
        Write-Host "6: Press '6' to create group directories"
        Write-Host "7: Press '7' to set group directories permissions"
        Write-Host "8: Press '8' to create users directory"
        Write-Host "9: Press '9' to set users directory permissions"
        Write-Host "10: Press '10' to rename unused directories"
        Write-Host "Q: Press 'Q' to quit."

        $scriptSelection = Read-Host "`nPlease make a selection"
        switch ($scriptSelection) {
            '1' {
                Clear-Host
                createOrUpdateUsers
            }
            '2' {
                Clear-Host
                createOrUpdateGroups
            }
            '3' {
                Clear-Host
                deactivateNotMentionedUsers
            }
            '4' {
                Clear-Host
                deleteNotMentionedGroups
            }
            '5' {
                Clear-Host
                assosiateAccountsToGroups
            }
            '6' {
                Clear-Host
                createGroupDirectory
            }
            '7' {
                Clear-Host
                setGroupDirectoryPermissions
            }
            '8' {
                Clear-Host
                createUserDirectory
            }
            '9' {
                Clear-Host
                setUserDirectoryPermissions
            }
            '10' {
                Clear-Host
                renameUnusedDirectories
            }
            'q' {
                Clear-Host
                return
            }
            Default {
                Clear-Host
                Write-Host "You didn't enter a valid option`n" -ForegroundColor Red
            }
        }
    } until ($input -eq 'q')
}
function run-fullScript {
    # TODO convert XML to CSV
    XMLtoCSV

    # TODO load CSV
    loadCSV

    # TODO run all tasks
    createOrUpdateUsers
    createOrUpdateGroup
    deactivateNotMentionedUsers
    deleteNotMentionedGroups
    assosiateAccountsToGroups
    createGroupDirectory
    setGroupDirectoryPermissions
    createUserDirectory
    setUserDirectoryPermissions
    renameUnusedDirectories
}