# Hadoop Windows Native Libraries

<div align="center">

[![Build Status](https://github.com/tchivs/Hadoop-NativeLibraries/actions/workflows/build-hadoop-windows.yml/badge.svg)](https://github.com/tchivs/Hadoop-NativeLibraries/actions/workflows/build-hadoop-windows.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![Hadoop](https://img.shields.io/badge/Hadoop-3.x-orange.svg)](https://hadoop.apache.org/)
[![Architecture](https://img.shields.io/badge/Architecture-x64%20%7C%20x86-green.svg)](#supported-architectures)

**[English](README.md)** | **[简体中文](docs/README-zh.md)**

</div>

> 🚀 Automated build system for Hadoop 3.x.x native libraries on Windows platforms

## 📖 Overview

This repository provides automated builds of Hadoop native libraries for Windows, including:

- 🔧 **winutils.exe** - Windows utilities for Hadoop
- 📦 **hadoop.dll** - Core Hadoop native library
- 💾 **hdfs.dll** - HDFS native library
- ⚡ **Other native components** - Compression codecs, CRC32, etc.

These native libraries are required to run Hadoop on Windows without encountering "no native library" and "access0" errors.

## 🚀 Quick Start

### 📥 Download Pre-built Binaries

1. Go to [Releases](https://github.com/tchivs/Hadoop-NativeLibraries/releases)
2. Download the version matching your Hadoop installation
3. Extract to your local drive
4. Set environment variables:

```cmd
set HADOOP_HOME=C:\path\to\hadoop-{version}-windows-native
set PATH=%PATH%;%HADOOP_HOME%\bin
```

### 🔨 Build from Source

#### ☁️ Using GitHub Actions (Recommended)

1. Go to the **Actions** tab
2. Select "Build Hadoop Windows Native Libraries"
3. Click "Run workflow"
4. Enter Hadoop version (e.g., `3.3.4`)
5. Select architecture: `x64`, `x86`, or `both`
6. Download artifacts from the completed workflow

#### 💻 Build Locally

```powershell
# Clone this repository
git clone https://github.com/tchivs/Hadoop-NativeLibraries.git
cd Hadoop-NativeLibraries

# Build x64 version (default)
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.3.4"

# Build x86 version
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.3.4" -Architecture "x86"

# Build both x86 and x64
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.3.4" -Architecture "both"
```

See [BUILD_GUIDE.md](BUILD_GUIDE.md) for detailed build instructions.

## ✨ Features

- ☁️ **Automated GitHub Actions builds** - Build in the cloud without local setup
- 🔄 **Multi-version support** - Build any Hadoop 3.x.x version
- 🏗️ **Multi-architecture support** - Build for x64, x86, or both simultaneously
- 💻 **Local build scripts** - PowerShell and batch scripts for local compilation
- 📚 **Comprehensive documentation** - Step-by-step guides and troubleshooting
- ✅ **Architecture verification** - Automatic verification of built binary architecture

## 📚 Documentation

- 📖 [BUILD_GUIDE.md](BUILD_GUIDE.md) - Complete build instructions and troubleshooting ([中文版](docs/BUILD_GUIDE-zh.md))
- 🤖 [CLAUDE.md](CLAUDE.md) - Repository guidance for Claude Code

## 📦 Supported Versions

![Hadoop 3.3.x](https://img.shields.io/badge/Hadoop-3.3.x-orange.svg)
![Hadoop 3.4.x](https://img.shields.io/badge/Hadoop-3.4.x-orange.svg)

- Hadoop 3.3.x series (3.3.4, 3.3.5, 3.3.6)
- Hadoop 3.4.x series (3.4.0, 3.4.1, 3.4.2)

## 🏗️ Supported Architectures

![x64](https://img.shields.io/badge/x64-64--bit-success.svg)
![x86](https://img.shields.io/badge/x86-32--bit-success.svg)

- **x64 (64-bit)** - For 64-bit Java JVM (most common)
- **x86 (32-bit)** - For 32-bit Java JVM (legacy systems)

⚠️ **Important**: The native library architecture must match your Java JVM architecture. Verify with `java -version`.

## 🔧 Prerequisites for Local Builds

![Visual Studio](https://img.shields.io/badge/Visual%20Studio-2019+-5C2D91.svg?logo=visual-studio)
![Java](https://img.shields.io/badge/Java-JDK%208-007396.svg?logo=java)
![Maven](https://img.shields.io/badge/Maven-3.6+-C71A36.svg?logo=apache-maven)
![CMake](https://img.shields.io/badge/CMake-3.19+-064F8C.svg?logo=cmake)

- Visual Studio 2019+ with C++ tools
- Java JDK 8
- Apache Maven 3.6+
- CMake 3.19+
- Protocol Buffers
- zlib and OpenSSL development libraries

## 📋 Usage

After installing the native libraries:

```cmd
# Verify installation
where winutils

# Check native library loading (requires Hadoop)
hadoop checknative -a
```

Expected output:
```
Native library checking:
hadoop: true C:\path\to\hadoop.dll
zlib:   true
...
```

## 📁 Project Structure

```
Hadoop-NativeLibraries/
├── .github/
│   └── workflows/
│       └── build-hadoop-windows.yml    # GitHub Actions workflow
├── scripts/
│   ├── build-hadoop-native.ps1         # PowerShell build script
│   └── build-hadoop-native.bat         # Batch wrapper script
├── docs/
│   ├── README-zh.md                    # Chinese README
│   └── BUILD_GUIDE-zh.md               # Chinese build guide
├── BUILD_GUIDE.md                      # Detailed build documentation
├── CLAUDE.md                           # Claude Code guidance
└── README.md                           # This file
```

## 🔗 References

- 📖 [Official Hadoop Native Libraries Guide](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/NativeLibraries.html)
- 📦 [Hadoop Releases](https://hadoop.apache.org/releases.html)
- 🇨🇳 [Build Instructions (Chinese)](https://www.jianshu.com/p/1b4cbabfd899)

## 🤝 Contributing

![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

Contributions are welcome! Please:

1. ✅ Test with different Hadoop versions
2. 🐛 Report issues with complete error logs
3. 🔧 Submit PRs with improvements

## 📄 License

![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

Apache License 2.0 - See Hadoop project for details.

## 🔧 Troubleshooting

See [BUILD_GUIDE.md - Troubleshooting](BUILD_GUIDE.md#troubleshooting) for common issues and solutions.

---

<div align="center">

**⭐ Star this repo if you find it helpful!**

Made with ❤️ for the Hadoop community

</div>
