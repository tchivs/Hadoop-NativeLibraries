# 🔨 Hadoop Windows Native Libraries Build Guide

**[English](BUILD_GUIDE.md)** | **[简体中文](docs/BUILD_GUIDE-zh.md)**

This repository provides automated build tools for compiling Hadoop 3.x.x native libraries on Windows, including `hadoop.dll`, `hdfs.dll`, and `winutils.exe`.

## 📑 Table of Contents

- [📖 Overview](#overview)
- [🔧 Prerequisites](#prerequisites)
- [☁️ Building with GitHub Actions](#building-with-github-actions)
- [💻 Building Locally](#building-locally)
- [📦 Output Files](#output-files)
- [📋 Usage](#usage)
- [🐛 Troubleshooting](#troubleshooting)

## 📖 Overview

Hadoop native libraries provide performance-critical native implementations for Windows platforms. This project automates the build process through:

1. ☁️ **GitHub Actions** - Automated cloud builds triggered manually or on code changes
2. 💻 **Local Build Scripts** - PowerShell and batch scripts for local compilation

### 📦 What Gets Built

- 🔧 **winutils.exe** - Windows utilities for Hadoop
- 📦 **hadoop.dll** - Core Hadoop native library
- 💾 **hdfs.dll** - HDFS native library
- ⚡ **Other native components** - Compression codecs, CRC32, etc.

## 🔧 Prerequisites

### ☁️ For GitHub Actions (Automated)

No local setup required! GitHub Actions runs the build in the cloud.

### 💻 For Local Builds

#### ✅ Required Software

1. **Visual Studio 2019 or later**
   - Install "Desktop development with C++" workload
   - Download: https://visualstudio.microsoft.com/downloads/

2. **Java Development Kit (JDK) 8**
   - Download: https://adoptium.net/temurin/releases/?version=8
   - Set `JAVA_HOME` environment variable

3. **Apache Maven 3.6+**
   - Download: https://maven.apache.org/download.cgi
   - Add to PATH

4. **CMake 3.19+**
   - Download: https://cmake.org/download/
   - Or install via chocolatey: `choco install cmake`

5. **Protocol Buffers**
   - Install via chocolatey: `choco install protoc`

**Note:** zlib and other native dependencies are automatically handled by Maven during the build process.

#### Quick Setup with Chocolatey

```powershell
# Install Chocolatey first if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install dependencies
choco install -y cmake protoc
```

## ☁️ Building with GitHub Actions

### 🚀 Triggering a Build

1. Go to your repository on GitHub
2. Click the "Actions" tab
3. Select "Build Hadoop Windows Native Libraries" workflow
4. Click "Run workflow"
5. Enter the Hadoop version (e.g., `3.3.4`, `3.4.2`)
6. Select architecture: `x64`, `x86`, or `both`
7. Click "Run workflow"

**Architecture Options:**
- **x64**: Build 64-bit version only (for 64-bit Java JVM)
- **x86**: Build 32-bit version only (for 32-bit Java JVM)
- **both**: Build both x64 and x86 versions simultaneously

### ⚙️ What Happens

The GitHub Action will:

1. 🔧 Set up Windows build environment
2. 📦 Install all required dependencies
3. 📥 Download Hadoop source code
4. 🔨 Compile native libraries
5. 📦 Package the artifacts
6. 🚀 Create a GitHub Release with the binaries

### 📥 Downloading Build Artifacts

After the workflow completes:

- 📁 **Artifacts**: Available in the workflow run for 90 days
- 🏷️ **Releases**: Permanent releases tagged as `hadoop-{version}-windows-{arch}`

## 💻 Building Locally

### 🔹 Using PowerShell Script (Recommended)

```powershell
# Navigate to the repository
cd Hadoop-NativeLibraries

# Build x64 version (default)
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.4.2"

# Build x86 version
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.4.2" -Architecture "x86"

# Build both x64 and x86 versions
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.4.2" -Architecture "both"

# With custom build directory
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.4.2" -BuildDir "C:\builds\hadoop"

# Clean build (remove existing build directory)
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.4.2" -CleanBuild

# Skip download (if source already exists)
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.4.2" -SkipDownload
```

**Script Parameters:**
- `-HadoopVersion`: Version to build (e.g., "3.4.2")
- `-Architecture`: Target architecture - `x64` (default), `x86`, or `both`
- `-BuildDir`: Custom build directory (default: `.\build`)
- `-CleanBuild`: Remove existing build directory before building
- `-SkipDownload`: Skip downloading source (if already present)
- `-SkipBuild`: Skip build phase (for testing)

### 🔹 Using Batch Script

```cmd
cd Hadoop-NativeLibraries
scripts\build-hadoop-native.bat
```

### 🔹 Manual Build Steps

If you prefer to build manually:

```cmd
# 1. Download Hadoop source
curl -L -O https://archive.apache.org/dist/hadoop/common/hadoop-3.4.2/hadoop-3.4.2-src.tar.gz
tar -xzf hadoop-3.4.2-src.tar.gz
cd hadoop-3.4.2-src

# 2. Set up Visual Studio environment
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

# 3. Build with Maven
mvn package -Pdist,native-win -DskipTests -Dtar -Dmaven.javadoc.skip=true

# 4. Find output in:
# hadoop-dist\target\hadoop-3.4.2\bin\
# hadoop-dist\target\hadoop-3.4.2\lib\native\
```

### ⏱️ Build Time

Expect the build to take **15-30 minutes** depending on your system.

## 📦 Output Files

After a successful build, you'll find:

```
hadoop-{version}-windows-{arch}/
├── bin/
│   ├── winutils.exe
│   ├── hadoop.dll
│   ├── hdfs.dll
│   └── other DLLs and executables
├── lib/
│   └── native library files
└── BUILD_INFO.txt
```

Where `{arch}` is either `x64` or `x86`.

### 📄 File Descriptions

| File | Description |
|------|-------------|
| 🔧 `winutils.exe` | Windows utilities for file operations, permissions, etc. |
| 📦 `hadoop.dll` | Core Hadoop native library (compression, CRC32, etc.) |
| 💾 `hdfs.dll` | HDFS native operations |
| 📝 `BUILD_INFO.txt` | Build metadata and version information |

## 📋 Usage

### 📥 Installing Built Libraries

1. Copy the `hadoop-{version}-windows-native` directory to your local drive
2. Set environment variables:

```cmd
set HADOOP_HOME=C:\path\to\hadoop-{version}-windows-native
set PATH=%PATH%;%HADOOP_HOME%\bin
```

Or in PowerShell:

```powershell
$env:HADOOP_HOME="C:\path\to\hadoop-{version}-windows-native"
$env:PATH="$env:PATH;$env:HADOOP_HOME\bin"
```

### 🔒 Permanent Environment Variables

**Windows 10/11:**

1. 🔍 Search for "Environment Variables" in Start Menu
2. ⚙️ Click "Edit system environment variables"
3. 🔘 Click "Environment Variables" button
4. ➕ Add `HADOOP_HOME` under "System variables"
5. ✏️ Edit `Path` and add `%HADOOP_HOME%\bin`

### ✅ Verifying Installation

```cmd
# Check if winutils is accessible
where winutils

# Check Hadoop native libraries (requires Hadoop installation)
hadoop checknative -a
```

Expected output:
```
Native library checking:
hadoop: true C:\path\to\hadoop.dll
zlib:   true
...
```

## 🐛 Troubleshooting

### ❌ Build Fails with "Maven not found"

**💡 Solution:** Install Maven and add to PATH
```powershell
choco install maven
```

### ❌ Build Fails with "CMake not found"

**💡 Solution:** Install CMake
```powershell
choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'
```

### ❌ Build Fails with "Cannot find vcvars64.bat"

**💡 Solution:** Install Visual Studio with C++ tools
- 📂 Open Visual Studio Installer
- ⚙️ Modify installation
- ✅ Check "Desktop development with C++"

### ❌ Build Fails with Protocol Buffer Errors

**💡 Solution:** Install Protocol Buffers
```powershell
choco install protoc
```

### ❌ "Unable to load native-hadoop library" Runtime Error

**💡 Solutions:**

1. ✅ Verify `HADOOP_HOME` is set correctly
2. ✅ Ensure `%HADOOP_HOME%\bin` is in PATH
3. 🏗️ **Check DLL architecture matches JVM architecture:**
   - For 64-bit Java: Use `hadoop-{version}-windows-x64`
   - For 32-bit Java: Use `hadoop-{version}-windows-x86`
   - Verify Java arch with: `java -version` (look for "64-Bit" or "32-Bit")
4. 📁 Verify all DLLs are present in `bin` directory

### ⚠️ Architecture Mismatch Error

If you see errors like "Can't load IA 32-bit .dll on a AMD 64-bit platform":

**❗ Problem:** The native library architecture doesn't match your Java JVM architecture.

**💡 Solution:**
```cmd
# Check your Java version
java -version

# Look for:
# - "64-Bit Server VM" = You need x64 native libraries
# - No "64-Bit" mention = You need x86 native libraries

# Download/build the matching architecture
```

### ❌ GitHub Actions Build Fails

**🔍 Common causes:**

1. ⚠️ Invalid Hadoop version specified
2. 📦 Hadoop version not available in Apache archives
3. 🌐 Temporary download issues

**💡 Solution:** Check the Actions log for specific errors and re-run the workflow.

## 📦 Supported Hadoop Versions

This build system supports:

- ✅ Hadoop 3.3.x series (tested: 3.3.4, 3.3.5, 3.3.6)
- ✅ Hadoop 3.4.x series (tested: 3.4.0, 3.4.1, 3.4.2)

For other versions, try building - most 3.x versions should work.

## 🔗 References

- 📖 [Official Hadoop Native Libraries Guide](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/NativeLibraries.html)
- 📥 [Hadoop Release Downloads](https://hadoop.apache.org/releases.html)
- 🇨🇳 [Build Instructions (Chinese)](https://www.jianshu.com/p/1b4cbabfd899)

## 📄 License

![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

This build system is provided as-is. Hadoop itself is licensed under Apache License 2.0.

## 🤝 Contributing

![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

Contributions welcome! Please:

1. ✅ Test builds with different Hadoop versions
2. 🐛 Report issues with specific error messages
3. 🔧 Submit PRs with improvements to build scripts

---

<div align="center">

**❓ Need Help?**

Open an issue on GitHub with:
- 📦 Hadoop version
- 💻 Build environment details (Windows version, Visual Studio version)
- 📝 Complete error message and logs

**Made with ❤️ for the Hadoop community**

</div>
