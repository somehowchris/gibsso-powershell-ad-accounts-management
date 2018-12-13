function convertXmlToCsv {
    param (
        [Parameter(mandatory=$true)] [String]$inputPath,
        [Parameter(mandatory=$true)] [String]$outputPath,
        [Parameter(mandatory=$false)] [String]$outputEncoding = "UTF8"
    )
    
    # Read from file
    [xml]$inputFile = Get-Content $inputPath

    # Set separator in file
    Set-Content -Value "sep=;" -Path $outputPath -Encoding $outputEncoding

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
    foreach($course in $courses){
        $course.ParentNode.RemoveChild($course) | Out-Null
    }

    # Remove "profile"
    $profiles = $inputFile.SelectNodes('//ad/schueler/profile')
    foreach($profile in $profiles){
        $profile.ParentNode.RemoveChild($profile) | Out-Null
    }

    # Export xml as csv
    $inputFile.ad.schueler | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Add-Content -Path $outputPath -Encoding $outputEncoding
}

convertXmlToCsv -inputPath "$PSScriptRoot\..\Ressources\gibsso_AD-Export.xml" -outputPath "$PSScriptRoot\..\Ressources\gibsso_AD-Export.csv"