. "$PSScriptRoot\..\Logger.ps1"

function find-ExistingGroup([String]$name){
  log("Looking for group ${name}")
  return (Get-ADGroup -Filter {Name -eq $name})
}
function add-Group([String] $name) {
  if ([bool] find-ExistingGroup $name) {
    log("Group ${name} already exists")
  }
  else {
    New-ADGroup -Name $name -GroupScope DomainLocal -Path "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local"
    log("Group ${name} created")
  }
}
function remove-Group([String] $name) {
  Get-ADGroup -Filter {name -eq $name} -SearchBase "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local" | Remove-ADGroup
}
function retrieveAllGroups(){
  return (Get-ADGroup -Filter {name -like "*"} -SearchBase "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local")
}