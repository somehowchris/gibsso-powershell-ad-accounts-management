function convert2CSV($path, $outpath) {
  [xml]$XamlDocument = Get-Contenct $path
  $XamlDocument | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Set-Content -Path $outpath -Encoding UTF8
}