<#Update to ServerHealthCheckToolVer2
DESCRIPTION
This script collects health information from one or more computers and creates a quick operational snapshot.
It checks the operating system, uptime, memory usage, and local disk space so an administrator can determine
if the server appears healthy or needs attention.#>

# Accept one or more computer names.
# If no name is provided, use the local computer.

param(
    [string[]]$ComputerName = $env:COMPUTERNAME
)       
#Define thresholds used to determine PASS, WARNING, or FAIL.

$DiskWarningThreshold = 20
$DiskFailPercentage = 10
$MemoryWarningGB = 2
$UptimeWarningDays = 30

#Create a report folder if it does not already exist.

$ReportFolder = "C:\ServerHealthCheckReports"
if (-not (Test-Path -Path $ReportFolder)) {
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

# Loop through each computer in the ComputerName parameter.
$Results = foreach ($Computer in $ComputerName) {

    $target = if ([string]::IsNullOrWhiteSpace($Computer)) { $env:COMPUTERNAME } else { $Computer.Trim() }
  # Use try/catch so minimize the chance of the entire script failing.
    try {
        $isLocal = @($env:COMPUTERNAME, 'localhost', '.') -contains $target

        if ($isLocal) {
            $os = Get-CimInstance -Class Win32_OperatingSystem -ErrorAction Stop
            $ComputerSystem = Get-CimInstance -Class Win32_ComputerSystem -ErrorAction Stop
            $MemoryModules = Get-CimInstance -Class Win32_PhysicalMemory -ErrorAction Stop
            $disks = Get-CimInstance -Class Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop
        }
        else {
            $os = Get-CimInstance -Class Win32_OperatingSystem -ComputerName $target -ErrorAction Stop
            $ComputerSystem = Get-CimInstance -Class Win32_ComputerSystem -ComputerName $target -ErrorAction Stop
            $MemoryModules = Get-CimInstance -Class Win32_PhysicalMemory -ComputerName $target -ErrorAction Stop
            $disks = Get-CimInstance -Class Win32_LogicalDisk -ComputerName $target -Filter "DriveType=3" -ErrorAction Stop
        }

        $LastBootUpTime = $os.LastBootUpTime
        $Uptime = (Get-Date) - $LastBootUpTime

        $totalMemory = [math]::round(($MemoryModules.Capacity | Measure-Object -Sum).Sum / 1GB, 2)
        $freeMemory = [math]::round((($os.FreePhysicalMemory * 1KB) / 1GB), 2)
        $usedMemory = [math]::round($totalMemory - $freeMemory, 2)

        if ($freeMemory -lt $MemoryWarningGB) {
            $MemoryStatus = "Warning: Free Memory is below $MemoryWarningGB GB!"
        }
        else {
            $MemoryStatus = "Healthy: Free Memory is above $MemoryWarningGB GB."       
        }
        if ($Uptime.Days -gt $UptimeWarningDays) {
            $UptimeStatus = "Warning: Uptime is above $UptimeWarningDays days!"
        }
        else {
            $UptimeStatus = "Healthy: Uptime is within normal limits."       
        }
        if (-not $disks) {
            #Create a custom object for clean structured output.

            [PSCustomObject]@{
                ComputerName = $ComputerSystem.Name
                OSName = $os.Caption
                OSVersion = $os.Version
                LastBootTime = $LastBootUpTime
                Uptime = $Uptime.Days
                UptimeHours = $Uptime.Hours
                UptimeStatus = $UptimeStatus
                DriveLetter = "N/A"
                TotalDiskGB = "N/A"
                FreeDiskGB = "N/A"
                UsedDiskGB = "N/A"
                FreeDiskPercentage = "N/A"
                DiskStatus = "Warning: No fixed disks returned."
                TotalMemoryGB = $totalMemory
                UsedMemoryGB = $usedMemory
                FreeMemoryGB = $freeMemory
                MemoryStatus = $MemoryStatus
            }
            continue
        }

        foreach ($disk in $disks) {
                $totalDiskGB = [math]::round($disk.Size / 1GB, 2)
                $freeDiskGB = [math]::round($disk.FreeSpace / 1GB, 2)
                $usedDiskGB = [math]::round($totalDiskGB - $freeDiskGB, 2)

                if ($totalDiskGB -le 0) {
                    $freeDiskPercentage = 0
                }
                else {
                    $freeDiskPercentage = [math]::round(($freeDiskGB / $totalDiskGB) * 100, 2)
                }

                if ($freeDiskPercentage -lt $DiskFailPercentage) {
                    $DiskStatus = "Fail: Free Disk space is below $DiskFailPercentage%!"
                }
                elseif ($freeDiskPercentage -lt $DiskWarningThreshold) {
                    $DiskStatus = "Warning: Free Disk space is below $DiskWarningThreshold%!"
                }
                else {
                    $DiskStatus = "Healthy: Free Disk space is within normal limits."
                }
                #Create a custom object for clean structured output.
                [PSCustomObject]@{
                    ComputerName = $ComputerSystem.Name
                    OSName = $os.Caption
                    OSVersion = $os.Version
                    LastBootTime = $LastBootUpTime
                    Uptime = $Uptime.Days
                    UptimeHours = $Uptime.Hours                    
                    UptimeStatus = $UptimeStatus
                    DriveLetter = $disk.DeviceID
                    TotalDiskGB = $totalDiskGB
                    FreeDiskGB = $freeDiskGB 
                    UsedDiskGB = $usedDiskGB
                    FreeDiskPercentage = $freeDiskPercentage
                    DiskStatus = $DiskStatus
                    TotalMemoryGB = $totalMemory
                    UsedMemoryGB = $usedMemory
                    FreeMemoryGB = $freeMemory             
                    MemoryStatus = $MemoryStatus
                }
        }
}
            #If data collection fails, return a FAIL result with N/A values.
    catch {
        [PSCustomObject]@{
                ComputerName = $target
                OSName = "N/A"
                OSVersion = "N/A"
                LastBootTime = "N/A"
                Uptime = "N/A"
                UptimeHours = "N/A"
                UptimeStatus = "FAIL"
                DriveLetter = "N/A"
                TotalDiskGB = "N/A"
                FreeDiskGB = "N/A"
                UsedDiskGB = "N/A"
                FreeDiskPercentage = "N/A"
                DiskStatus = "FAIL"
                TotalMemoryGB = "N/A"
                UsedMemoryGB = "N/A"
                FreeMemoryGB = "N/A"
                MemoryStatus = "FAIL"
                ErrorMessage = $_.Exception.Message
        }
    }   
}
#Display the results on Screen as a table.
$Results | Format-Table -AutoSize

#Export the results to CSV and TXT reports.
$CsvPath = Join-Path -Path $ReportFolder -ChildPath "ServerHealthReport.csv"
$TxtPath = Join-Path -Path $ReportFolder -ChildPath "ServerHealthReport.txt"

$Results | Export-Csv -Path $CsvPath -NoTypeInformation
$Results | Out-File -FilePath $TxtPath

#Run the results to HTML.
if ($ExportHtml) {
    $HtmlPath = Join-Path -Path $ReportFolder -ChildPath "ServerHealthReport.html"

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
<h1>Server Health Check Report</h1>
<p><strong>Generated:</strong> $(Get-Date)</p>
<p><strong>Computers Checked:</strong> $($ComputerName -join ', ')</p>
"@

    $Results |
        ConvertTo-Html -Head $HtmlHead -PreContent $PreContent -Title "Server Health Report" |
        Out-File -FilePath $HtmlPath

    Write-Host "HTML: $HtmlPath"
}

Write-Host ""
Write-Host "Reports saved to:" -ForegroundColor Green
Write-Host "CSV: $CsvPath"
Write-Host "TXT: $TxtPath"