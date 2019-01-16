function create-Directory($dir) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -type directory -Path $dir | Out-Null
    }
}
function set-DirectoryUnused($base, $addon) {
    # check if unused already exists
    if (Test-Path -Path (Join-Path -Path $base -ChildPath $addon)) {
        Rename-Item -Path (Join-Path -Path $base -ChildPath $addon) -newName (Join-Path -Path $base -ChildPath "unused_${addon}") | Out-Null
    }
}
function reuseDirectory($base, $addon) {
    if (Test-Path -Path (Join-Path -Path $base -ChildPath "unused_${addon}")) {
        Rename-Item -Path (Join-Path -Path $base -ChildPath "unused_${addon}") -newName (Join-Path -Path $base -ChildPath $addon) | Out-Null
    }
}

function give-PermissionToDirectory($name, $path) {
    $readWrite = [System.Security.AccessControl.FileSystemRights]"FullControl"
    $inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $propagationFlag = [System.Security.AccessControl.PropagationFlags]"InheritOnly"
    $type = [System.Security.AccessControl.AccessControlType]::Allow

    $accessControlEntryRW = New-Object System.Security.AccessControl.FileSystemAccessRule($name, $readWrite, $inheritanceFlag, $propagationFlag, $type)

    $objACL = Get-ACL $path
    
    $objACL.AddAccessRule($accessControlEntryRW)  

    Set-ACL $path $objACL
}
function createGroupDirectory([String]$name) {
    switch (doesGroupDirectoryExist($name)) {
        $true {
            log("Directory for group ${name} already created");
        }
        "unused" {
            if ($global:reuseUnusedDirecotires -eq "1") {
                reuseDirectory $global:baseGroupDirectory $name
                log("Unused directory for group ${name}. Reusing that.")
            }
            else {
                log("Unused directory for group ${name}. Creating new one.")
                Remove-Item -Path (get-UnusedGroupPath($name)) | Out-Null
                $path = (get-GroupPath($name))
                create-Directory($path)
                give-PermissionToDirectory $name $path
            }
        }
        Default {
            log("No Directory for ${name} found")
            $path = (get-GroupPath($name))
            create-Directory($path)
            give-PermissionToDirectory $name $path
        }
    }
}
function createUserDirectory([String]$username) {
    switch (doesUserDirectoryExist($username)) {
        $true {
            log("Directory for user ${username} already created");
        }
        "unused" {
            if ($global:reuseUnusedDirecotires -eq "1") {
                reuseDirectory ($global:baseUserDirectory)  ($username)
                log("Unused directory for user ${username}. Reusing that.")
            }
            else {
                log("Unused directory for user ${username}. Creating new one.")
                Remove-Item -Path (get-UnusedUserPath($username)) | Out-Null
                $path = (get-UserPath($username))
                create-Directory($path)
                give-PermissionToDirectory $username $path
            }
        }
        Default {
            log("Not Directory for ${username}")
            $path = (get-UserPath($username))
            create-Directory($path)
            give-PermissionToDirectory $username $path
        }
    }
}
function setGroupDirectoryUnused([String]$name) {
    if (Test-Path -Path (get-GroupPath($name))) {
        set-DirectoryUnused $global:baseGroupDirectory $name
    }
}
function setUserDirectoryUnused($name) {
    if (Test-Path -Path (get-UserPath($name))) {
        set-DirectoryUnused $global:baseUserDirectory $name 
    }
}

function get-UserPath($username) {
    return (Join-Path -Path $global:baseUserDirectory -ChildPath $username)
}
function get-UnusedUserPath($username) {
    return (Join-Path -Path $global:baseUserDirectory -ChildPath "unused_${username}")
}
function get-GroupPath($name) {
    return (Join-Path -Path $global:baseGroupDirectory -ChildPath $name)
}
function get-UnusedGroupPath($name) {
    return (Join-Path -Path $global:baseGroupDirectory -ChildPath "unused_${name}")
}

function doesUserDirectoryExist($username) {
    if (Test-Path -Path (get-UserPath($username))) {
        return $true
    }
    elseif (Test-Path -Path (get-UnusedUserPath($username))) {
        return "unused"
    }
    else {
        return $false
    }
}
function doesGroupDirectoryExist($name) {
    if (Test-Path -Path (get-GroupPath($name))) {
        return $true
    }
    elseif (Test-Path -Path (get-UnusedGroupPath($name))) {
        return "unused"
    }
    else {
        return $false
    }
}

function get-AllGroupsByDirectories() {
    return ((Get-ChildItem -Directory -Path $global:baseGroupDirectory).Name)
}
function get-AllUsersByDirectories() {
    return ((Get-ChildItem -Directory -Path $global:baseUserDirectory).Name)
}