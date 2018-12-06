function convert2CSV($path) {
  [xml]$XamlDocument = Get-Contenct c:\Cars.xml
  $inputFile.Transaction.TXNHEAD | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Set-Content -Path "c:\pstest\test.csv" -Encoding UTF8
}