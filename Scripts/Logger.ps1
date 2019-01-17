function Logger($message) {
    Write-Output "$("[{0:dd/MM/yy} {0:HH:mm:ss}]" -f (Get-Date)) ${message}" | Out-file "./.log" -append
}
function Logger-WithMessage($message) {
    Logger($message)
    Write-Host $messge
}

