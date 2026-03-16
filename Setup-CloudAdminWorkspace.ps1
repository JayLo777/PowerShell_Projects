<#
.SYNOPSIS
    Sets up an everyday cloud admin workspace with common tools, modules, and aliases.

.DESCRIPTION
    This script bootstraps a cloud administrator's daily working environment by:
    - Installing essential PowerShell modules (Az, ExchangeOnlineManagement, etc.)
    - Installing cloud CLI tools (Azure CLI, AWS CLI) if on Windows
    - Configuring helpful PowerShell aliases and functions
    - Optionally updating the current user's PowerShell profile so the
      workspace is ready every time a new session starts

.PARAMETER InstallModules
    Switch to install/update PowerShell modules for cloud administration.

.PARAMETER InstallCLI
    Switch to install Azure CLI and AWS CLI via winget (Windows only).

.PARAMETER UpdateProfile
    Switch to append workspace helper functions/aliases to your PowerShell profile.

.PARAMETER All
    Convenience switch that enables InstallModules, InstallCLI, and UpdateProfile.

.EXAMPLE
    .\Setup-CloudAdminWorkspace.ps1 -All
    Runs the full setup: modules, CLI tools, and profile update.

.EXAMPLE
    .\Setup-CloudAdminWorkspace.ps1 -InstallModules
    Only installs/updates PowerShell modules.

.EXAMPLE
    .\Setup-CloudAdminWorkspace.ps1 -UpdateProfile
    Only appends workspace helpers to the PowerShell profile.
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [switch]$InstallModules,
    [switch]$InstallCLI,
    [switch]$UpdateProfile,
    [switch]$All
)

Set-StrictMode -Version Latest

# winget exit code: package is already installed (not an error)
$WINGET_ALREADY_INSTALLED = -1978335189

if ($All) {
    $InstallModules = $true
    $InstallCLI     = $true
    $UpdateProfile  = $true
}

#region Helpers

function Write-Banner {
    $banner = @"
╔══════════════════════════════════════════════════════════╗
║        Cloud Admin Workspace Setup                       ║
╚══════════════════════════════════════════════════════════╝
"@
    Write-Host $banner -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "  ▶ $Message" -ForegroundColor Yellow
}

function Write-OK {
    param([string]$Message)
    Write-Host "    ✅ $Message" -ForegroundColor Green
}

function Write-Skip {
    param([string]$Message)
    Write-Host "    ⏭️  $Message" -ForegroundColor DarkGray
}

function Write-Warn {
    param([string]$Message)
    Write-Host "    ⚠️  $Message" -ForegroundColor Magenta
}

function Write-Separator {
    Write-Host ("─" * 60) -ForegroundColor DarkCyan
}

#endregion

#region Module Installation

$CloudModules = @(
    @{ Name = "Az";                             Description = "Azure PowerShell module"             },
    @{ Name = "ExchangeOnlineManagement";       Description = "Exchange Online management"          },
    @{ Name = "Microsoft.Graph";                Description = "Microsoft Graph API"                 },
    @{ Name = "MicrosoftTeams";                 Description = "Microsoft Teams administration"      },
    @{ Name = "AWSPowerShell.NetCore";          Description = "AWS Tools for PowerShell"            },
    @{ Name = "PnP.PowerShell";                 Description = "SharePoint PnP PowerShell"           },
    @{ Name = "PSReadLine";                     Description = "Enhanced interactive console editing" }
)

function Install-CloudModules {
    Write-Step "Installing / updating PowerShell modules..."
    Write-Separator

    # Ensure PSGallery is trusted so installs are non-interactive
    $gallery = Get-PSRepository -Name "PSGallery" -ErrorAction SilentlyContinue
    if ($gallery -and $gallery.InstallationPolicy -ne "Trusted") {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
        Write-OK "PSGallery set to Trusted"
    }

    foreach ($mod in $CloudModules) {
        $name = $mod.Name
        $desc = $mod.Description

        $installed = Get-Module -ListAvailable -Name $name -ErrorAction SilentlyContinue |
                     Sort-Object Version -Descending |
                     Select-Object -First 1

        $latest = Find-Module -Name $name -ErrorAction SilentlyContinue |
                  Select-Object -First 1

        if ($null -eq $latest) {
            Write-Warn "$name – not found in PSGallery, skipping."
            continue
        }

        if ($null -eq $installed) {
            if ($PSCmdlet.ShouldProcess($name, "Install module ($desc)")) {
                Write-Host "    📦 Installing $name ($desc)..." -ForegroundColor White
                Install-Module -Name $name -Scope CurrentUser -AllowClobber -Force -ErrorAction Stop
                Write-OK "$name installed (v$($latest.Version))"
            }
        } elseif ([version]$installed.Version -lt [version]$latest.Version) {
            if ($PSCmdlet.ShouldProcess($name, "Update module from v$($installed.Version) to v$($latest.Version)")) {
                Write-Host "    🔄 Updating $name v$($installed.Version) → v$($latest.Version)..." -ForegroundColor White
                Update-Module -Name $name -Force -ErrorAction Stop
                Write-OK "$name updated to v$($latest.Version)"
            }
        } else {
            Write-Skip "$name is already up to date (v$($installed.Version))"
        }
    }

    Write-Separator
}

#endregion

#region CLI Tool Installation (Windows / winget)

function Install-CLITools {
    Write-Step "Installing CLI tools via winget (Windows only)..."
    Write-Separator

    if ($IsLinux -or $IsMacOS) {
        Write-Warn "CLI installation via winget is only supported on Windows."
        Write-Host "    On Linux/macOS, install tools via your package manager:" -ForegroundColor White
        Write-Host "      Azure CLI:  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash" -ForegroundColor DarkGray
        Write-Host "      AWS CLI:    https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html" -ForegroundColor DarkGray
        Write-Separator
        return
    }

    $winget = Get-Command "winget" -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Warn "winget is not available. Install it from https://aka.ms/getwinget"
        Write-Separator
        return
    }

    $cliTools = @(
        @{ Id = "Microsoft.AzureCLI";       Name = "Azure CLI"      },
        @{ Id = "Amazon.AWSCLI";            Name = "AWS CLI v2"     },
        @{ Id = "Microsoft.Bicep";          Name = "Bicep CLI"      },
        @{ Id = "Hashicorp.Terraform";      Name = "Terraform"      },
        @{ Id = "Kubernetes.kubectl";       Name = "kubectl"        }
    )

    foreach ($tool in $cliTools) {
        if ($PSCmdlet.ShouldProcess($tool.Name, "Install/upgrade via winget")) {
            Write-Host "    📦 Installing $($tool.Name)..." -ForegroundColor White
            winget install --id $tool.Id --accept-source-agreements --accept-package-agreements --silent 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq $WINGET_ALREADY_INSTALLED) {
                Write-OK "$($tool.Name) is installed"
            } else {
                Write-Warn "$($tool.Name) install returned exit code $LASTEXITCODE"
            }
        }
    }

    Write-Separator
}

#endregion

#region Profile Update

# Workspace helper content appended to the PowerShell profile
$ProfileBlock = @'

# ──────────────────────────────────────────────────────────
#  Cloud Admin Workspace Helpers  (added by Setup-CloudAdminWorkspace.ps1)
# ──────────────────────────────────────────────────────────

#── Azure shortcuts ──────────────────────────────────────
function Connect-Azure   { Connect-AzAccount @args }
function Set-AzSub       { param([string]$SubscriptionName) Set-AzContext -Subscription $SubscriptionName }
function Get-AzSubs      { Get-AzSubscription | Select-Object Name, Id, State | Sort-Object Name }
function Get-AzResources { param([string]$ResourceGroup) Get-AzResource -ResourceGroupName $ResourceGroup | Select-Object Name, ResourceType, Location }

#── Microsoft Graph shortcuts ────────────────────────────
function Connect-Graph   { Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All" @args }

#── Exchange Online shortcuts ─────────────────────────────
function Connect-EXO     { Connect-ExchangeOnline @args }

#── AWS shortcuts ─────────────────────────────────────────
function Connect-AWS     { Set-AWSCredential @args }

#── General admin utilities ───────────────────────────────
function Get-PublicIP    { (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip }
function Reload-Profile  { . $PROFILE }
function Edit-Profile    { & (if ($IsWindows) { "notepad" } elseif ($IsMacOS) { "open" } else { $env:EDITOR ?? "nano" }) $PROFILE }

#── Prompt customisation ──────────────────────────────────
function prompt {
    $azContext = $null
    try { $azContext = (Get-AzContext -ErrorAction SilentlyContinue)?.Subscription.Name } catch {}
    $ctxLabel = if ($azContext) { " [Az: $azContext]" } else { "" }
    $location = (Get-Location).Path
    "`n[$(Get-Date -Format 'HH:mm:ss')]$ctxLabel`n$location`n> "
}

# ──────────────────────────────────────────────────────────
'@

function Update-PowerShellProfile {
    Write-Step "Updating PowerShell profile: $PROFILE"
    Write-Separator

    $markerText = "Cloud Admin Workspace Helpers  (added by Setup-CloudAdminWorkspace.ps1)"

    # Read existing profile content (or empty string if it doesn't exist yet)
    $existingContent = ""
    if (Test-Path $PROFILE) {
        $existingContent = Get-Content -Path $PROFILE -Raw -ErrorAction SilentlyContinue
    }

    if ($existingContent -match [regex]::Escape($markerText)) {
        Write-Skip "Workspace helpers are already present in your profile."
        Write-Separator
        return
    }

    if ($PSCmdlet.ShouldProcess($PROFILE, "Append cloud admin workspace helpers")) {
        $profileDir = Split-Path -Path $PROFILE -Parent
        if (-not (Test-Path -Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }

        Add-Content -Path $PROFILE -Value $ProfileBlock -Encoding UTF8
        Write-OK "Helpers appended to $PROFILE"
        Write-Host ""
        Write-Host "    Reload your profile with:  . `$PROFILE" -ForegroundColor White
        Write-Host "    Or start a new PowerShell session." -ForegroundColor White
    }

    Write-Separator
}

#endregion

#region Summary

function Show-WorkspaceSummary {
    Write-Host ""
    Write-Separator
    Write-Host "  🏁 Cloud Admin Workspace Setup Complete!" -ForegroundColor Cyan
    Write-Separator
    Write-Host ""
    Write-Host "  Quick-start commands available after reloading your profile:" -ForegroundColor White
    Write-Host ""
    Write-Host "    Connect-Azure       – Sign in to Azure" -ForegroundColor DarkGray
    Write-Host "    Set-AzSub <name>    – Switch Azure subscription" -ForegroundColor DarkGray
    Write-Host "    Get-AzSubs          – List Azure subscriptions" -ForegroundColor DarkGray
    Write-Host "    Connect-Graph       – Connect to Microsoft Graph" -ForegroundColor DarkGray
    Write-Host "    Connect-EXO         – Connect to Exchange Online" -ForegroundColor DarkGray
    Write-Host "    Connect-AWS         – Configure AWS credentials" -ForegroundColor DarkGray
    Write-Host "    Get-PublicIP        – Show your current public IP" -ForegroundColor DarkGray
    Write-Host "    Reload-Profile      – Reload your PowerShell profile" -ForegroundColor DarkGray
    Write-Host "    Edit-Profile        – Open your profile in Notepad" -ForegroundColor DarkGray
    Write-Host ""
    Write-Separator
    Write-Host ""
}

#endregion

#region Entry Point

Write-Banner

if (-not ($InstallModules -or $InstallCLI -or $UpdateProfile)) {
    Write-Host ""
    Write-Host "  No action flags specified. Use one or more of:" -ForegroundColor Yellow
    Write-Host "    -InstallModules   Install/update PowerShell cloud modules" -ForegroundColor White
    Write-Host "    -InstallCLI       Install CLI tools via winget (Windows)" -ForegroundColor White
    Write-Host "    -UpdateProfile    Append helpers/aliases to your PS profile" -ForegroundColor White
    Write-Host "    -All              Run all of the above" -ForegroundColor White
    Write-Host ""
    Write-Host "  Example:  .\Setup-CloudAdminWorkspace.ps1 -All" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

if ($InstallModules) { Install-CloudModules   }
if ($InstallCLI)     { Install-CLITools       }
if ($UpdateProfile)  { Update-PowerShellProfile }

Show-WorkspaceSummary

#endregion
