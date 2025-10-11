@echo off
REM OKD Homelab Quick Setup Script for Windows
REM Simplified batch script for basic CRC configuration
REM For full automation, use install-okd.ps1 PowerShell script

SETLOCAL EnableDelayedExpansion

echo.
echo ========================================
echo  OKD Homelab Quick Setup
echo  OpenShift Local (CRC) Configuration
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as Administrator!
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)
echo [OK] Running with Administrator privileges
echo.

REM Check if CRC is installed
where crc >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] CRC is not installed or not in PATH
    echo.
    echo Please install CRC first:
    echo 1. Visit: https://console.redhat.com/openshift/create/local
    echo 2. Download and install OpenShift Local for Windows
    echo 3. Download the pull secret file
    echo 4. Run this script again
    pause
    exit /b 1
)
echo [OK] CRC is installed
echo.

REM Get CRC version
echo Current CRC version:
crc version
echo.

REM Configuration
echo ========================================
echo  Configuration Settings
echo ========================================
echo.

set /p CPU_CORES="Enter number of CPU cores (default: 8): "
if "%CPU_CORES%"=="" set CPU_CORES=8

set /p MEMORY="Enter memory in MB (default: 16384 = 16GB): "
if "%MEMORY%"=="" set MEMORY=16384

set /p DISK_SIZE="Enter disk size in GB (default: 60): "
if "%DISK_SIZE%"=="" set DISK_SIZE=60

echo.
echo Configuration Summary:
echo   CPU Cores: %CPU_CORES%
echo   Memory: %MEMORY% MB
echo   Disk: %DISK_SIZE% GB
echo.

set /p CONFIRM="Continue with these settings? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Setup cancelled.
    pause
    exit /b 0
)

echo.
echo ========================================
echo  Configuring CRC for OKD
echo ========================================
echo.

REM Set OKD preset
echo [*] Setting OKD preset...
crc config set preset okd
if %errorLevel% neq 0 (
    echo [ERROR] Failed to set OKD preset
    pause
    exit /b 1
)
echo [OK] OKD preset configured
echo.

REM Configure resources
echo [*] Setting CPU cores to %CPU_CORES%...
crc config set cpus %CPU_CORES%
echo [OK] CPU configured
echo.

echo [*] Setting memory to %MEMORY% MB...
crc config set memory %MEMORY%
echo [OK] Memory configured
echo.

echo [*] Setting disk size to %DISK_SIZE% GB...
crc config set disk-size %DISK_SIZE%
echo [OK] Disk size configured
echo.

REM Disable telemetry
echo [*] Configuring telemetry settings...
crc config set consent-telemetry no
echo [OK] Telemetry disabled
echo.

REM Show configuration
echo ========================================
echo  Current CRC Configuration
echo ========================================
crc config view
echo.

echo ========================================
echo  Running CRC Setup
echo ========================================
echo.
echo This will download the OKD VM image (~2-3 GB)
echo and configure your system. This may take 10-30 minutes.
echo.
set /p SETUP="Run crc setup now? (Y/N): "
if /i not "%SETUP%"=="Y" (
    echo Setup skipped. Run 'crc setup' manually when ready.
    pause
    exit /b 0
)

echo.
echo [*] Running crc setup...
echo Please wait, this may take a while...
crc setup

if %errorLevel% neq 0 (
    echo.
    echo [ERROR] CRC setup failed
    echo Try running 'crc cleanup' and then run this script again
    pause
    exit /b 1
)

echo.
echo [OK] CRC setup completed successfully!
echo.

echo ========================================
echo  Starting OKD Cluster
echo ========================================
echo.
echo The first start will take 10-15 minutes.
echo You will be prompted for your pull secret.
echo.
set /p START="Start the cluster now? (Y/N): "
if /i not "%START%"=="Y" (
    echo.
    echo Cluster not started. To start manually, run:
    echo   crc start
    echo.
    pause
    exit /b 0
)

echo.
echo [*] Starting CRC cluster...
echo.
echo ** IMPORTANT **
echo When prompted, paste your pull secret from:
echo https://console.redhat.com/openshift/create/local
echo.
pause

crc start

if %errorLevel% neq 0 (
    echo.
    echo [ERROR] Failed to start cluster
    echo Check the error messages above for details.
    pause
    exit /b 1
)

echo.
echo ========================================
echo  OKD Cluster Started Successfully!
echo ========================================
echo.

REM Show credentials
echo Cluster credentials:
crc console --credentials

echo.
echo ========================================
echo  Next Steps
echo ========================================
echo.
echo 1. Open web console:
echo    crc console
echo.
echo 2. Set up oc CLI (PowerShell):
echo    crc oc-env ^| Invoke-Expression
echo.
echo 3. Log in via CLI:
echo    oc login -u developer https://api.crc.testing:6443
echo.
echo 4. Useful commands:
echo    crc status    - Check cluster status
echo    crc stop      - Stop the cluster
echo    crc start     - Start the cluster
echo    crc delete    - Delete the cluster
echo.
echo ========================================
echo  Installation Complete! Happy Learning!
echo ========================================
echo.

pause
