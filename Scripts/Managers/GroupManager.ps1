function add-Group([String] $name) {
    if([bool] (Get-ADGroup -Identity $name)) {
        Write-Host "Group does already exist!"
    } else {
        New-ADGroup -Name $name -GroupScope DomainLocal -Path "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local"
    }
}
function update-Group {}
function disable-Group {}