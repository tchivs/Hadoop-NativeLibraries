# Hadoop Windows 原生库

[![构建 Hadoop Windows 原生库](https://github.com/YOUR_USERNAME/Hadoop-NativeLibraries/actions/workflows/build-hadoop-windows.yml/badge.svg)](https://github.com/YOUR_USERNAME/Hadoop-NativeLibraries/actions/workflows/build-hadoop-windows.yml)

> Hadoop 3.x.x Windows 平台原生库的自动化构建系统

[English](../README.md) | 简体中文

## 概述

本仓库提供 Hadoop Windows 平台原生库的自动化构建，包括：

- **winutils.exe** - Hadoop 的 Windows 实用工具
- **hadoop.dll** - Hadoop 核心原生库
- **hdfs.dll** - HDFS 原生库
- **其他原生组件** - 压缩编解码器、CRC32 等

这些原生库是在 Windows 上运行 Hadoop 所必需的，可以避免 "no native library" 和 "access0" 错误。

## 快速开始

### 下载预编译的二进制文件

1. 前往 [Releases](https://github.com/YOUR_USERNAME/Hadoop-NativeLibraries/releases) 页面
2. 下载与你的 Hadoop 安装版本匹配的文件
3. 解压到本地磁盘
4. 设置环境变量：

```cmd
set HADOOP_HOME=C:\path\to\hadoop-{version}-windows-{arch}
set PATH=%PATH%;%HADOOP_HOME%\bin
```

### 从源码构建

#### 使用 GitHub Actions（推荐）

1. 进入仓库的 **Actions** 标签页
2. 选择 "Build Hadoop Windows Native Libraries" 工作流
3. 点击 "Run workflow"
4. 输入 Hadoop 版本（例如 `3.4.2`）
5. 选择架构：`x64`、`x86` 或 `both`
6. 从完成的工作流中下载构建产物

#### 本地构建

```powershell
# 克隆本仓库
git clone https://github.com/YOUR_USERNAME/Hadoop-NativeLibraries.git
cd Hadoop-NativeLibraries

# 构建 x64 版本（默认）
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.4.2"

# 构建 x86 版本
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.4.2" -Architecture "x86"

# 同时构建 x86 和 x64 版本
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.4.2" -Architecture "both"
```

详细构建说明请参阅 [BUILD_GUIDE-zh.md](BUILD_GUIDE-zh.md)。

## 功能特性

- **自动化 GitHub Actions 构建** - 无需本地配置，在云端构建
- **多版本支持** - 支持构建任意 Hadoop 3.x.x 版本
- **多架构支持** - 支持 x64、x86 或同时构建两种架构
- **本地构建脚本** - 提供 PowerShell 和批处理脚本用于本地编译
- **完善的文档** - 包含详细的步骤指南和故障排除
- **架构验证** - 自动验证构建的二进制文件架构

## 文档

- [BUILD_GUIDE-zh.md](BUILD_GUIDE-zh.md) - 完整的构建说明和故障排除
- [CLAUDE.md](../CLAUDE.md) - Claude Code 的仓库指南（英文）

## 支持的版本

- Hadoop 3.3.x 系列（3.4.2, 3.3.5, 3.3.6）
- Hadoop 3.4.x 系列（3.4.0, 3.4.1, 3.4.2）

## 支持的架构

- **x64（64位）** - 适用于 64位 Java JVM（最常见）
- **x86（32位）** - 适用于 32位 Java JVM（旧系统）

⚠️ **重要提示**：原生库架构必须与你的 Java JVM 架构匹配。使用 `java -version` 命令验证。

## 本地构建的前置要求

- Visual Studio 2019+ 及 C++ 工具
- Java JDK 8
- Apache Maven 3.6+
- CMake 3.19+
- Protocol Buffers
- zlib 和 OpenSSL 开发库

## 使用方法

安装原生库后：

```cmd
# 验证安装
where winutils

# 检查原生库加载情况（需要已安装 Hadoop）
hadoop checknative -a
```

预期输出：
```
Native library checking:
hadoop: true C:\path\to\hadoop.dll
zlib:   true
...
```

## 项目结构

```
Hadoop-NativeLibraries/
├── .github/
│   └── workflows/
│       └── build-hadoop-windows.yml    # GitHub Actions 工作流
├── scripts/
│   ├── build-hadoop-native.ps1         # PowerShell 构建脚本
│   └── build-hadoop-native.bat         # 批处理包装脚本
├── docs/
│   ├── README-zh.md                    # 中文自述文件（本文件）
│   └── BUILD_GUIDE-zh.md               # 中文构建指南
├── BUILD_GUIDE.md                      # 详细构建文档（英文）
├── CLAUDE.md                           # Claude Code 指南
└── README.md                           # 英文自述文件
```

## 参考资料

- [Hadoop 原生库官方指南](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/NativeLibraries.html)
- [Hadoop 发行版下载](https://hadoop.apache.org/releases.html)
- [构建说明（中文）](https://www.jianshu.com/p/1b4cbabfd899)

## 贡献

欢迎贡献！请：

1. 使用不同的 Hadoop 版本进行测试
2. 报告问题时提供完整的错误日志
3. 提交改进构建脚本的 PR

## 许可证

Apache License 2.0 - 详见 Hadoop 项目。

## 故障排除

常见问题和解决方案请参阅 [BUILD_GUIDE-zh.md - 故障排除](BUILD_GUIDE-zh.md#故障排除)。

## 常见问题

### 架构不匹配怎么办？

如果看到类似 "Can't load IA 32-bit .dll on a AMD 64-bit platform" 的错误：

```cmd
# 检查你的 Java 版本
java -version

# 查找：
# - "64-Bit Server VM" = 你需要 x64 原生库
# - 没有 "64-Bit" 字样 = 你需要 x86 原生库
```

### 支持 ARM 架构吗？

目前不支持。Hadoop 官方在 Windows ARM 平台上的原生库支持还不完整。

**推荐方案**：
- 在 ARM 设备上使用 WSL2（Windows Subsystem for Linux）
- 在 WSL2 中运行 Linux 版本的 Hadoop
- 或使用 Hadoop 的纯 Java 实现（性能较低）

### 如何验证架构是否匹配？

```cmd
# 检查 Java 架构
java -version

# 使用 PowerShell 检查 DLL 架构（如果已安装 Visual Studio）
dumpbin /headers hadoop.dll | Select-String "machine"

# x64 会显示: machine (x64)
# x86 会显示: machine (x86)
```

---

**注意**：请将上述 URL 中的 `YOUR_USERNAME` 替换为你的实际 GitHub 用户名。
