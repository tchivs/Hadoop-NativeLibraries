# Hadoop Windows 原生库构建指南

本仓库提供用于编译 Hadoop 3.x.x Windows 原生库的自动化构建工具，包括 `hadoop.dll`、`hdfs.dll` 和 `winutils.exe`。

[English](../BUILD_GUIDE.md) | 简体中文

## 目录

- [概述](#概述)
- [前置要求](#前置要求)
- [使用 GitHub Actions 构建](#使用-github-actions-构建)
- [本地构建](#本地构建)
- [输出文件](#输出文件)
- [使用方法](#使用方法)
- [故障排除](#故障排除)

## 概述

Hadoop 原生库为 Windows 平台提供了性能关键的原生实现。本项目通过以下方式自动化构建过程：

1. **GitHub Actions** - 手动触发或代码更改时的自动化云端构建
2. **本地构建脚本** - 用于本地编译的 PowerShell 和批处理脚本

### 构建内容

- `winutils.exe` - Hadoop 的 Windows 实用工具
- `hadoop.dll` - Hadoop 核心原生库
- `hdfs.dll` - HDFS 原生库
- 其他原生组件（压缩编解码器等）

## 前置要求

### GitHub Actions 构建（自动化）

无需本地配置！GitHub Actions 在云端运行构建。

### 本地构建

#### 必需软件

1. **Visual Studio 2019 或更高版本**
   - 安装 "使用 C++ 的桌面开发" 工作负载
   - 下载地址：https://visualstudio.microsoft.com/downloads/

2. **Java Development Kit (JDK) 8**
   - 下载地址：https://adoptium.net/temurin/releases/?version=8
   - 设置 `JAVA_HOME` 环境变量

3. **Apache Maven 3.6+**
   - 下载地址：https://maven.apache.org/download.cgi
   - 添加到 PATH

4. **CMake 3.19+**
   - 下载地址：https://cmake.org/download/
   - 或通过 chocolatey 安装：`choco install cmake`

5. **Protocol Buffers**
   - 通过 chocolatey 安装：`choco install protoc`

6. **开发库**
   - zlib：`choco install zlib`
   - OpenSSL：`choco install openssl`

#### 使用 Chocolatey 快速安装

```powershell
# 如果尚未安装 Chocolatey，先安装它
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 安装依赖项
choco install -y cmake protoc zlib openssl
```

## 使用 GitHub Actions 构建

### 触发构建

1. 在 GitHub 上进入你的仓库
2. 点击 "Actions" 标签页
3. 选择 "Build Hadoop Windows Native Libraries" 工作流
4. 点击 "Run workflow"
5. 输入 Hadoop 版本（例如 `3.3.4`、`3.4.2`）
6. 选择架构：`x64`、`x86` 或 `both`
7. 点击 "Run workflow"

**架构选项：**
- **x64**：仅构建 64 位版本（适用于 64 位 Java JVM）
- **x86**：仅构建 32 位版本（适用于 32 位 Java JVM）
- **both**：同时构建 x64 和 x86 两个版本

### 执行流程

GitHub Action 将会：

1. 设置 Windows 构建环境
2. 安装所有必需的依赖项
3. 下载 Hadoop 源代码
4. 编译原生库
5. 打包构建产物
6. 创建包含二进制文件的 GitHub Release

### 下载构建产物

工作流完成后：

- **Artifacts（工件）**：在工作流运行中保留 90 天
- **Releases（发布）**：永久性发布，标签为 `hadoop-{version}-windows-{arch}`

## 本地构建

### 使用 PowerShell 脚本（推荐）

```powershell
# 进入仓库目录
cd Hadoop-NativeLibraries

# 构建 x64 版本（默认）
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.3.4"

# 构建 x86 版本
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.3.4" -Architecture "x86"

# 同时构建 x64 和 x86 版本
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.3.4" -Architecture "both"

# 使用自定义构建目录
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.3.4" -BuildDir "C:\builds\hadoop"

# 清理构建（删除现有构建目录）
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.3.4" -CleanBuild

# 跳过下载（如果源代码已存在）
.\scripts\build-hadoop-native.ps1 -HadoopVersion "3.3.4" -SkipDownload
```

**脚本参数：**
- `-HadoopVersion`：要构建的版本（例如 "3.3.4"）
- `-Architecture`：目标架构 - `x64`（默认）、`x86` 或 `both`
- `-BuildDir`：自定义构建目录（默认：`.\build`）
- `-CleanBuild`：构建前删除现有构建目录
- `-SkipDownload`：跳过下载源代码（如果已存在）
- `-SkipBuild`：跳过构建阶段（用于测试）

### 使用批处理脚本

```cmd
cd Hadoop-NativeLibraries
scripts\build-hadoop-native.bat
```

### 手动构建步骤

如果你更喜欢手动构建：

```cmd
# 1. 下载 Hadoop 源代码
curl -L -O https://archive.apache.org/dist/hadoop/common/hadoop-3.3.4/hadoop-3.3.4-src.tar.gz
tar -xzf hadoop-3.3.4-src.tar.gz
cd hadoop-3.3.4-src

# 2. 设置 Visual Studio 环境
# 对于 x64：
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
# 对于 x86：
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars32.bat"

# 3. 使用 Maven 构建
mvn package -Pdist,native-win -DskipTests -Dtar -Dmaven.javadoc.skip=true

# 4. 在以下位置查找输出：
# hadoop-dist\target\hadoop-3.3.4\bin\
# hadoop-dist\target\hadoop-3.3.4\lib\native\
```

### 构建时间

根据你的系统性能，预计构建需要 **15-30 分钟**。

## 输出文件

成功构建后，你会得到：

```
hadoop-{version}-windows-{arch}/
├── bin/
│   ├── winutils.exe
│   ├── hadoop.dll
│   ├── hdfs.dll
│   └── 其他 DLL 和可执行文件
├── lib/
│   └── 原生库文件
└── BUILD_INFO.txt
```

其中 `{arch}` 为 `x64` 或 `x86`。

### 文件说明

| 文件 | 描述 |
|------|------|
| `winutils.exe` | Windows 文件操作、权限等实用工具 |
| `hadoop.dll` | Hadoop 核心原生库（压缩、CRC32 等） |
| `hdfs.dll` | HDFS 原生操作 |
| `BUILD_INFO.txt` | 构建元数据和版本信息 |

## 使用方法

### 安装构建的库

1. 将 `hadoop-{version}-windows-{arch}` 目录复制到本地磁盘
2. 设置环境变量：

```cmd
set HADOOP_HOME=C:\path\to\hadoop-{version}-windows-{arch}
set PATH=%PATH%;%HADOOP_HOME%\bin
```

或在 PowerShell 中：

```powershell
$env:HADOOP_HOME="C:\path\to\hadoop-{version}-windows-{arch}"
$env:PATH="$env:PATH;$env:HADOOP_HOME\bin"
```

### 永久设置环境变量

**Windows 10/11：**

1. 在开始菜单中搜索"环境变量"
2. 点击"编辑系统环境变量"
3. 点击"环境变量"按钮
4. 在"系统变量"下添加 `HADOOP_HOME`
5. 编辑 `Path` 并添加 `%HADOOP_HOME%\bin`

### 验证安装

```cmd
# 检查 winutils 是否可访问
where winutils

# 检查 Hadoop 原生库（需要已安装 Hadoop）
hadoop checknative -a
```

预期输出：
```
Native library checking:
hadoop: true C:\path\to\hadoop.dll
zlib:   true
...
```

## 故障排除

### 构建失败提示 "Maven not found"

**解决方案：** 安装 Maven 并添加到 PATH
```powershell
choco install maven
```

### 构建失败提示 "CMake not found"

**解决方案：** 安装 CMake
```powershell
choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System'
```

### 构建失败提示 "Cannot find vcvars64.bat" 或 "Cannot find vcvars32.bat"

**解决方案：** 安装带 C++ 工具的 Visual Studio
- 打开 Visual Studio Installer
- 修改安装
- 勾选 "使用 C++ 的桌面开发"

### 构建失败出现 Protocol Buffer 错误

**解决方案：** 安装 Protocol Buffers
```powershell
choco install protoc
```

### 运行时错误 "Unable to load native-hadoop library"

**解决方案：**

1. 验证 `HADOOP_HOME` 设置正确
2. 确保 `%HADOOP_HOME%\bin` 在 PATH 中
3. **检查 DLL 架构是否与 JVM 架构匹配：**
   - 64 位 Java：使用 `hadoop-{version}-windows-x64`
   - 32 位 Java：使用 `hadoop-{version}-windows-x86`
   - 使用 `java -version` 验证 Java 架构（查找 "64-Bit" 或 "32-Bit"）
4. 验证 `bin` 目录中存在所有 DLL

### 架构不匹配错误

如果看到类似 "Can't load IA 32-bit .dll on a AMD 64-bit platform" 的错误：

**问题：** 原生库架构与 Java JVM 架构不匹配。

**解决方案：**
```cmd
# 检查你的 Java 版本
java -version

# 查找：
# - "64-Bit Server VM" = 你需要 x64 原生库
# - 没有 "64-Bit" 字样 = 你需要 x86 原生库

# 下载/构建匹配的架构
```

### GitHub Actions 构建失败

**常见原因：**

1. 指定的 Hadoop 版本无效
2. Hadoop 版本在 Apache 归档中不可用
3. 临时下载问题

**解决方案：** 检查 Actions 日志以查看具体错误并重新运行工作流。

## 支持的 Hadoop 版本

本构建系统支持：

- Hadoop 3.3.x 系列（已测试：3.3.4、3.3.5、3.3.6）
- Hadoop 3.4.x 系列（已测试：3.4.0、3.4.1、3.4.2）

对于其他版本，可以尝试构建 - 大多数 3.x 版本应该都能工作。

## 支持的架构

- **x64（64位）**：适用于 64 位 Windows 系统和 64 位 Java JVM
- **x86（32位）**：适用于 32 位 Windows 系统和 32 位 Java JVM
- **不支持 ARM**：由于 Hadoop 官方限制，暂不支持 Windows ARM 平台

### 如何确定需要哪个架构？

```cmd
# 检查 Java 版本
java -version

# 示例输出分析：
# "64-Bit Server VM" 或 "amd64" → 使用 x64
# "Client VM" 且没有 "64-Bit" → 使用 x86
```

## 高级用法

### 同时构建多个版本

```powershell
# 构建多个 Hadoop 版本
$versions = @("3.3.4", "3.3.5", "3.4.0")
foreach ($ver in $versions) {
    .\scripts\build-hadoop-native.ps1 -HadoopVersion $ver -Architecture "both"
}
```

### 验证 DLL 架构

如果你已安装 Visual Studio，可以使用 `dumpbin` 验证 DLL 架构：

```cmd
# 在 Visual Studio Developer Command Prompt 中
dumpbin /headers hadoop.dll | findstr "machine"

# 输出示例：
# x64: "machine (x64)"
# x86: "machine (x86)"
```

或使用 PowerShell：

```powershell
# 查找 dumpbin.exe
$dumpbin = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe"
& (Get-Item $dumpbin | Select-Object -First 1).FullName /headers hadoop.dll | Select-String "machine"
```

## 参考资料

- [Hadoop 原生库官方指南](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/NativeLibraries.html)
- [Hadoop 发行版下载](https://hadoop.apache.org/releases.html)
- [构建说明（中文）](https://www.jianshu.com/p/1b4cbabfd899)
- [Hadoop 源码构建](https://cwiki.apache.org/confluence/display/HADOOP/HowToContribute)

## 许可证

本构建系统按原样提供。Hadoop 本身采用 Apache License 2.0 许可。

## 贡献

欢迎贡献！请：

1. 使用不同的 Hadoop 版本进行测试
2. 报告问题时提供具体的错误消息
3. 提交改进构建脚本的 PR

---

**需要帮助？** 在 GitHub 上提交 issue，并包含：
- Hadoop 版本
- 构建环境详细信息（Windows 版本、Visual Studio 版本）
- 完整的错误消息和日志
