function Create-Directory($dir) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -type directory -Path $dir | Out-Null
    }
}
function Set-DirectoryUnused($base, $addon) {
    # check if unused already exists
    if (Test-Path -Path (Join-Path -Path $base -ChildPath $addon)) {
        Rename-Item -Path (Join-Path -Path $base -ChildPath $addon) -newName (Join-Path -Path $base -ChildPath "unused_${addon}") | Out-Null
    }
}
function Reuse-Directory($base, $addon) {
    if (Test-Path -Path (Join-Path -Path $base -ChildPath "unused_${addon}")) {
        Rename-Item -Path (Join-Path -Path $base -ChildPath "unused_${addon}") -newName (Join-Path -Path $base -ChildPath $addon) | Out-Null
    }
}

function Give-PermissionForDirectory($name, $path) {
    $readWrite = [System.Security.AccessControl.FileSystemRights]"FullControl"
    $inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
    $propagationFlag = [System.Security.AccessControl.PropagationFlags]"InheritOnly"
    $type = [System.Security.AccessControl.AccessControlType]::Allow

    $accessControlEntryRW = New-Object System.Security.AccessControl.FileSystemAccessRule($name, $readWrite, $inheritanceFlag, $propagationFlag, $type)

    $objACL = Get-ACL $path
    
    $objACL.AddAccessRule($accessControlEntryRW)  

    Set-ACL $path $objACL
}
function Create-GroupDirectory([String]$name) {
    switch (Does-GroupDirectoryExist($name)) {
        $true {
            Logger("Directory for group ${name} already created");
        }
        "unused" {
            if ($global:ReuseUnusedDirecotires -eq "1") {
                Reuse-Directory $global:BaseGroupDirectory $name
                Logger("Unused directory for group ${name}. Reusing that.")
            }
            else {
                Logger("Unused directory for group ${name}. Creating new one.")
                Remove-Item -Path (Get-UnusedGroupPath($name)) | Out-Null
                $path = (Get-GroupPath($name))
                Create-Directory($path)
                Give-PermissionForDirectory $name $path
            }
        }
        Default {
            Logger("No Directory for ${name} found")
            $path = (Get-GroupPath($name))
            Create-Directory($path)
            Give-PermissionForDirectory $name $path
        }
    }
}
function Create-UserDirectory([String]$username) {
    switch (Does-UserDirectoryExist($username)) {
        $true {
            Logger("Directory for user ${username} already created");
        }
        "unused" {
            if ($global:ReuseUnusedDirecotires -eq "1") {
                Reuse-Directory ($global:BaseUserDirectory)  ($username)
                Logger("Unused directory for user ${username}. Reusing that.")
            }
            else {
                Logger("Unused directory for user ${username}. Creating new one.")
                Remove-Item -Path (Get-UnusedUserPath($username)) | Out-Null
                $path = (Get-UserPath($username))
                Create-Directory($path)
                Give-PermissionForDirectory $username $path
            }
        }
        Default {
            Logger("Not Directory for ${username}")
            $path = (Get-UserPath($username))
            Create-Directory($path)
            Give-PermissionForDirectory $username $path
        }
    }
}
function Set-GroupDirectoryUnused([String]$name) {
    if (Test-Path -Path (Get-GroupPath($name))) {
        Set-DirectoryUnused $global:BaseGroupDirectory $name
    }
}
function Set-UserDirectoryUnused($name) {
    if (Test-Path -Path (Get-UserPath($name))) {
        Set-DirectoryUnused $global:BaseUserDirectory $name 
    }
}

function Get-UserPath($username) {
    return (Join-Path -Path $global:BaseUserDirectory -ChildPath $username)
}
function Get-UnusedUserPath($username) {
    return (Join-Path -Path $global:BaseUserDirectory -ChildPath "unused_${username}")
}
function Get-GroupPath($name) {
    return (Join-Path -Path $global:BaseGroupDirectory -ChildPath $name)
}
function Get-UnusedGroupPath($name) {
    return (Join-Path -Path $global:BaseGroupDirectory -ChildPath "unused_${name}")
}

function Does-UserDirectoryExist($username) {
    if (Test-Path -Path (Get-UserPath($username))) {
        return $true
    }
    elseif (Test-Path -Path (Get-UnusedUserPath($username))) {
        return "unused"
    }
    else {
        return $false
    }
}
function Does-GroupDirectoryExist($name) {
    if (Test-Path -Path (Get-GroupPath($name))) {
        return $true
    }
    elseif (Test-Path -Path (Get-UnusedGroupPath($name))) {
        return "unused"
    }
    else {
        return $false
    }
}

function Get-AllGroupsByDirectorie() {
    return ((Get-ChildItem -Directory -Path $global:BaseGroupDirectory).Name)
}
function Get-AllUsersByDirectories() {
    return ((Get-ChildItem -Directory -Path $global:BaseUserDirectory).Name)
}