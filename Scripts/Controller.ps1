. "$PSScriptRoot\Logger.ps1"
log("Loading Config")
. "$PSScriptRoot\Config.ps1"
. "$PSScriptRoot\Handlers\FlowHandler.ps1"

log("Initting scripts")
initial-userInput


