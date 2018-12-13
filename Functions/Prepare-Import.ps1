[Array]$Global:KeyMap = @()
[Array]$Global:People = @()
[Array]$Global:InvalidPeople = @()

$ErrorActionPreference = "Stop"
$InvalidPeopleExport = "..\UngueltigePersonen.csv"
$ResultName = "..\AktuelleImportdatei.csv"
$ValidMailDomain = "bbzsogr.ch"
$lehrer = "lehrer"
$schueler = "schueler"

$Sources = @(
    [PSCustomObject]@{ Name = "KBS"; Url = "https://kaschuso.so.ch/adexp/kbssogr/ad/ex/kbssogr_AD-Export.xml"; Username ="adexpkbssogr"; Password = "ib1SROdKl7GyeUNi" }
    [PSCustomObject]@{ Name = "ZZ"; Url = "https://kaschuso.so.ch/adexp/zzgr/ad/ex/zzgr_AD-Export.xml"; Username ="adexpzzgr"; Password = "Ehigupute170" }
    [PSCustomObject]@{ Name = "GIBSGR"; Url = "https://kaschuso.so.ch/adexp/gibsgr/ad/ex/gibsgr_AD-Export.xml"; Username ="adexpgibsgr"; Password = "Iragepasi517" }
    [PSCustomObject]@{ Name = "GIBSSO"; Url = "https://kaschuso.so.ch/adexp/gibsso/ad/ex/gibsso_AD-Export.xml"; Username ="adexpgibsso"; Password = "Ipunokire356" }
)

$ExistingProfilePaths = @{
	"beat.jeker"="\\fileprint\Profiles3$\Beat.Jeker"
	"beat.studer"="\\fileprint\Profiles5$\beat.studer"
	"christine.glauser"="\\fileprint\Profiles3$\Christine.Glauser"
	"christoph.homberger"="\\fileprint\Profiles5$\christoph.homberger"
	"cristina.zanco"="\\fileprint\Profiles5$\Cristina.Zanco"
	"debora.horst"="\\fileprint\Profiles3$\Debora.Horst"
	"doris.banz"="\\fileprint\Profiles5$\Doris.Banz"
	"felix.heiri"="\\fileprint\Profiles3$\Felix.Heiri"
	"hans.holzach"="\\fileprint\Profiles5$\hans.holzach"
	"hans.imboden"="\\fileprint\Profiles5$\Hans.Imboden"
	"jakob.nessensohn"="\\fileprint\Profiles3$\Jakob.Nessensohn"
	"lucien.wenger"="\\fileprint\Profiles3$\Lucien.Wenger"
	"marc.mueller"="\\fileprint\Profiles3$\marc.mueller"
	"martin.jenni2"="\\fileprint\Profiles3$\Martin.Jenni"
	"myriam.lanz"="\\fileprint\Profiles3$\Myriam.Lanz"
	"othmar.kreuzer"="\\fileprint\Profiles3$\Othmar.Kreuzer"
	"peter.christ"="\\fileprint\Profiles3$\peter.christ"
	"peter.heiniger"="\\fileprint\Profiles3$\Peter.Heiniger"
	"peter.schmid"="\\fileprint\Profiles3$\Peter.Schmid"
	"regine.anderegg"="\\fileprint\Profiles3$\Regine.Anderegg"
	"rene.hirt"="\\fileprint\Profiles3$\Rene.Hirt"
	"roger.rossier"="\\fileprint\Profiles3$\Roger.Rossier"
	"stephan.rueegg"="\\fileprint\Profiles3$\Stephan.Ruegg"
	"verena.steiner"="\\fileprint\Profiles5$\Verena.Steiner"
}

function Get-XmlContent{
    Param(
        [Parameter(Mandatory=$true)]
        [string]
        $DownloadUrl,
        [Parameter()]
        [string]
        $DownloadUser,
        [Parameter()]
        [string]
        $DownloadPassword,
        [Parameter()]
        [switch]
        $UseLocalCopy
    )

    if ($UseLocalCopy){
        [xml]$xml = Get-Content -Encoding UTF8 $LocalCopyName
    } else {
        $tempFile = [System.IO.Path]::GetTempFileName()
        $secpasswd = ConvertTo-SecureString $DownloadPassword -AsPlainText -Force
        $credentials = New-Object System.Management.Automation.PSCredential ($DownloadUser, $secpasswd)
        Invoke-WebRequest -Uri $DownloadUrl -Credential $credentials -OutFile $tempFile
        [xml]$xml = Get-Content -Path $tempFile -Encoding UTF8
        Remove-Item -Path $tempFile
    }

    return $xml
}

function Get-Klassen{
     Param(
        [Parameter(Mandatory)]
        [System.Xml.XmlElement]
        $XmlNode,
        [Parameter(Mandatory)]
        [string]
        $Source,
        [Parameter(Mandatory)]
        [string]
        $School
    )

    If ($Source -eq $School){

        $klassen = @()

        if ($XmlNode.LocalName -eq $lehrer){
            if ($XmlNode.regelklassen){
                $klassen += $XmlNode.regelklassen.klasse.klasse_kuerzel | sort
            }
        } else {
            if ($XmlNode.profile){
                $klassen += $XmlNode.profile.profil.stammklasse | sort
                $klassen += $XmlNode.profile.profil.zweitausbildung_stammklasse | sort
            }
        }
        
		$klassen = $klassen | select -uniq
		
        if ($klassen.Count -gt 0)
        {
            return [string]::Join(",",$klassen)
        }
    }

    return ""
}

function Get-ProfilePath {
	param(
		[string] $ThirdPartySystemId
	)

    $profilePath = ""

    if ($ExistingProfilePaths.ContainsKey($ThirdPartySystemId)) {
        $profilePath = $ExistingProfilePaths[$ThirdPartySystemId]
    }

    return $profilePath
}

function Get-Mail {
	param(
		[string] $Mail,
        [string] $Username
	)

    if ([string]::IsNullOrWhiteSpace($Mail)) {
        $Mail = ("$($Username)@bbzsogr.ch" -replace "ö", "oe")
    }

    return $Mail
}

function Get-PersonFromXmlNode{
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Microsoft.PowerShell.Commands.SelectXmlInfo]
        $XmlNode,
        [Parameter(Mandatory)]
        [string]
        $Source
    )

    Process{
        $node = $XmlNode.Node

        if ($node.status -gt 0){
            return [PSCustomObject]@{
                Id = $node.username
                Vorname = $node.vorname
                Nachname = $node.name
                Kuerzel = $node.kuerzel
                Mail = Get-Mail -Mail $node.mail -Username $node.username
                Typ = $node.LocalName
                Teilschulen = $Source
                KlassenKBS = Get-Klassen -XmlNode $node -Source $Source -School "KBS"
                KlassenZZ = Get-Klassen -XmlNode $node -Source $Source -School "ZZ"
                KlassenGIBSGR = Get-Klassen -XmlNode $node -Source $Source -School "GIBSGR"
                KlassenGIBSSO = Get-Klassen -XmlNode $node -Source $Source -School "GIBSSO"
		Profilpfad = Get-ProfilePath -ThirdPartySystemId $node.username
            }
        }
    }
}

function Validate-Person{
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]
        $Person
    )

    Process{
        if ([string]::IsNullOrWhiteSpace($Person.Id)){
            $Person | Add-Member -Name Error -MemberType NoteProperty -Value "ID ist leer"       
        } elseif ([string]::IsNullOrWhiteSpace($Person.Nachname)) {
            $Person | Add-Member -Name Error -MemberType NoteProperty -Value "Nachname ist leer" 
        } elseif ([string]::IsNullOrWhiteSpace($Person.Vorname)) {
            $Person | Add-Member -Name Error -MemberType NoteProperty -Value "Vorname ist leer" 
        } elseif ([string]::IsNullOrWhiteSpace($Person.Mail)) {
            $Person | Add-Member -Name Error -MemberType NoteProperty -Value "Mail ist leer" 
        } elseif ($Person.Mail -notlike "*@$($ValidMailDomain)") {
            $Person | Add-Member -Name Error -MemberType NoteProperty -Value "Mail-Domäne ist ungültig" 
        } elseif ([string]::IsNullOrWhiteSpace($Person.Kuerzel) -and $Person.Typ -eq $lehrer) {
            $Person | Add-Member -Name Error -MemberType NoteProperty -Value "Kürzel ist leer" 
        } else {
            return $Person
        }  

        $Global:InvalidPeople += $Person
    }
}

function Find-ExistingPerson{
    Param(
        [Parameter(Mandatory)]
        [PSCustomObject]
        $Person
    )

    Process{
        return $Global:People | where Id -eq $Person.Id
    }
}

function New-Person{
    Param(
        [Parameter(Mandatory)]
        [PSCustomObject]
        $Person
    )

    Process{
        $Global:People += $Person
    }
}

function Update-Person{
    Param(
        [Parameter(Mandatory)]
        [PSCustomObject]
        $NewPerson,
        [Parameter(Mandatory)]
        [PSCustomObject]
        $ExistingPerson
    )

    Process{
        
        if ($ExistingPerson.Mail -ne $NewPerson.Mail){
            $NewPerson | Add-Member -Name Error -MemberType NoteProperty -Value "Unterschiedliche E-Mail-Adressen bei verschiedenen Teilschulen" 
            $Global:InvalidPeople += $NewPerson
        }

        $ExistingPerson.Teilschulen = "$($ExistingPerson.Teilschulen),$($NewPerson.Teilschulen)"
        switch ($NewPerson.Teilschulen)
        {
            "KBS" { $ExistingPerson.KlassenKBS = $NewPerson.KlassenKBS }
            "ZZ" { $ExistingPerson.KlassenZZ = $NewPerson.KlassenZZ }
            "GIBSGR" { $ExistingPerson.KlassenGIBSGR = $NewPerson.KlassenGIBSGR }
            "GIBSSO" { $ExistingPerson.KlassenGIBSSO = $NewPerson.KlassenGIBSSO }
        }
    }
}

function Persist-Person{
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]
        $Person
    )

     Process{
        $existingPerson = Find-ExistingPerson -Person $Person

        if ($existingPerson){
            Update-Person -NewPerson $Person -ExistingPerson $existingPerson
        } else {
            New-Person -Person $Person
        }
    }
}

Write-Information "Start Script."

foreach($source in $Sources){
    Write-Information "Read XML of Source '$($source.Name)'"
    [xml]$xml = Get-XmlContent -DownloadUrl $source.Url -DownloadUser $source.Username -DownloadPassword $source.Password
    $nodes = Select-Xml "//$($lehrer)|//$($schueler)" $xml
    Write-Information "Number of people found in XML: $($nodes.Count)"
    $nodes | Get-PersonFromXmlNode -Source $source.Name | Validate-Person | Persist-Person
}

Write-Information "Save invalid people in file '$($InvalidPeopleExport)'."
$Global:InvalidPeople | Export-Csv $InvalidPeopleExport -Delimiter ';' -Encoding UTF8 -NoTypeInformation
Write-Information "Save valid people in file '$($ResultName)'."
$Global:People | Export-Csv $ResultName -Delimiter ';' -Encoding UTF8 -NoTypeInformation

Write-Information "End of Script."