function Convert-XmlToCsv {
    try {
        # Read from file
        [xml]$inputFile = Get-Content $global:xmlPath

        # Remove old and create new CSV
        Remove-Item $global:CSVPath -Force | Out-Null
        New-Item $global:CSVPath -ItemType File -Force | Out-Null

        # Set separator in file
        #Set-Content -Value "sep=;" -Path $global:CSVPath -Encoding $global:Encoding

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
        } # | ConvertTo-Csv -NoTypeInformation -Delimiter ";"| Add-Content -Path $global:CSVPath -Encoding $global:Encoding

        # Export xml as csv
        $inputFile.ad.schueler  | Where-Object {$_.status -eq "1"} | ForEach-Object {
            if ($_.username.length -gt 20) {
                $_.username = $_.username.substring(0, 20)
            }
        }

        $inputFile.ad.schueler  | Where-Object {$_.status -eq "1"} |  ConvertTo-Csv -NoTypeInformation -Delimiter ";"| Add-Content -Path $global:CSVPath -Encoding $global:Encoding
    }
    catch {
        Logger("Failed construcing csv from xml")
    }
}
function Read-CSV {
    try {
        $global:csvContent = Import-Csv -Delimiter ";" -Path $global:CSVPath -Encoding $global:Encoding
    }
    catch {
        Logger("Failed reading csv")
    }
}