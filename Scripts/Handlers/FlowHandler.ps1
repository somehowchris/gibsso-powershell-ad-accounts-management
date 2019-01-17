. "$PSScriptRoot\TaskHandler.ps1"
. "$PSScriptRoot\..\Logger.ps1"
function Initial-UserInput {
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
                Logger("Handing over to run full script");
                Run-FullScript
                return
            }
            '2' {
                Clear-Host
                Logger("Handing over to run paritial scripts");
                Run-SelectableScript
                return
            }
            'q' {
                Clear-Host
                Logger("Terminating by user input");
                return
            }
            Default {
                Clear-Host
                Logger("Didnt recognize user input");
                Write-Host "You didn't enter a valid option`n" -ForegroundColor Red
            }
        }
    } until ($input -eq 'q')
}
function Run-SelectableScript {
    Write-Host "Converting XML to CSV"
    Write-Host "This might take some seconds"
    XMLtoCSV
    Write-Host "Loading freshly converted CSV"
    Load-CSV

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
        Write-Host "8: Press '7' to create users directory"
        Write-Host "10: Press '8' to rename unused directories"
        Write-Host "Q: Press 'Q' to quit."

        $scriptSelection = Read-Host "`nPlease make a selection"
        switch ($scriptSelection) {
            '1' {
                Clear-Host
                Logger("Start creating and updating users");
                Create-Users
            }
            '2' {
                Clear-Host
                Logger("Start creating and updating groups");
                Create-Groups
            }
            '3' {
                Clear-Host
                Logger("Start deactivating not mentioned users");
                Deactivate-NotRequieredUsers
            }
            '4' {
                Clear-Host
                Logger("Start deleting not mentioned users");
                Delete-NotRequieredGroups
            }
            '5' {
                Clear-Host
                Logger("Start assosiating accounts to groups");
                Assosiate-UsersToGroups
            }
            '6' {
                Clear-Host
                Logger("Start creating group directories");
                Create-GroupDirectories
            }
            '7' {
                Clear-Host
                Logger("Start creaing personal directories");
                Create-UserDirectories
            }
            '8' {
                Clear-Host
                Logger("Start renaming unused directories");
                Rename-OldDirectories
            }
            'q' {
                Clear-Host
                Logger("Terminating by user input");
                return
            }
            Default {
                Clear-Host
                Logger("Didnt recognize user input");
                Write-Host "You didn't enter a valid option`n" -ForegroundColor Red
            }
        }
    } until ($input -eq 'q')
}
function Run-FullScript {
    # TODO convert XML to CSV
    XMLtoCSV

    # TODO load CSV
    Load-CSV

    # TODO run all tasks
    Create-Users
    Create-Groups
    Deactivate-NotRequieredUsers
    Delete-NotRequieredGroups
    Assosiate-UsersToGroups
    Create-GroupDirectories
    Create-UserDirectories
    Rename-OldDirectories
}