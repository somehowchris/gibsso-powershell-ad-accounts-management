. "$PSScriptRoot\..\Logger.ps1"
function add-Group([String] $name) {
  if ([bool] (Get-ADGroup -Filter {name -eq $name})) {
    Write-Host "Group does already exist!"
    log("Group ${name} already exists");
  }
  else {
    New-ADGroup -Name $name -GroupScope DomainLocal -Path "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local"
    log("Group ${name} created")
  }
}
function update-Group {}
function remove-Group {
  Get-ADGroup -Filter {name -eq $name} -searchBase "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local"
function retreiveAllGroups(){
  return (Get-ADGroup -Filter {name -like "*"})
}