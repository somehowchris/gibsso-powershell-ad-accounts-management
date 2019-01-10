function convert-XmlToCsv() {
    # Read from file
    [xml]$global:xmlPath = Get-Content $global:csvPath

    # Set separator in file
    Set-Content -Value "sep=;" -Path $global:csvPath -Encoding $global:encoding

    # Create fields for "stammklasse" und "zweitausbildung_stammklasse"
    $global:xmlPath.ad.schueler | ForEach-Object {
        $stammklasse = $global:xmlPath.CreateElement("stammklasse")
        $stammklasse.set_InnerText($_.profile.profil.stammklasse)
        $_.AppendChild($stammklasse) | Out-Null

        if ($_.profile.profil.zweitausbildung_stammklasse) {
            $zweitausbildung_stammklasse = $global:xmlPath.CreateElement("zweitausbildung_stammklasse")
            $zweitausbildung_stammklasse.set_InnerText($_.profile.profil.zweitausbildung_stammklasse)
            $_.AppendChild($zweitausbildung_stammklasse) | Out-Null
        }
    }

    # Remove "kurse"
    $courses = $global:xmlPath.SelectNodes('//ad/schueler/kurse')
    foreach($course in $courses){
        $course.ParentNode.RemoveChild($course) | Out-Null
    }

    # Remove "profile"
    $profiles = $global:xmlPath.SelectNodes('//ad/schueler/profile')
    foreach($profile in $profiles){
        $profile.ParentNode.RemoveChild($profile) | Out-Null
    }

    # Export xml as csv
    $global:xmlPath.ad.schueler | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Add-Content -Path $global:csvPath -Encoding $global:encoding

}

function read-Csv() {
    $global:csvContent = (Import-Csv -Delimiter ";" -Path $global:csvPath)
}