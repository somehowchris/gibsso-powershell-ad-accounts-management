function log($message) {
  $dir = get-location | Select -Property Path
  Write-Output "$(Get-TimeStamp) ${message}" | Out-file "${dir}/log.txt" -append
}