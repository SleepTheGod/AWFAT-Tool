# Import required modules
Import-Module Net.Sockets
Import-Module System.Net.NetworkInformation
Import-Module Microsoft.PowerShell.Security

# Attribution
$attribution = "Made by Taylor Christian Newsome"

# Define target process name
$targetProcessName = "notepad"

# Check for IDA Pro installation and download if necessary
if (!(Test-Path "C:\Program Files\IDA Pro 7.5\ida.exe")) {
    Write-Host "IDA Pro is not installed. Downloading the installer script..."

    # Download the IDA Pro installer script from the actual URL
    $idaInstallerScriptURL = "https://download.hex-rays.com/ida/ida76_installer.exe"
    $idaInstallerScriptPath = "$env:TEMP\ida-installer.exe"
    (New-Object System.Net.WebClient).DownloadFile($idaInstallerScriptURL, $idaInstallerScriptPath)

    # Launch the downloaded IDA Pro installer script
    Start-Process -FilePath $idaInstallerScriptPath
    exit
}

# Check if the target process exists
$targetProcess = Get-Process -Name $targetProcessName | Select-Object -ExpandProperty ID
if (!$targetProcess) {
    Write-Host "Target process '$targetProcessName' not found."
    exit
}

# Create a new folder for extracted artifacts
$artifactsFolder = New-Item -Path "$env:TEMP\forensics_artifacts" -ItemType Directory

# Extract memory contents of the process using PowerShell
$processMemory = Get-ProcessMemory -ProcessId $targetProcess
$memoryBytes = $processMemory | Select-Object -ExpandProperty WorkingSet | Select-Object -ExpandProperty ToArray

# Disassemble memory contents using IDA Pro
$idaExecutablePath = "C:\Program Files\IDA Pro 7.5\ida.exe"
$disassembledCodeFilePath = Join-Path $artifactsFolder "disassembled_code.txt"
$disassembledCode = Start-Process -FilePath $idaExecutablePath -ArgumentList ("-L", $memoryBytes) | Wait-Process -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Output

# Save disassembled code to a file for documentation
Out-File -FilePath $disassembledCodeFilePath -Content $disassembledCode

# Analyze network activity associated with the process
$networkConnections = Get-NetConnection | Where-Object { $_.OwningProcess -eq $targetProcess.Id }
if ($networkConnections) {
    Write-Host "Monitoring network traffic for process ID $targetProcess.Id..."

    # Start network traffic capture using NetMon
    $networkTrafficFilePath = Join-Path $artifactsFolder "network_traffic.etl"
    Start-NetMon -CaptureFile $networkTrafficFilePath -CaptureDuration 0

    # Wait for 10 seconds to capture network traffic
    Start-Sleep -Seconds 10

    # Stop network traffic capture
    Stop-NetMon

    Write-Host "Network traffic capture completed. Saved to: $networkTrafficFilePath"
}

# Identify and analyze registry hives associated with the process
$registryHives = Get-ChildItem -Path "HKCU:\Software" -Recurse | Where-Object { $_.HiveType -eq "Registry" }
if ($registryHives) {
    Write-Host "Analyzing registry hives associated with process ID $targetProcess.Id..."

    foreach ($registryHive in $registryHives) {
        $registryHivePath = Join-Path $artifactsFolder "registry_hive_${registryHive.Name}.reg"
        Export-RegistryKey -Path $registryHive.PSPath -Filepath $registryHivePath

        Write-Host "Exported registry hive: $registryHivePath"
    }
}

# Generate a comprehensive forensic report
$reportContent = @"
Target Process: $targetProcessName
Disassembled Code Location: $disassembledCodeFilePath
Network Traffic Capture (if applicable): $networkTrafficFilePath
Registry Hives (if applicable): $registryHives
$attribution
"@
Out-File -FilePath (Join-Path $artifactsFolder "forensics_report.txt") -Content $reportContent

Write-Host "Forensic analysis completed. Refer to the artifacts folder for detailed information."
