. "$PSScriptRoot\..\Logger.ps1"

function find-ExistingGroup([String]$name){
  log("Looking for group GISO_${name}")
  return (Get-ADGroup -Filter {Name -eq "GISO_${name}"})
}
function add-Group([String] $name) {
  if ([bool] find-ExistingGroup $name) {
    log("Group GISO_${name} already exists")
  }
  else {
    New-ADGroup -Name "GISO_${name}" -GroupScope DomainLocal -Path "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local"
    log("Group GISO_${name} created")
  }
}
function remove-Group([String] $name) {
  Get-ADGroup -Filter {name -eq "GISO_${name}"} -SearchBase "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local" | Remove-ADGroup
  log("Group GISO_${name} deleted")
}
function retrieveAllGroups(){
  return (Get-ADGroup -Filter {name -like "*"} -SearchBase "OU=$global:groupOU,OU=$global:mainOU,DC=m122g,DC=local")
}