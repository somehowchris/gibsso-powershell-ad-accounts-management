Get-ADUSer -Organization "GIBS/Lernende" -Name "Username" -eq $NULL
Add-ADUser -Organization "GIBS/Lernende" -Name "Username" -AccountPassword "Password"
