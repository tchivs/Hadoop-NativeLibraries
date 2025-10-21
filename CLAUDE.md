# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository provides an automated build system for Hadoop 3.x.x native libraries on Windows platforms. It builds:
- `winutils.exe` - Windows utilities for Hadoop
- `hadoop.dll` - Core Hadoop native library
- `hdfs.dll` - HDFS native library
- Other native components (compression codecs, CRC32, etc.)

These binaries are required to run Hadoop on Windows without encountering "no native library" and "access0" errors.

## Repository Structure

```
Hadoop-NativeLibraries/
├── .github/
│   └── workflows/
│       └── build-hadoop-windows.yml    # GitHub Actions workflow for automated builds
├── scripts/
│   ├── build-hadoop-native.ps1         # PowerShell build script (main)
│   └── build-hadoop-native.bat         # Batch wrapper script
├── BUILD_GUIDE.md                      # Comprehensive build documentation
├── CLAUDE.md                           # This file
└── README.md                           # User-facing documentation
```

## Architecture

### GitHub Actions Workflow

**File:** `.github/workflows/build-hadoop-windows.yml`

This workflow automates the entire build process:
1. Triggers manually via `workflow_dispatch` with configurable Hadoop version
2. Sets up Windows build environment (Visual Studio, Java, Maven, CMake)
3. Downloads Hadoop source from Apache archives
4. Compiles native libraries using Maven with `native-win` profile
5. Packages artifacts and creates GitHub releases

**Key features:**
- Runs on `windows-latest` GitHub runner
- Uses Visual Studio 2022 build tools
- Installs dependencies via Chocolatey
- Creates releases with automatic tagging

### Local Build Script

**File:** `scripts/build-hadoop-native.ps1`

A comprehensive PowerShell script that:
- Downloads Hadoop source code
- Validates build environment (Visual Studio, Maven, CMake, protoc)
- Executes Maven build with proper Visual Studio environment
- Packages output artifacts
- Creates build metadata

**Parameters:**
- `HadoopVersion` - Version to build (default: 3.4.2)
- `BuildDir` - Build directory (default: .\build)
- `SkipDownload` - Skip source download
- `SkipBuild` - Skip build phase
- `CleanBuild` - Clean build directory first

## Common Development Tasks

### Testing GitHub Actions Workflow Locally

GitHub Actions cannot be fully tested locally, but you can:
1. Use `act` tool to simulate: https://github.com/nektos/act
2. Test the PowerShell script directly which has similar logic

### Modifying Build Process

**To change build flags:**
Edit line in `build-hadoop-windows.yml` and `build-hadoop-native.ps1`:
```
mvn package -Pdist,native-win -DskipTests -Dtar
```

**To add new dependencies:**
1. Add to GitHub Actions workflow in the "Install dependencies" step
2. Add validation checks in PowerShell script

### Supporting New Hadoop Versions

The build system should work with any Hadoop 3.x version. To add explicit support:
1. Test build with new version: `.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.x.x"`
2. Update supported versions list in README.md if successful

## Build System Technical Details

### Maven Profile

Uses `-Pdist,native-win` profile which:
- Activates Windows-specific native compilation
- Uses CMake for native builds
- Requires Visual Studio C++ compiler
- Links against zlib and OpenSSL

### Build Output

After successful build, artifacts are in:
```
build/hadoop-{version}-src/hadoop-dist/target/hadoop-{version}/
├── bin/
│   ├── winutils.exe
│   ├── hadoop.dll
│   ├── hdfs.dll
│   └── other binaries
└── lib/
    └── native/
        └── additional native libraries
```

### Environment Requirements

**Visual Studio:**
- Must have "Desktop development with C++" workload
- Uses `vcvars64.bat` to set up build environment
- Requires x64 native tools

**Maven:**
- Version 3.6+ required
- Java 8 JDK required (newer versions may have compatibility issues)

**CMake:**
- Version 3.19+ required for Hadoop 3.3+
- Must be in PATH

**Protocol Buffers:**
- Required for Hadoop RPC serialization
- Must be in PATH

## Troubleshooting Build Issues

### Common Issues

1. **Maven build fails with "Cannot find vcvars64.bat"**
   - Visual Studio not installed or C++ tools missing
   - Fix: Install Visual Studio with C++ workload

2. **CMake errors during native build**
   - CMake not in PATH or wrong version
   - Fix: `choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'`

3. **Protocol buffer compilation errors**
   - protoc not installed or not in PATH
   - Fix: `choco install protoc`

4. **Download failures in GitHub Actions**
   - Apache mirror issues or version doesn't exist
   - Fix: Check version exists at https://archive.apache.org/dist/hadoop/common/

### Debugging Local Builds

The PowerShell script provides colored output:
- **[INFO]** - Informational messages
- **[SUCCESS]** - Successful operations
- **[WARNING]** - Non-fatal issues
- **[ERROR]** - Build failures

Check build logs in:
```
build/hadoop-{version}-src/build-native.bat
```

## Key Files to Understand

1. **`.github/workflows/build-hadoop-windows.yml`** - Complete GitHub Actions workflow
2. **`scripts/build-hadoop-native.ps1`** - Main build logic
3. **`BUILD_GUIDE.md`** - User-facing documentation with troubleshooting

## References

- Official Hadoop Native Libraries Guide: https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/NativeLibraries.html
- Hadoop source builds: https://cwiki.apache.org/confluence/display/HADOOP/HowToContribute
- Windows build guide (Chinese): https://www.jianshu.com/p/1b4cbabfd899
