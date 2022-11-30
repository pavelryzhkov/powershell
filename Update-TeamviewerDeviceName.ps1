$TeamViewerID = Get-TeamViewerId
$token = ConvertTo-SecureString -AsPlainText "your_token" -force
Get-TeamViewerDevice $token| where TeamViewerId -Match $TeamViewerID | `
Set-TeamViewerDevice -Name $env:COMPUTERNAME -ApiToken $token
