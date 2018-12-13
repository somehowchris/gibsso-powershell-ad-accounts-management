function log($message) {
  Write-Output "$(Get-TimeStamp) ${message}" | Out-file "${$PSScriptRoot}/.log" -append
}

