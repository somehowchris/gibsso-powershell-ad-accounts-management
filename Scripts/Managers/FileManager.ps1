function convert-XmlToCsv {
  # Read from file
  [xml]$inputFile = Get-Content $global:xmlPath

  # Remove old and create new CSV
  Remove-Item $global:csvPath -Force | Out-Null
  New-Item $global:csvPath -ItemType File -Force | Out-Null

  # Set separator in file
  #Set-Content -Value "sep=;" -Path $global:csvPath -Encoding $global:encoding

  # Create fields for "stammklasse" und "zweitausbildung_stammklasse"
  $inputFile.ad.schueler | ForEach-Object {
    $stammklasse = $inputFile.CreateElement("stammklasse")
    $stammklasse.set_InnerText($_.profile.profil.stammklasse)
    $_.AppendChild($stammklasse) | Out-Null

    if ($_.profile.profil.zweitausbildung_stammklasse) {
      $zweitausbildung_stammklasse = $inputFile.CreateElement("zweitausbildung_stammklasse")
      $zweitausbildung_stammklasse.set_InnerText($_.profile.profil.zweitausbildung_stammklasse)
      $_.AppendChild($zweitausbildung_stammklasse) | Out-Null
    }
  }

  # Remove "kurse"
  $courses = $inputFile.SelectNodes('//ad/schueler/kurse')
  foreach ($course in $courses) {
    $course.ParentNode.RemoveChild($course) | Out-Null
  }

  # Remove "profile"
  $profiles = $inputFile.SelectNodes('//ad/schueler/profile')
  foreach ($profile in $profiles) {
    $profile.ParentNode.RemoveChild($profile) | Out-Null
  }

  # Export xml as csv
  $inputFile.ad.schueler | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Add-Content -Path $global:csvPath -Encoding $global:encoding

}

function read-Csv {
  # TODO Remove Select-Object for only the first 25
  $global:csvContent = Import-Csv -Delimiter ";" -Path $global:csvPath -Encoding $global:encoding 
}