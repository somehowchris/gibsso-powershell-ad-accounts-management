. "$PSScriptRoot\Logger.ps1"

Logger("Loading Config")

. "$PSScriptRoot\Config.ps1"
. "$PSScriptRoot\Handlers\FlowHandler.ps1"

Logger("Init scripts")

Initial-UserInput
