# HaboMalHunter: Habo Linux Malware Analysis System

- [二开自研](./auxiliary)

[![BlackHat](https://cdn.rawgit.com/toolswatch/badges/master/arsenal/2017.svg)](https://www.blackhat.com/asia-17/arsenal.html#habomalhunter-an-automated-malware-analysis-tool-for-linux-elf-files)
[![license](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](https://github.com/Tencent/HaboMalHunter/blob/master/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/Tencent/HaboMalHunter/pulls)
[![Platform](https://img.shields.io/badge/Platform-Linux-brightgreen.svg)](https://github.com/Tencent/HaboMalHunter/wiki)

(中文版本请参看[这里](#readme_cn))

## 2020-12-9 
> 运行采用绝对路径; 另外注意修改默认的 root 文件下执行为我们需要的位置。


## 参与贡献
[腾讯开源激励计划](https://opensource.tencent.com/contribution) 鼓励开发者的参与和贡献，期待你的加入。

# <a name="readme_cn">哈勃分析系统(HaboMalHunter)</a>

## 功能描述

HaboMalHunter是[哈勃分析系统 (https://habo.qq.com) ](https://habo.qq.com)的开源子项目，用于Linux平台下进行自动化分析、文件安全性检测的开源工具。使用该工具能够帮助安全分析人员简洁高效的获取恶意样本的静态和动态行为特征。分析报告中提供了进程、文件、网络和系统调用等关键信息。

## 功能清单

开源代码支持Linux x86/x64 平台上的ELF文件的自动化静态动态分析功能。

### 静态分析

1. 基础信息：包括文件md5，名称，类型，大小和SSDEEP等信息。
2. 依赖so信息：对于动态链接的文件，输出依赖的so信息。
3. 字符串信息
4. ELF头信息，入口点
5. IP和端口信息
6. ELF段信息，节信息和hash值
7. 源文件名称

### 动态分析

1. 动态运行启动结束信息：耗时等
2. 进程信息：clone系统调用，execve调用，进程创建结束等
3. 文件操作信息：打开，读取，修改，删除等文件IO操作
4. 网络信息：TCP, UDP, HTTP, HTTPS, SSL等信息 
5. 典型恶意行为：自删除，自修改和自锁定等
6. API信息：getpid, system, dup 等libc函数调用
7. syscall 序列信息

## Demo
### 1.环境配置

使用哈勃Linux开源版进行病毒分析，需要首先制作用于运行病毒的虚拟机环境。切勿直接在真实环境下运行和分析病毒。项目默认使用VirtualBox 5.1 运行Ubuntu 14.04 LTS 作为分析环境。

安装相关的软件，获取源代码之后，请在虚拟机内以root身份运行如下命令：

```bash
root# cd ./util/update_image
root# bash update_image.sh
```

### 2.获取源代码

使用git工具获取源代码。

```bash
git clone https://github.com/Tencent/HaboMalHunter.git
```
### 3.编译源代码
 
大部分源代码是python, 有一部分c代码需要进行编译和打包。
首先将代码上传到虚拟机中。
使用root身份，在/root/ 目录下使用命令，如图：

```bash
cp -ra /media/sf_Source/* .
```
![source](https://cloud.githubusercontent.com/assets/717403/21881137/90ea2d7c-d8dd-11e6-8a8d-b0341d66934d.jpg)

运行命令,进行编译和打包，会输出AnalyzeControl_1129.zip 和test_1129.zip 两个文件, 如图:

```bash
bash package.sh
```
![png2](https://cloud.githubusercontent.com/assets/717403/21881200/01f37460-d8de-11e6-852f-3b48fe87b95f.png)

### 4.进行分析

本次使用测试文件 ./test/bin/read.32.elf 进行测试。使用如下命令:
其中第二条命令会将分析结果拷贝到虚拟机外，用于分析人员阅读。

```
python AnalyzeControl.py -v -l ./test/bin/read.32.elf
cp ./log/output.zip /media/sf_Source/
```
![png3](https://cloud.githubusercontent.com/assets/717403/21881257/5b2aaf1c-d8de-11e6-8551-63c1cf8a5ad7.png)

分析结果中，output.static 是静态分析结果，output.dynamic 是动态分析结果，system.log是运行时的日志。同时也可以结合哈勃分析系统 (https://habo.qq.com) 中的结果展示进行样本分析。

![png4](https://cloud.githubusercontent.com/assets/717403/21881288/a131b122-d8de-11e6-8e51-bba6c68de425.png)


## 未来规划

1. [已完成] 希望使用volatility和LiME进行内存分析
2. 希望增加更多的病毒规则(./util/yara/malware)
3. [已完成] 希望将输出的json数据格式转化成为HTML页面进行展示

## 已知故障和错误列表

1. 分析病毒请在虚拟机环境下进行，并在BIOS设置中开启Intel-VT功能，对因运行病毒引起的任何软件安全问题，本项目不承担责任。
2. 推荐使用VirtualBox 5.1以上版本运行虚拟机。
3. 对于无法运行的ELF文件，例如so文件，哈勃分析系统默认会生成动态日志，但是里面只有无法运行的报错信息。


## UPDRADE
- [Docker构建](./Dockerfile)