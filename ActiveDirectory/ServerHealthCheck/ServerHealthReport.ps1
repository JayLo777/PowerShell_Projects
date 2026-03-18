#This will generate a report of the health as a csv file that can be used for further analysis.

$os = Get-CimInstance -Class Win32_OperatingSystem 
$computerSystem = Get-CimInstance -Class Win32_ComputerSystem
$disk = Get-CimInstance -Class Win32_LogicalDisk -Filter "DeviceID='C:'"

$lastboot = $os.LastBootUpTime
$uptime = (Get-Date) - $lastboot

$report = [PSCustomObject]@{
    ComputerName = $computerSystem.Name
    OperatingSystem = "$($os.Caption) $($os.OSArchitecture)"
    OSVersion = $os.Version
    LastBootTime = $os.LastBootUpTime
    Uptime = "$($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"
    FreeMemoryGB = $freeMemory
    UsedMemoryGB = $usedMemory
    TotalMemoryGB = $totalMemory
    FreeDiskGB = $freeDisk
    UsedDiskGB = $usedDisk
    TotalDiskGB = $totalDisk
    CPULoadPercentage = $cpuLoad
} |Export-Csv -Path "ServerHealthReport.csv" -NoTypeInformation