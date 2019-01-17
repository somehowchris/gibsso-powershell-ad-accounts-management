function Logger($message) {
  Write-Output "$("[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)) ${message}" | Out-file C:\.txt -append
}