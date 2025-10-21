@echo off
REM Hadoop Windows Native Libraries Build Script (Batch version)
REM This is a wrapper script that calls the PowerShell build script

setlocal

set HADOOP_VERSION=3.4.2
set BUILD_DIR=.\build

REM Check if PowerShell is available
where pwsh >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Using PowerShell Core...
    pwsh -ExecutionPolicy Bypass -File "%~dp0build-hadoop-native.ps1" -HadoopVersion %HADOOP_VERSION% -BuildDir %BUILD_DIR%
) else (
    where powershell >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo Using Windows PowerShell...
        powershell -ExecutionPolicy Bypass -File "%~dp0build-hadoop-native.ps1" -HadoopVersion %HADOOP_VERSION% -BuildDir %BUILD_DIR%
    ) else (
        echo ERROR: PowerShell not found. Please install PowerShell.
        exit /b 1
    )
)

endlocal
