function log($message) {
  Write-Output "$("[{0:dd/MM/yy} {0:HH:mm:ss}]" -f (Get-Date)) ${message}" | Out-file "./.log" -append
}

