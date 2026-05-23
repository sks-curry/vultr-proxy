@echo off
title Vultr Proxy
setlocal enabledelayedexpansion

echo ================================
echo   Vultr Proxy
echo ================================
echo   1. Los Angeles (149.248.16.188)
echo   2. New Jersey  (66.135.29.59)
echo ================================
set /p choice="Select (1/2): "

if "%choice%"=="1" (
    set HOST=vultr-la
    set PORT=8889
    set LABEL=Los Angeles
)
if "%choice%"=="2" (
    set HOST=vultr-nj
    set PORT=8890
    set LABEL=New Jersey
)
if not defined HOST (
    echo Invalid choice.
    pause
    exit /b
)

echo.
echo Starting: !LABEL! (!PORT!^)

echo [1/2] SSH forwarding...
"C:\windows\System32\OpenSSH\ssh.exe" -f -L !PORT!:127.0.0.1:8888 -N -o ExitOnForwardFailure=yes !HOST!

if errorlevel 1 (
    echo ERROR: SSH connection failed.
    pause
    exit /b
)

echo [2/2] Enabling system proxy...
(
echo $key  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
echo Set-ItemProperty -Path $key -Name ProxyServer -Value 'http=127.0.0.1:!PORT!;https=127.0.0.1:!PORT!'
echo Set-ItemProperty -Path $key -Name ProxyEnable -Value 1
echo Write-Host 'Proxy ON: http://127.0.0.1:!PORT!'
) > "%TEMP%\proxy-on.ps1"

powershell -ExecutionPolicy Bypass -File "%TEMP%\proxy-on.ps1"
del "%TEMP%\proxy-on.ps1" 2>nul

echo.
echo ================================
echo   !LABEL! proxy is ON
echo   127.0.0.1:!PORT!
echo   Press any key to DISABLE
echo ================================
pause >nul

echo Disabling proxy...
(
echo $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
echo Set-ItemProperty -Path $key -Name ProxyEnable -Value 0
echo Write-Host 'Proxy OFF'
) > "%TEMP%\proxy-off.ps1"

powershell -ExecutionPolicy Bypass -File "%TEMP%\proxy-off.ps1"
del "%TEMP%\proxy-off.ps1" 2>nul

taskkill /F /IM ssh.exe 2>nul
echo Done.
pause
