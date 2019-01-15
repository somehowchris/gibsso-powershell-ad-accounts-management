function create-Directory() {
    # create a new directory
}
function set-DirectoryUnused() {
    # rename folder with added unsuded_
}
function is-direcotryCreated() {
    <# lookup used and unsued folders#>  
}

function give-UserPermissionToDirecotry($user, $path) {

}
function remove-UserPermissionFromDirectory($user, $path) {
    
}

function createGroupDirecotry([String]$name) {
    $UserPath = Join-Path -Path $global:baseGroupDirecotry -ChildPath $name
    $UnusedPath = Join-Path -Path 
    # forward to create-Direcotry with specific path
}
function createUserDirectory([String]$username) {
    $Path = Join-Path -Path $global:baseUserDirecotry -ChildPath $username
    # forward to create-Direcotry with specific path
    switch (doesUserDirectoryExist($username)) {
        $true { 
            log("Directory for user ${username} already created");
        }
        "unused" {
            if ($global:reuseUnusedDirecotires -eq $true) {
                #TODO reuse unused
                log("Unused directory for user ${username}. Reusing that.")
            }
            else {
                log("Unused directory for user ${username}. Creating new one.")
                #TODO remove unused
                #TODO create new one
            }
            
        }
        Default {
            log("Not Directory for ${username}")
            # TODO crreate new one
        }
    }
}
function addUserToGroupDirectory($groupname, $username) {
    # giving permission to user for a group directory => give-UserPermissionToDirecotry
}
function addUserToPersonalDirectorry($username) {
    # give permission to user for his person directory => remove-UserPermissionFromDirectory
}

function removeUserFromGroupDirecotry($groupname, $username) {
    # remove permission of user for a group directory
}

function setGroupDirecotryUnused([String]$name) {
    $UserPath = Join-Path -Path $global:baseGroupDirecotry -ChildPath $name
    if (!(Test-Path -Path $TARGETDIR )) {
        # TODO set unused
    }
}
function setPersonalDirectoryUnused() {
    #TODO set unused
}

function get-UserPath($username) {
    return (Join-Path -Path $global:baseUserDirecotry -ChildPath $username)
}
function get-UnusedUserPath($username) {
    return (Join-Path -Path $global:baseUserDirecotry -ChildPath "unused_${username}")
}
function get-GroupPath($username) {
    return (Join-Path -Path $global:baseUserDirecotry -ChildPath $username)
}
function get-UnusedGroupPath($username) {
    return (Join-Path -Path $global:baseUserDirecotry -ChildPath "unused_${username}")
}

function doesUserDirectoryExist($username) {
    if (Test-Path -Path get-UserPath($username)) {
        return $true
    }
    elseif (Test-Path get-UnusedUserPath($username)) {
        return "unused"
    }
    else {
        return $false
    }
}
function doesGroupDirectoryExist($username) {
    if (Test-Path -Path get-UserPath($username)) {
        return $true
    }
    elseif (Test-Path get-UnusedUserPath($username)) {
        return "unused"
    }
    else {
        return $false
    }
}

function getAll-GroupsByDirectories() {
    # TODO return all groups
}
function get-All-UsersByDirectories() {
    # TODO returrn all people
}

function get-AllPeopleWithAccesstoDirectory($Path) {}