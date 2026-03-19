#Install the SharePoint Online Management Shell module
Get-process -name powershell,pwsh -ErrorAction SilentlyContinue  | where {$_.id -ne $PID} | Stop-Process -Force
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force -AllowClobber

# If this doesnt work, write domain manually (line 5 )
$Verifieddomain = LODSA494469.onmicrosoft.com

$verifiedDomainShort = $verifiedDomain -replace '\.onmicrosoft\.com$', ''
Connect-SPOService -Url "https://$verifiedDomainShort-admin.sharepoint.com"

Get-SPOSite

Get-SPOWebTemplate

New-SPOSite -Url https://$verifiedDomainShort.sharepoint.com/sites/Sales -Owner noreen@$verifiedDomain -StorageQuota 256 -Template EHS#1 -NoWait

Get-SPOSite | FL Url,Status

Disconnect-SPOService