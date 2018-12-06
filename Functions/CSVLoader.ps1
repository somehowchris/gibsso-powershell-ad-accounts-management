function loadCsv($path) {
  return (Import-Csv -Delimiter ";" -Path $path)
}