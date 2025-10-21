# Hadoop Windows Native Libraries Build Script
# This script builds Hadoop native libraries (hadoop.dll, winutils.exe, etc.) on Windows

param(
    [Parameter(Mandatory=$false)]
    [string]$HadoopVersion = "3.4.2",

    [Parameter(Mandatory=$false)]
    [string]$BuildDir = ".\build",

    [Parameter(Mandatory=$false)]
    [ValidateSet("x64", "x86", "both")]
    [string]$Architecture = "x64",

    [Parameter(Mandatory=$false)]
    [switch]$SkipDownload = $false,

    [Parameter(Mandatory=$false)]
    [switch]$SkipBuild = $false,

    [Parameter(Mandatory=$false)]
    [switch]$CleanBuild = $false
)

$ErrorActionPreference = "Stop"

# Color output functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

# Main script
Write-Info "Hadoop Windows Native Libraries Build Script"
Write-Info "=============================================="
Write-Info "Hadoop Version: $HadoopVersion"
Write-Info "Build Directory: $BuildDir"
Write-Info "Architecture: $Architecture"
Write-Info ""

# Determine which architectures to build
$architecturesToBuild = @()
if ($Architecture -eq "both") {
    $architecturesToBuild = @("x64", "x86")
    Write-Info "Building for both x64 and x86 architectures"
} else {
    $architecturesToBuild = @($Architecture)
    Write-Info "Building for $Architecture architecture only"
}

# Create build directory
if ($CleanBuild -and (Test-Path $BuildDir)) {
    Write-Info "Cleaning build directory..."
    Remove-Item -Recurse -Force $BuildDir
}

if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
    Write-Success "Created build directory: $BuildDir"
}

Set-Location $BuildDir

# Download Hadoop source
if (-not $SkipDownload) {
    Write-Info "Downloading Hadoop $HadoopVersion source code..."

    $sourceArchive = "hadoop-$HadoopVersion-src.tar.gz"
    $sourceUrl = "https://archive.apache.org/dist/hadoop/common/hadoop-$HadoopVersion/$sourceArchive"

    if (Test-Path $sourceArchive) {
        Write-Warning-Custom "Source archive already exists, skipping download"
    } else {
        try {
            Invoke-WebRequest -Uri $sourceUrl -OutFile $sourceArchive -UseBasicParsing
            Write-Success "Downloaded $sourceArchive"
        } catch {
            Write-Error-Custom "Failed to download Hadoop source: $_"
            exit 1
        }
    }

    # Extract source
    $sourceDir = "hadoop-$HadoopVersion-src"
    if (Test-Path $sourceDir) {
        Write-Warning-Custom "Source directory already exists, skipping extraction"
    } else {
        Write-Info "Extracting source archive..."
        tar -xzf $sourceArchive
        if (Test-Path $sourceDir) {
            Write-Success "Extracted source to $sourceDir"
        } else {
            Write-Error-Custom "Failed to extract source archive"
            exit 1
        }
    }
} else {
    Write-Warning-Custom "Skipping download (SkipDownload flag set)"
}

# Check for Visual Studio
Write-Info "Checking for Visual Studio..."
$vsWherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsPath = $null
if (Test-Path $vsWherePath) {
    $vsPath = & $vsWherePath -latest -property installationPath
    Write-Success "Found Visual Studio at: $vsPath"

    # Verify build tools exist
    $vcvars64Path = "$vsPath\VC\Auxiliary\Build\vcvars64.bat"
    $vcvars32Path = "$vsPath\VC\Auxiliary\Build\vcvars32.bat"

    if (Test-Path $vcvars64Path) {
        Write-Info "Visual Studio x64 build tools found"
    }
    if (Test-Path $vcvars32Path) {
        Write-Info "Visual Studio x86 build tools found"
    }

    if (-not (Test-Path $vcvars64Path) -and -not (Test-Path $vcvars32Path)) {
        Write-Error-Custom "vcvars batch files not found. Please install Visual Studio with C++ tools."
        exit 1
    }
} else {
    Write-Warning-Custom "vswhere.exe not found. Make sure Visual Studio is installed."
}

# Check for Maven
Write-Info "Checking for Maven..."
try {
    $mvnVersion = mvn -version 2>&1 | Select-Object -First 1
    Write-Success "Maven found: $mvnVersion"
} catch {
    Write-Error-Custom "Maven not found. Please install Maven and add it to PATH."
    exit 1
}

# Check for CMake
Write-Info "Checking for CMake..."
try {
    $cmakeVersion = cmake --version 2>&1 | Select-Object -First 1
    Write-Success "CMake found: $cmakeVersion"
} catch {
    Write-Error-Custom "CMake not found. Please install CMake and add it to PATH."
    exit 1
}

# Check for Protocol Buffers
Write-Info "Checking for Protocol Buffers..."
try {
    $protocVersion = protoc --version 2>&1
    Write-Success "Protocol Buffers found: $protocVersion"
} catch {
    Write-Warning-Custom "protoc not found. Build may fail without Protocol Buffers."
}

# Build native libraries
if (-not $SkipBuild) {
    $sourceDir = "hadoop-$HadoopVersion-src"

    # Build for each architecture
    foreach ($arch in $architecturesToBuild) {
        Write-Info "`n=============================================="
        Write-Info "Building Hadoop native libraries for $arch"
        Write-Info "=============================================="

        # Determine vcvars batch file
        $vcvarsBat = if ($arch -eq "x64") { "vcvars64.bat" } else { "vcvars32.bat" }
        $vcvarsPath = "$vsPath\VC\Auxiliary\Build\$vcvarsBat"
        $platformName = if ($arch -eq "x64") { "win64" } else { "win32" }

        if (-not (Test-Path $vcvarsPath)) {
            Write-Error-Custom "Visual Studio build tools for $arch not found at: $vcvarsPath"
            Write-Error-Custom "Please install Visual Studio with C++ support for $arch"
            continue
        }

        Set-Location $sourceDir

        # Create a build batch file to run Maven with Visual Studio environment
        $buildBat = @"
@echo off
call "$vcvarsPath"
echo Building Hadoop native libraries with Maven for $arch...
mvn package -Pdist,native-win -DskipTests -Dtar -Dmaven.javadoc.skip=true -Dcontainer-executor.conf.dir=/etc/hadoop -Drequire.fuse=false -Dexec.skip=true
"@

        $buildBat | Out-File -FilePath "build-native-$arch.bat" -Encoding ASCII

        Write-Info "Starting Maven build for $arch (this may take 15-30 minutes)..."
        Write-Info "Command: mvn package -Pdist,native-win -DskipTests -Dtar"

        cmd /c "build-native-$arch.bat"

        if ($LASTEXITCODE -ne 0) {
            Write-Error-Custom "Build failed for $arch with exit code $LASTEXITCODE"
            Set-Location ..
            continue
        }

        Write-Success "Build completed successfully for $arch!"

        # Verify build output
        $distPath = "hadoop-dist\target\hadoop-$HadoopVersion"
        if (Test-Path $distPath) {
            Write-Success "Distribution created at: $distPath"

            # List built native files
            Write-Info "`nBuilt native files for $arch :"
            Write-Info "===================="

            if (Test-Path "$distPath\bin\winutils.exe") {
                $size = (Get-Item "$distPath\bin\winutils.exe").Length
                Write-Success "  winutils.exe: $size bytes"
            }

            if (Test-Path "$distPath\bin\hadoop.dll") {
                $size = (Get-Item "$distPath\bin\hadoop.dll").Length
                Write-Success "  hadoop.dll: $size bytes"
            }

            if (Test-Path "$distPath\bin\hdfs.dll") {
                $size = (Get-Item "$distPath\bin\hdfs.dll").Length
                Write-Success "  hdfs.dll: $size bytes"
            }

            # List all important files
            Write-Info "`nAll important files in bin directory:"
            Get-ChildItem -Path "$distPath\bin" -Include *.exe,*.dll,*.cmd,*.bat -Recurse | ForEach-Object {
                Write-Host "  $($_.Name)" -ForegroundColor White
            }

            # Create output package
            Set-Location ..
            $outputDir = "hadoop-$HadoopVersion-windows-$arch"

            if (Test-Path $outputDir) {
                Remove-Item -Recurse -Force $outputDir
            }

            New-Item -ItemType Directory -Force -Path "$outputDir\bin" | Out-Null
            New-Item -ItemType Directory -Force -Path "$outputDir\lib" | Out-Null

            # Copy artifacts
            Write-Info "`nPackaging artifacts for $arch..."

            if (Test-Path "$sourceDir\$distPath\bin") {
                Copy-Item "$sourceDir\$distPath\bin\*" -Destination "$outputDir\bin\" -Recurse -Force
                Write-Success "Copied bin files"
            }

            if (Test-Path "$sourceDir\$distPath\lib\native") {
                Copy-Item "$sourceDir\$distPath\lib\native\*" -Destination "$outputDir\lib\" -Recurse -Force
                Write-Success "Copied native library files"
            }

            # Verify architecture using dumpbin if available
            $dumpbinPath = "$vsPath\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe"
            if (Test-Path $dumpbinPath) {
                $dumpbinExe = (Get-Item $dumpbinPath | Select-Object -First 1).FullName
                Write-Info "`nVerifying architecture of hadoop.dll:"
                & $dumpbinExe /headers "$outputDir\bin\hadoop.dll" | Select-String "machine"
            }

            # Create build info
            $buildInfo = @"
Hadoop Version: $HadoopVersion
Build Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Architecture: $arch
Platform: Windows $platformName
PowerShell Version: $($PSVersionTable.PSVersion)
Builder: $env:USERNAME@$env:COMPUTERNAME

Build Command:
mvn package -Pdist,native-win -DskipTests -Dtar

IMPORTANT: This build is for $arch architecture only.
Make sure your Java JVM matches this architecture ($arch).

For usage instructions, see README.md
"@

            $buildInfo | Out-File "$outputDir\BUILD_INFO.txt" -Encoding UTF8
            Write-Success "Created BUILD_INFO.txt"

            Write-Success "`nPackage created: $outputDir"
            Write-Info "You can now copy this directory to your Hadoop installation"

        } else {
            Write-Error-Custom "Distribution directory not found for $arch. Build may have failed."
            Set-Location ..
            continue
        }

        # Return to build directory for next iteration
        Set-Location ..
    }

} else {
    Write-Warning-Custom "Skipping build (SkipBuild flag set)"
}

Write-Success "`n=============================================="
Write-Success "Build script completed successfully!"
Write-Success "=============================================="
