#Security Check Report Script Txt and CSV Output

#-----Routine Admin Accounts Check-----#
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ReportFolder = ".\SecurityCheckReports"
$SvrRptTxt = "$ReportFolder\SecurityCheckReport_$TimeStamp.txt"
$SvrRptCsv = "$ReportFolder\SecurityCheckReport_$TimeStamp.csv"
$Results = @()

#Creates the report folder if it doesn't exist
$ReportFolder = ".\SecurityCheckReports"
if (-not (Test-Path $ReportFolder)) {     
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

#*Checks Priviliged Accounts
try {
    $Admins = Get-LocalGroupMember -Group "Administrators" -ErrorAction Stop
    $AdminCount = $Admins.Count
    $AdminNames = $Admins.Name -Join ', '

    if ($AdminCount -le 2) {
        $Status= "PASS"
    }
    else {
        $Status = "WARNING"
    }

$Results += [PSCustomObject]@{
        Check   = "Privileged Accounts - Local Administrators"
        Status  = $Status
        Details = "$AdminCount privileged accounts found: $AdminNames"
    }
}
catch {
    $Results += [PSCustomObject]@{
        Check   = "Privileged Accounts - Local Administrators"
        Status  = "FAIL"
        Details = "Could not retrieve privileged accounts"
    }
}


#Firewall Checks
try {
    $FirewallProfile = Get-NetFirewallProfile
    $DisabledProfiles = $FirewallProfile | Where-Object { $_.Enabled -eq $false }

    if ($DisabledProfiles.Count -eq 0) {
        $Results += [PSCustomObject]@{
            Check = "Firewall Status"
            Status = "PASS"
            Details = "All firewall profiles are enabled"
        }
    } 
    else {
        $Results += [PSCustomObject]@{
        Check = "Firewall Status"
        Status = "WARNING"
        Details = "One or more firewall profiles are disabled: $($DisabledProfiles.Name -join ', ')"
        }
    }
}
catch {
    $Results += [PSCustomObject]@{
        Check = "Firewall Status"
        Status = "FAIL"
        Details = "Could not retrieve firewall status"
    }
}

#Antivirus Checks

try {
    $Antivirus = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct
    if ($Antivirus) {
        $Results += [PSCustomObject]@{
            Check = "Antivirus Status"
            Status = "PASS"
            Details = "$Antivirus product detected: $($Antivirus.displayName)"

        }
    } 
    else {
        $Results += [PSCustomObject]@{
            Check = "Antivirus Status"
            Status = "FAIL"
            Details = "No antivirus product detected"
        }
    }
}
catch {
    $Results += [PSCustomObject]@{
        Check   = "Antivirus"
        Status  = "FAIL"
        Details = "Could not retrieve antivirus status" 
    }
}

#Check Defender Status

try {
    $Defender = Get-MpComputerStatus
    if ($Defender.AntivirusEnabled -and $Defender.RealTimeProtectionEnabled) {
        $Results += [PSCustomObject]@{
            Check = "Windows Defender Status"
            Status = "PASS" 
            Details = "Windows Defender is enabled and real-time protection is active"
        }
    } 
    else {
        $Results += [PSCustomObject]@{
            Check = "Windows Defender Status"
            Status = "WARNING" 
            Details = "Windows Defender is either disabled or real-time protection is not active"
        }
    }
}
catch {
    $Results += [PSCustomObject]@{
        Check = "Windows Defender Status"
        Status = "FAIL" 
        Details = "Windows Defender status is unavailable"
    }
}

#Check User Account Control (UAC) Status

try {
    $UAC = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA"
    if ($UAC.EnableLUA -eq 1) {
        $Results += [PSCustomObject]@{
            Check = "User Account Control Status"
            Status = "PASS"
            Details = "UAC is enabled"
        }
    } 
    else {
        $Results += [PSCustomObject]@{
            Check = "User Account Control Status"
            Status = "WARNING"
            Details = "UAC is disabled-Potential security risk!"
        }
    }
}
catch {
    $Results += [PSCustomObject]@{
        Check = "User Account Control Status"
        Status = "FAIL"
        Details = "Could not retrieve UAC status"
    }
}

#Output to Screen
$Results | Format-Table -AutoSize


"Security Check Report - $env:COMPUTERNAME" | Out-File -FilePath $SvrRptTxt
"Generated on: $(Get-Date)" | Out-File -FilePath $SvrRptTxt -Append

$Results | Format-Table -AutoSize | Out-File -FilePath $SvrRptTxt -Append

$Results | Export-Csv -Path $SvrRptCsv -NoTypeInformation

#--On page Update--#
Write-host "`nReports saved to:" -ForegroundColor Green
Write-host "TXT: $SvrRptTxt" -ForegroundColor Yellow
Write-host "CSV: $SvrRptCsv" -ForegroundColor Yellow

#Export the results to CSV and TXT reports.
$CsvPath = Join-Path -Path $ReportFolder -ChildPath "Security Check.csv"
$TxtPath = Join-Path -Path $ReportFolder -ChildPath "Security Check.txt"

$Results | Export-Csv -Path $CsvPath -NoTypeInformation
$Results | Out-File -FilePath $TxtPath

#Run the results to HTML.
if ($ExportHtml) {
    $HtmlPath = Join-Path -Path $ReportFolder -ChildPath "Security Check.html"

    $HtmlHead = @"
<style>
    body {
        font-family: Arial, sans-serif;
        margin: 20px;
        background-color: #f4f6f8;
    }
    h1 {
        color: #1f4e79;
    }
    h2 {
        color: #2f75b5;
    }
    table {
        border-collapse: collapse;
        width: 100%;
        background-color: white;
    }
    th, td {
        border: 1px solid #d9d9d9;
        padding: 8px;
        text-align: left;
    }
    th {
        background-color: #1f4e79;
        color: white;
    }
    tr:nth-child(even) {
        background-color: #f2f2f2;
    }
</style>
"@

    $PreContent = @"
<h1>Security Check Report</h1>
<p><strong>Generated:</strong> $(Get-Date)</p>
<p><strong>Computers Checked:</strong> $($ComputerName -join ', ')</p>
"@

    $Results |
        ConvertTo-Html -Head $HtmlHead -PreContent $PreContent -Title "Security Check Report" |
        Out-File -FilePath $HtmlPath

    Write-Host "HTML: $HtmlPath"
}

Write-Host ""
Write-Host "Reports saved to:" -ForegroundColor Green
Write-Host "CSV: $CsvPath"
Write-Host "TXT: $TxtPath"