function Create-Directory($dir) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -type directory -Path $dir | Out-Null
    }
}
function Set-DirectoryUnused($base, $addon, $nr) {
    try {
        if (Test-Path -Path (Join-Path -Path $base -ChildPath $addon)) {
            if (Test-Path -Path (Join-Path -Path $base -ChildPath "unused_${addon}${nr}")) {
                if ([String]::IsNullOrEmpty()) {
                    $nr = 0
                } else {
                    $nr = $nr + 1
                }
                Set-DirectoryUnused $base $addon $nr
            } else {
                Logger("Renaming $addon to unused")
                Rename-Item -Path (Join-Path -Path $base -ChildPath $addon) -newName (Join-Path -Path $base -ChildPath "unused_${addon}${nr}") | Out-Null
            }
        }
    }
    catch {
        Logger("Failed renaming $addon to unused")
    }
}
function Reuse-Directory($base, $addon) {
    try {
        if (Test-Path -Path (Join-Path -Path $base -ChildPath "unused_${addon}")) {
            Logger("Reusing $addon")
            Rename-Item -Path (Join-Path -Path $base -ChildPath "unused_${addon}") -newName (Join-Path -Path $base -ChildPath $addon) | Out-Null
        }
    }
    catch {
        Logger("Failed resuing $addon")
    }
}

function Give-PermissionForDirectory($name, $path) {
    try {
        $readWrite = [System.Security.AccessControl.FileSystemRights]"FullControl"
        $inheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
        $propagationFlag = [System.Security.AccessControl.PropagationFlags]"InheritOnly"
        $type = [System.Security.AccessControl.AccessControlType]::Allow

        $accessControlEntryRW = New-Object System.Security.AccessControl.FileSystemAccessRule($name, $readWrite, $inheritanceFlag, $propagationFlag, $type)

        $objACL = Get-ACL $path
        
        $objACL.AddAccessRule($accessControlEntryRW)  

        Set-ACL $path $objACL
        Logger("Gave $name permissions to $path")
    }
    catch {
        Logger("Failed givin permissions for $path to $name")
    }
}
function Create-GroupDirectory([String]$name) {
    try{
        switch (Does-GroupDirectoryExist($name)) {
            $true {
                Logger("Directory for group ${name} already created");
                $path = (Get-GroupPath($name))
                Give-PermissionForDirectory $name $path
            }
            "unused" {
                if ($global:ReuseUnusedDirecotires -eq "1") {
                    Reuse-Directory $global:BaseGroupDirectory $name
                    Logger("Unused directory for group ${name} found. Reusing that.")
                }
                else {
                    Logger("Unused directory for group ${name} found. Creating new one.")
                    Remove-Item -Path (Get-UnusedGroupPath($name)) | Out-Null
                    $path = (Get-GroupPath($name))
                    Create-Directory($path)
                    Give-PermissionForDirectory $name $path
                }
            }
            Default {
                Logger("Creating directory for ${name}")
                $path = (Get-GroupPath($name))
                Create-Directory($path)
                Give-PermissionForDirectory $name $path
            }
        }
    }catch{
        Logger("Failed creating directory for $name")
    }
}
function Create-UserDirectory([String]$username) {
    try {
        switch (Does-UserDirectoryExist($username)) {
            $true {
                Logger("Directory for user ${username} already created");
                $path = (Get-UserPath($username))
                Give-PermissionForDirectory $username $path
            }
            "unused" {
                if ($global:ReuseUnusedDirecotires -eq "1") {
                    Reuse-Directory ($global:BaseUserDirectory)  ($username)
                    Logger("Unused directory for user ${username} found. Reusing that.")
                }
                else {
                    Logger("Unused directory for user ${username} found. Creating new one.")
                    Remove-Item -Path (Get-UnusedUserPath($username)) | Out-Null
                    $path = (Get-UserPath($username))
                    Create-Directory($path)
                    Give-PermissionForDirectory $username $path
                }
            }
            Default {
                Logger("Creating directory for ${username}")
                $path = (Get-UserPath($username))
                Create-Directory($path)
                Give-PermissionForDirectory $username $path
            }
        }
    }catch{
        Logger("Failed creating directory for $username")
    }
}
function Set-GroupDirectoryUnused([String]$name) {
    try{
        if (Test-Path -Path (Get-GroupPath($name))) {
            Set-DirectoryUnused $global:BaseGroupDirectory $name ""
        }
    }catch{
        Logger("Failed setting group directory unused")
    }
}
function Set-UserDirectoryUnused($name) {
    try{
        if (Test-Path -Path (Get-UserPath($name))) {
            Set-DirectoryUnused $global:BaseUserDirectory $name ""
        }
    }catch {
        Logger("Failed setting user directory unused")
    }
}

function Get-UserPath($username) {
    try{ 
        return (Join-Path -Path $global:BaseUserDirectory -ChildPath $username)
    }catch {
        Logger("Failed construcing user path")
    }
}
function Get-UnusedUserPath($username) {
    try{
        return (Join-Path -Path $global:BaseUserDirectory -ChildPath "unused_${username}")
    }catch {
        Logger("Failed construcing unused user path")
    }
}
function Get-GroupPath($name) {
    try{
        return (Join-Path -Path $global:BaseGroupDirectory -ChildPath $name)
    }catch {
        Logger("Failed construcing group path")
    }
}
function Get-UnusedGroupPath($name) {
    try{
        return (Join-Path -Path $global:BaseGroupDirectory -ChildPath "unused_${name}")
    }catch {
        Logger("Failed construcing unused group path")
    }
}

function Does-UserDirectoryExist($username) {
    try{
        if (Test-Path -Path (Get-UserPath($username))) {
            return $true
        }
        else {
            return $false
        }
    }catch {
        Logger("Failed checking if user directory exists")
    }
}
function Does-GroupDirectoryExist($name) {
    try{
        if (Test-Path -Path (Get-GroupPath($name))) {
            return $true
        }
        else {
            return $false
        }
    }catch {
        Logger("Failed checking if group directory exists")
    }
}

function Get-AllGroupsByDirectories() {
    try{
        return ((Get-ChildItem -Directory -Path $global:BaseGroupDirectory).Name)
    }catch {
        Logger("Failed getting all groups by directory names")
    }
}
function Get-AllUsersByDirectories() {
    try{
        return ((Get-ChildItem -Directory -Path $global:BaseUserDirectory).Name)
    }catch {
        Logger("Failed getting all users by directory names")
    }
}