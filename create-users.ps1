# скрипт создает локальных пользователей с заданными паролями и включает их в необходиые группы
$plaintextpassword = "password_to_be_set"
$password = ConvertTo-SecureString -String $plaintextpassword -AsPlainText -Force
$AdminName1 = "Администратор"
$AdminName2 = "extra_admin"
$UserName = "user"
# set admin #1 
Get-LocalUser $AdminName1 | Enable-LocalUser
Get-LocalUser $AdminName1 | Set-LocalUser -AccountNeverExpires -Password $password -PasswordNeverExpires $true
# set User
New-LocalUser -Name $UserName -NoPassword -UserMayNotChangePassword -AccountNeverExpires
Set-LocalUser $UserName -PasswordNeverExpires $true -AccountNeverExpires
Add-LocalGroupMember -Group "Пользователи" -Member $UserName
# set admin #2
New-LocalUser $AdminName2 -Password $password -AccountNeverExpires | Out-File -FilePath "c:\Temp\user_status.txt"
Set-LocalUser $AdminName2 -PasswordNeverExpires $true -AccountNeverExpires
Add-LocalGroupMember -Group "Администраторы" -Member $AdminName2