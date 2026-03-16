# PowerShell---Projects

PowerShell scripts to help set up an everyday cloud admin working environment and showcase your Microsoft Learn achievements.

---

## Scripts

### 1. `Show-MSLearnTranscript.ps1`

Displays your Microsoft Learn profile, transcript, and achievements URLs in a formatted view. Optionally opens your transcript in the browser or exports a shareable summary file.

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `-Username` | `string` | ✅ Yes | Your MS Learn username (from your profile URL) |
| `-OpenBrowser` | `switch` | No | Opens your transcript in the default browser |
| `-ExportPath` | `string` | No | File path to export a transcript summary |

#### Examples

```powershell
# Display your MS Learn transcript URLs
.\Show-MSLearnTranscript.ps1 -Username "johndoe"

# Display and open transcript in browser
.\Show-MSLearnTranscript.ps1 -Username "johndoe" -OpenBrowser

# Display and export a summary file
.\Show-MSLearnTranscript.ps1 -Username "johndoe" -ExportPath "C:\Transcripts\MyTranscript.txt"
```

> **Tip:** Make sure your MS Learn profile is set to **Public** so others can view your transcript.  
> Go to: https://learn.microsoft.com/en-us/users/me/settings

---

### 2. `Setup-CloudAdminWorkspace.ps1`

Bootstraps an everyday cloud administrator workspace by installing PowerShell modules, CLI tools (Windows), and adding helpful aliases and functions to your PowerShell profile.

#### What it sets up

**PowerShell Modules**
- `Az` – Azure PowerShell
- `ExchangeOnlineManagement` – Exchange Online
- `Microsoft.Graph` – Microsoft Graph API
- `MicrosoftTeams` – Teams administration
- `AWSPowerShell.NetCore` – AWS Tools for PowerShell
- `PnP.PowerShell` – SharePoint PnP
- `PSReadLine` – Enhanced console editing

**CLI Tools** *(Windows / winget)*
- Azure CLI
- AWS CLI v2
- Bicep CLI
- Terraform
- kubectl

**Profile Helpers & Aliases**

| Command | Description |
|---------|-------------|
| `Connect-Azure` | Sign in to Azure |
| `Set-AzSub <name>` | Switch Azure subscription |
| `Get-AzSubs` | List all Azure subscriptions |
| `Get-AzResources <rg>` | List resources in a resource group |
| `Connect-Graph` | Connect to Microsoft Graph |
| `Connect-EXO` | Connect to Exchange Online |
| `Connect-AWS` | Configure AWS credentials |
| `Get-PublicIP` | Show your current public IP address |
| `Reload-Profile` | Reload your PowerShell profile |
| `Edit-Profile` | Open your profile in Notepad |

The profile also includes a **custom prompt** that shows the current time and active Azure subscription context.

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `-InstallModules` | `switch` | Install/update PowerShell cloud modules |
| `-InstallCLI` | `switch` | Install CLI tools via winget (Windows only) |
| `-UpdateProfile` | `switch` | Append helpers and aliases to your PS profile |
| `-All` | `switch` | Run all of the above |

#### Examples

```powershell
# Full setup (modules + CLI tools + profile update)
.\Setup-CloudAdminWorkspace.ps1 -All

# Only install/update PowerShell modules
.\Setup-CloudAdminWorkspace.ps1 -InstallModules

# Only add helpers to your PowerShell profile
.\Setup-CloudAdminWorkspace.ps1 -UpdateProfile

# Preview what would happen without making changes
.\Setup-CloudAdminWorkspace.ps1 -All -WhatIf
```

> **Note:** CLI tool installation (`-InstallCLI`) requires **winget** on Windows.  
> On Linux/macOS, the script prints the equivalent commands for your package manager.

---

## Requirements

- PowerShell 7+ (recommended) or Windows PowerShell 5.1
- Internet access for module/tool downloads
- Administrator rights are **not** required (modules install to `CurrentUser` scope)
