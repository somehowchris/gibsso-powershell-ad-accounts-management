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

    # Export xml as csv
    $inputFile.ad.schueler | ConvertTo-Csv -NoTypeInformation -Delimiter ";" | Add-Content -Path $outputPath -Encoding $outputEncoding
}

convertXmlToCsv -inputPath "$PSScriptRoot\..\Ressources\gibsso_AD-Export.xml" -outputPath "$PSScriptRoot\..\Ressources\gibsso_AD-Export.csv"