# OKD Homelab Installation Script for Windows
# This script automates the setup of OpenShift Local (CRC) with OKD preset
# 
# Prerequisites:
# - Windows 10/11 with Administrator privileges
# - Download the pull-secret.txt from https://console.redhat.com/openshift/create/local
# - CRC installer should be downloaded or installed already

<#
.SYNOPSIS
    Automated installation and configuration of OKD using OpenShift Local (CRC)

.DESCRIPTION
    This script checks prerequisites, configures Hyper-V, sets up CRC with OKD preset,
    and starts your local OKD cluster.

.PARAMETER PullSecretPath
    Path to your pull-secret.txt file downloaded from Red Hat

.PARAMETER CPUs
    Number of CPU cores to allocate (default: 8)

.PARAMETER Memory
    Memory in MB to allocate (default: 16384 = 16GB)

.PARAMETER DiskSize
    Disk size in GB to allocate (default: 60)

.PARAMETER SkipHyperVCheck
    Skip Hyper-V installation check (use if already enabled)

.EXAMPLE
    .\install-okd.ps1 -PullSecretPath "C:\Downloads\pull-secret.txt"

.EXAMPLE
    .\install-okd.ps1 -PullSecretPath "C:\Downloads\pull-secret.txt" -CPUs 6 -Memory 12288 -DiskSize 50

.NOTES
    Author: OKD Community
    Requires: Windows 10/11, Administrator privileges
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$PullSecretPath = "",
    
    [Parameter(Mandatory=$false)]
    [int]$CPUs = 8,
    
    [Parameter(Mandatory=$false)]
    [int]$Memory = 16384,
    
    [Parameter(Mandatory=$false)]
    [int]$DiskSize = 60,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipHyperVCheck
)

# Script configuration
$ErrorActionPreference = "Stop"
$CRCPath = "crc"

# Color output functions
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Header {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Magenta
    Write-Host " $Message" -ForegroundColor Magenta
    Write-Host "========================================`n" -ForegroundColor Magenta
}

# Check if running as Administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check system requirements
function Test-SystemRequirements {
    Write-Header "Checking System Requirements"
    
    # Check if running as admin
    if (-not (Test-Administrator)) {
        Write-Error-Custom "This script must be run as Administrator!"
        Write-Info "Right-click PowerShell and select 'Run as Administrator'"
        exit 1
    }
    Write-Success "Running with Administrator privileges"
    
    # Check Windows version
    $os = Get-CimInstance Win32_OperatingSystem
    $version = [System.Environment]::OSVersion.Version
    Write-Info "Windows Version: $($os.Caption) (Build $($version.Build))"
    
    if ($version.Build -lt 16299) {
        Write-Error-Custom "Windows 10 Fall Creators Update (version 1709) or later required"
        exit 1
    }
    Write-Success "Windows version is compatible"
    
    # Check CPU cores
    $cores = (Get-CimInstance Win32_Processor).NumberOfCores
    Write-Info "Physical CPU cores: $cores"
    if ($cores -lt 4) {
        Write-Error-Custom "Minimum 4 physical CPU cores required"
        exit 1
    }
    Write-Success "CPU requirements met"
    
    # Check RAM
    $totalRAM = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    Write-Info "Total RAM: $totalRAM GB"
    if ($totalRAM -lt 16) {
        Write-Warning-Custom "Recommended 16 GB or more RAM. You have $totalRAM GB"
        Write-Warning-Custom "Consider reducing Memory parameter if installation fails"
    } else {
        Write-Success "RAM requirements met"
    }
    
    # Check available disk space
    $systemDrive = $env:SystemDrive
    $freeSpace = [math]::Round((Get-PSDrive $systemDrive.Trim(':')).Free / 1GB, 2)
    Write-Info "Free disk space on ${systemDrive}: $freeSpace GB"
    if ($freeSpace -lt 35) {
        Write-Error-Custom "Minimum 35 GB free disk space required. You have $freeSpace GB"
        exit 1
    }
    Write-Success "Disk space requirements met"
    
    Write-Success "All system requirements passed!"
}

# Check and enable Hyper-V
function Enable-HyperVFeature {
    if ($SkipHyperVCheck) {
        Write-Info "Skipping Hyper-V check as requested"
        return
    }
    
    Write-Header "Checking Hyper-V Status"
    
    $hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
    
    if ($hyperv.State -eq "Enabled") {
        Write-Success "Hyper-V is already enabled"
        return
    }
    
    Write-Warning-Custom "Hyper-V is not enabled"
    Write-Info "Enabling Hyper-V... This will require a system restart"
    
    $response = Read-Host "Do you want to enable Hyper-V now? (Y/N)"
    if ($response -ne "Y" -and $response -ne "y") {
        Write-Error-Custom "Hyper-V is required for OKD installation"
        Write-Info "Please enable Hyper-V manually and run this script again"
        exit 1
    }
    
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
        Write-Success "Hyper-V has been enabled"
        Write-Warning-Custom "A system restart is REQUIRED before continuing"
        Write-Info "After restart, run this script again to complete the setup"
        
        $restart = Read-Host "Restart now? (Y/N)"
        if ($restart -eq "Y" -or $restart -eq "y") {
            Restart-Computer
        }
        exit 0
    }
    catch {
        Write-Error-Custom "Failed to enable Hyper-V: $_"
        exit 1
    }
}

# Check if CRC is installed
function Test-CRCInstalled {
    Write-Header "Checking CRC Installation"
    
    try {
        $crcVersion = & $CRCPath version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "CRC is installed"
            Write-Info "$crcVersion"
            return $true
        }
    }
    catch {
        Write-Warning-Custom "CRC is not installed or not in PATH"
        return $false
    }
    return $false
}

# Install CRC (guide user to download)
function Install-CRC {
    Write-Header "CRC Installation Required"
    
    Write-Info "CRC needs to be installed before continuing"
    Write-Info ""
    Write-Info "Please follow these steps:"
    Write-Info "1. Visit: https://console.redhat.com/openshift/create/local"
    Write-Info "2. Log in with your Red Hat Developer account (free)"
    Write-Info "3. Download 'OpenShift Local' for Windows"
    Write-Info "4. Also download the 'Pull Secret' file"
    Write-Info "5. Extract and run the .msi installer"
    Write-Info "6. Restart your PowerShell/Terminal"
    Write-Info "7. Run this script again"
    Write-Info ""
    Write-Warning-Custom "Script will exit now. Please install CRC and try again."
    
    exit 1
}

# Configure CRC for OKD
function Configure-CRC {
    Write-Header "Configuring CRC for OKD"
    
    # Set OKD preset
    Write-Info "Setting OKD preset..."
    & $CRCPath config set preset okd
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to set OKD preset"
        exit 1
    }
    Write-Success "OKD preset configured"
    
    # Configure CPU
    Write-Info "Setting CPU cores to $CPUs..."
    & $CRCPath config set cpus $CPUs
    Write-Success "CPU cores set to $CPUs"
    
    # Configure Memory
    Write-Info "Setting memory to $Memory MB..."
    & $CRCPath config set memory $Memory
    Write-Success "Memory set to $Memory MB ($([math]::Round($Memory/1024, 2)) GB)"
    
    # Configure Disk Size
    Write-Info "Setting disk size to $DiskSize GB..."
    & $CRCPath config set disk-size $DiskSize
    Write-Success "Disk size set to $DiskSize GB"
    
    # Disable telemetry by default (user can enable if desired)
    Write-Info "Configuring telemetry preference..."
    & $CRCPath config set consent-telemetry no
    Write-Success "Telemetry disabled (you can enable with: crc config set consent-telemetry yes)"
    
    # Show configuration
    Write-Info "`nCurrent CRC Configuration:"
    & $CRCPath config view
    Write-Success "CRC configuration complete!"
}

# Setup CRC
function Setup-CRC {
    Write-Header "Setting Up CRC Environment"
    
    Write-Info "Running crc setup..."
    Write-Info "This will download the OKD VM image (~2-3 GB) and configure networking"
    Write-Warning-Custom "This may take 10-30 minutes depending on your internet speed"
    Write-Info ""
    
    & $CRCPath setup
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "CRC setup failed"
        Write-Info "Try running 'crc cleanup' and then run this script again"
        exit 1
    }
    
    Write-Success "CRC setup completed successfully!"
}

# Start CRC cluster
function Start-CRCCluster {
    param([string]$PullSecretPath)
    
    Write-Header "Starting OKD Cluster"
    
    if ($PullSecretPath -and (Test-Path $PullSecretPath)) {
        Write-Info "Using pull secret from: $PullSecretPath"
        $pullSecret = Get-Content $PullSecretPath -Raw
        
        Write-Info "Starting CRC with pull secret..."
        Write-Warning-Custom "First start may take 10-15 minutes"
        
        # Start with pull secret
        $pullSecret | & $CRCPath start
    }
    else {
        Write-Info "Starting CRC..."
        Write-Warning-Custom "You will be prompted for the pull secret"
        Write-Info "Paste the contents of your pull-secret.txt file when prompted"
        Write-Warning-Custom "First start may take 10-15 minutes"
        
        & $CRCPath start
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to start CRC cluster"
        Write-Info "Check the error messages above for details"
        exit 1
    }
    
    Write-Success "OKD cluster started successfully!"
}

# Display cluster information
function Show-ClusterInfo {
    Write-Header "OKD Cluster Information"
    
    Write-Info "Retrieving cluster credentials..."
    & $CRCPath console --credentials
    
    Write-Info "`n`nUseful Commands:"
    Write-Info "  View cluster status:    crc status"
    Write-Info "  Open web console:       crc console"
    Write-Info "  Stop cluster:           crc stop"
    Write-Info "  Start cluster:          crc start"
    Write-Info "  Delete cluster:         crc delete"
    Write-Info "  Setup oc CLI:           crc oc-env | Invoke-Expression"
    
    Write-Success "`nOKD installation complete! Happy learning! 🚀"
}

# Main execution
function Main {
    Write-Host @"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   OKD Homelab Installation Script                       ║
║   OpenShift Local (CRC) Automated Setup                 ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    # Step 1: Check system requirements
    Test-SystemRequirements
    
    # Step 2: Check/Enable Hyper-V
    Enable-HyperVFeature
    
    # Step 3: Check if CRC is installed
    if (-not (Test-CRCInstalled)) {
        Install-CRC
    }
    
    # Step 4: Configure CRC for OKD
    Configure-CRC
    
    # Step 5: Setup CRC environment
    Setup-CRC
    
    # Step 6: Start the cluster
    Start-CRCCluster -PullSecretPath $PullSecretPath
    
    # Step 7: Display information
    Show-ClusterInfo
}

# Run the main function
try {
    Main
}
catch {
    Write-Error-Custom "An unexpected error occurred: $_"
    Write-Info "Please check the error message and try again"
    exit 1
}
