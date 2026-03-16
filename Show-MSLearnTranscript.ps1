<#
.SYNOPSIS
    Displays and opens your Microsoft Learn transcript and learning achievements.

.DESCRIPTION
    This script helps you showcase your Microsoft Learn transcript by:
    - Opening your public MS Learn profile/transcript in the default browser
    - Displaying a formatted summary of your learning activity
    - Optionally exporting transcript details to a file for sharing

.PARAMETER Username
    Your Microsoft Learn username (as shown in your profile URL).
    Example: https://learn.microsoft.com/en-us/users/<Username>/

.PARAMETER OpenBrowser
    Switch to open the transcript URL in the default browser.

.PARAMETER ExportPath
    Optional file path to export a shareable transcript summary (e.g., C:\Transcripts\MyTranscript.txt).

.EXAMPLE
    .\Show-MSLearnTranscript.ps1 -Username "johndoe"
    Displays the profile URL and opens it in the browser.

.EXAMPLE
    .\Show-MSLearnTranscript.ps1 -Username "johndoe" -ExportPath "C:\Transcripts\MyTranscript.txt"
    Displays the profile and exports a summary file.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Enter your Microsoft Learn username")]
    [string]$Username,

    [Parameter(Mandatory = $false)]
    [switch]$OpenBrowser,

    [Parameter(Mandatory = $false)]
    [string]$ExportPath
)

#region Helper Functions

function Write-Banner {
    $banner = @"
╔══════════════════════════════════════════════════════════╗
║          Microsoft Learn Transcript Showcase             ║
╚══════════════════════════════════════════════════════════╝
"@
    Write-Host $banner -ForegroundColor Cyan
}

function Get-MSLearnProfileUrl {
    param([string]$User)
    return "https://learn.microsoft.com/en-us/users/$User/"
}

function Get-MSLearnTranscriptUrl {
    param([string]$User)
    return "https://learn.microsoft.com/en-us/users/$User/transcript"
}

function Get-MSLearnAchievementsUrl {
    param([string]$User)
    return "https://learn.microsoft.com/en-us/users/$User/achievements"
}

function Show-TranscriptSummary {
    param(
        [string]$User,
        [string]$ProfileUrl,
        [string]$TranscriptUrl,
        [string]$AchievementsUrl
    )

    $separator = "─" * 60

    Write-Host ""
    Write-Host $separator -ForegroundColor DarkCyan
    Write-Host "  MS Learn Profile: $User" -ForegroundColor Yellow
    Write-Host $separator -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  🔗 Profile URL:" -ForegroundColor White
    Write-Host "     $ProfileUrl" -ForegroundColor Blue
    Write-Host ""
    Write-Host "  📋 Transcript URL:" -ForegroundColor White
    Write-Host "     $TranscriptUrl" -ForegroundColor Blue
    Write-Host ""
    Write-Host "  🏆 Achievements URL:" -ForegroundColor White
    Write-Host "     $AchievementsUrl" -ForegroundColor Blue
    Write-Host ""
    Write-Host $separator -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  ℹ️  Share your transcript by sending your Transcript URL." -ForegroundColor Green
    Write-Host "  ℹ️  Make sure your profile is set to public on MS Learn." -ForegroundColor Green
    Write-Host ""
    Write-Host "  To make your profile public, go to:" -ForegroundColor White
    Write-Host "  https://learn.microsoft.com/en-us/users/me/settings" -ForegroundColor Blue
    Write-Host ""
    Write-Host $separator -ForegroundColor DarkCyan
}

function Export-TranscriptSummary {
    param(
        [string]$User,
        [string]$ProfileUrl,
        [string]$TranscriptUrl,
        [string]$AchievementsUrl,
        [string]$FilePath
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $content = @"
Microsoft Learn Transcript Summary
Generated: $timestamp
══════════════════════════════════════════════════════════

User:            $User
Profile URL:     $ProfileUrl
Transcript URL:  $TranscriptUrl
Achievements URL: $AchievementsUrl

NOTE: Ensure your MS Learn profile visibility is set to Public so others
can view your transcript. Settings: https://learn.microsoft.com/en-us/users/me/settings
"@

    $exportDir = Split-Path -Path $FilePath -Parent
    if ($exportDir -and -not (Test-Path -Path $exportDir)) {
        New-Item -ItemType Directory -Path $exportDir -Force | Out-Null
    }

    $content | Out-File -FilePath $FilePath -Encoding UTF8
    Write-Host "  ✅ Transcript summary exported to: $FilePath" -ForegroundColor Green
}

#endregion

#region Main

Write-Banner

$profileUrl     = Get-MSLearnProfileUrl     -User $Username
$transcriptUrl  = Get-MSLearnTranscriptUrl  -User $Username
$achievementsUrl = Get-MSLearnAchievementsUrl -User $Username

Show-TranscriptSummary -User $Username `
                       -ProfileUrl $profileUrl `
                       -TranscriptUrl $transcriptUrl `
                       -AchievementsUrl $achievementsUrl

if ($OpenBrowser) {
    Write-Host "  🌐 Opening MS Learn transcript in your default browser..." -ForegroundColor Cyan
    Start-Process $transcriptUrl
    Write-Host ""
}

if ($ExportPath) {
    Export-TranscriptSummary -User $Username `
                             -ProfileUrl $profileUrl `
                             -TranscriptUrl $transcriptUrl `
                             -AchievementsUrl $achievementsUrl `
                             -FilePath $ExportPath
}

#endregion
