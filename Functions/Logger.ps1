function log($message) {
  Write-Output "$(Get-TimeStamp) ${message}" | Out-file C:\.txt -append
}