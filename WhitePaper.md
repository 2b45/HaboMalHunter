＃ HaboMalHunter：针对Linux ELF文件的自动化恶意软件分析工具

> 杨静宇，刘钊，张伟，王旭，刘桂泽

## 摘要

HaboMalHunter是针对Linux ELF文件的自动化恶意软件分析工具，它是由腾讯防病毒实验室独立开发的Habo Analysis System的子项目。它可以从静态信息和动态行为中全面分析样本，在沙箱中触发和捕获样本的行为，并以各种格式输出结果。生成的报告揭示了有关进程，文件I / O，网络和系统调用的重要信息。

最近，HaboMalHunter在MIT许可下开放了其源代码，旨在与研究人员共享和讨论自动分析技术。该项目应用了数字取证技术，例如内核空间系统调用跟踪和内存分析，并且通过轻松添加第三方YARA规则并支持.mdb文件的输出，强调了与主流安全工具进行协作的重要性。基于散列的ClamAV签名。该工具通过生成一个包含系统调用编号序列的.syscall文件，也非常适合人工智能研究恶意软件的分类和检测。

HaboMalHunter还已经在腾讯防病毒实验室的大型集群中进行了部署和验证。HaboMalHunter每天可处理数千个ELF恶意软件样本，其中大部分来自VirusTotal，可帮助安全分析人员有效地提取静态和动态功能。

我们希望介绍有关HaboMalHunter的技术架构和详细实现，并通过几个典型的实际Linux恶意软件示例进行演示。

有关更多信息，请阅读白皮书并访问项目网站：

https://github.com/Tencent/HaboMalHunter
 
＃1.简介

HaboMalHunter是在很少有针对Linux平台设计自动恶意软件分析工具的背景下开发的。它使用虚拟机执行和监视技术通过自动分析过程来分析ELF样本的行为，从而为防病毒研究人员提供了有效的解决方案。

本文介绍了HaboMalHunter的分析流程，阐述了其架构，实现和演示，并概述了与同类项目相比的优势。
 
对Linux恶意软件的研究具有实际意义。尽管Linux恶意软件的数量相对较少，但是Linux是服务器使用最广泛的操作系统。一旦Linux服务器被感染，许多企业及其用户可能会受到影响，从而造成不可估量的直接和间接损失。实际上，近年来，针对企业服务器的恶意软件已经出现在公众视野中。一些恶意活动可以窃取服务器中的敏感数据，一些恶意活动可以使用服务器资源进行DDoS或其他恶意攻击，甚至对特定企业的APT攻击也已发生。结果，对Linux恶意软件的研究比以往任何时候都更加紧迫。

＃2.体系结构和实现

在分析阶段的开始，HaboMalHunter将初始化运行时环境，例如将虚拟机映像还原到其原始状态并将示例文件复制到虚拟机上。然后将进行静态和动态分析。最后，HaboMalHunter将根据要求生成不同格式的结果。

## 2.1。静态分析

静态分析是指在不运行样品的情况下收集其特征的分析过程。HaboMalHunter收集样本的特征，包括文件格式，哈希值，ELF文件特征，YARA [1]结果，字符串信息和其他特征。与数据一样，重要数据是有助于分析恶意软件的功能，例如IP地址和源文件名。

HaboMalHunter强调其与主流安全工具的集成。它包含由安全分析师编写的YARA规则。此外，HaboMalHunter支持.mdb文件的输出，这些文件是ClamAV的基于哈希的签名[2]。

## 2.2。动态分析

### 2.2.1准备

在运行示例之前，HaboMalHunter将启动一些监视程序，例如Tcpdump [3]监视网络通信，而Sysdig [4]监视系统调用（包括进程创建，文件读写操作等）。这些监视工具将在执行期间记录受监视的数据。分析过程结束后，将处理各种监视工具的监视数据和日志。

### 2.2.2执行

设置运行时环境后，HaboMalHunter将使用加载程序加载示例。使用加载程序的原因是监视程序需要获取用于监视任务的样本的进程ID（PID）。加载程序可以首先创建进程并获取其PID，然后在设置监视程序后，HaboMalHunter将向加载程序发送持续执行信号（SIGCONT）以继续执行样本。执行示例时，将根据配置文件设置执行时间限制，以等待更多恶意操作。

### 2.2.3内存分析

执行完成后，HaboMalHunter将首先使用LiME [5]获取内存转储文件。该工具是内核驱动程序，可以将当前物理内存转储到指定的磁盘文件。然后HaboMalHunter使用volatility [6]分析已保存的内存映像并输出过程信息和shell执行记录。由于此类信息是基于内存中的数据结构派生的，因此可以用来抵抗诸如直接内核对象操纵（DKOM）[7]之类的进程隐藏技术。

### 2.2.4日志处理

在此阶段，可以汇总之前获得的监视数据和日志。HaboMalHunter包含多种日志输出格式。HaboMalHunter还设计了一个层次结构来简化提取的信息。例如，自删除操作对应于文件删除操作，而删除的目标是样本本身。

HaboMalHunter还可以根据要求输出不同的结果。关于机器学习，HaboMalHunter可以将系统调用序列输出为数组格式（.syscall文件）；关于恶意软件自动检测，HaboMalHunter可以将日志输出为json格式；HaboMalHunter还可以提供HTML报告以简化报告的内容，以确保可读性。

＃3.示范

Linux.BackDoor.Gates是Linux平台上的一种DDoS恶意软件。它具有悠久的历史，巧妙的隐藏方法和重要的网络攻击行为。主要的恶意功能是它具有后门和DDoS攻击功能，并且可以替换常用的系统文件以隐藏在后台。

Linux.BackDoor.Gates对重要数据进行加密，例如命令和控制（C＆C）地址和端口，这使得仅基于静态功能很难检测到。此时，使用HaboMalHunter可以轻松地在运行时捕获其动作，包括连接的C＆C域名和端口信息。

HaboMalHunter对于Linux.BackDoor.Gates.6产生以下结果。

## 3.1。自动运行
 
该恶意软件将自动运行文件插入目录/etc/init.d/：

```

	执行：-c ln -s /etc/init.d/VsystemsshMdt /etc/rc1.d/S97VsystemsshMdt
	执行：-c ln -s /etc/init.d/VsystemsshMdt /etc/rc5.d/S97VsystemsshMdt
	
```

## 3.2。自我复制

该恶意软件将自身复制到/ usr / bin / bsd-port目录，并将其重命名为knerl（内核的拼写错误），以实现隐藏自身的目的：

```

	执行：-c mkdir -p / usr / bin / bsd-port
	执行：-c cp -f /tmp/bin/****.elf / usr / bin / bsd-port / knerl

```

## 3.3。网络流量

该恶意软件发送请求以查询bei [。] game918 [。] me域，然后在获取IP地址后尝试在端口21351上创建TCP连接：

```

	行为：查询DNS
	详细信息：192.168.0。**-> 8.8.8.8 DNS 76标准查询0x16e9 A bei.game918.me
	
	行为：响应dns
	详细信息：8.8.8.8-> 192.168.0。** DNS 92标准查询响应0x16e9 A **。133.40。**
	
	行为：TCP程序包
	详细信息：192.168.0。** s-> **。133.40。** TCP 76 60159> 21351 [SYN] Seq = 0 Win = 29200 Len = 0 MSS = 1460 SACK_PERM = 1 TSval = 12750 TSecr = 0 WS = 128
	**。133.40。**-> 192.168.0。** TCP 56 21351> 60159 [RST，ACK] Seq = 1 Ack = 1 Win = 0 Len = 0

```


＃4.相关工作

在防病毒领域，当前有一些众所周知的分析系统，可以将其分为专有系统和开源系统。

对于专有系统，Fireeye [8]提供了用于恶意软件分析的专业硬件环境（AX系列）。硬件环境的使用可以使分析更加有效，并减少环境影响因素。另外，VxStream Sandbox [9]提供了模拟用户操作的功能。但是，这两个系统都没有能力分析ELF恶意软件。而且，作为专有系统，它们对新功能的响应不如开源系统。相比之下，开源HaboMalHunter可以与其他安全工具快速集成，例如，分析人员可以根据分析结果提取YARA或ClamAV规则。HaboMalHunter还支持多种环境，这意味着它比使用定制硬件的解决方案更适用。

在开源系统中，Cuckoo Sandbox [10]被广泛用于在线文件分析网站，例如malwr.com。但是，该网站目前不支持ELF文件。相比之下，HaboMalHunter项目已部署到Habo网站（https://habo.qq.com）的后端，用户可以使用该项目上载ELF文件并获取行为和检测结果。此外，还有一个用于在Linux平台上进行自动分析的开源项目，即Limon Sandbox [11]。该系统使用Strace启动示例文件。相比之下，HaboMalHunter使用加载程序技术来确保可以同时通过多个工具监视样品。

＃5.结论

考虑到Linux平台的重要性以及恶意软件造成的损害，用于自动分析Linux ELF文件的工具非常有用。HaboMalHunter可以从其静态和动态功能以及输出动作报告以各种格式全面分析样本。同时，它可以轻松地与现有安全工具集成，并为机器学习提供数据。通过使用它来分析Linux.BackDoor.Gates病毒并将其与其他类似项目进行比较，这表明HaboMalHunter具有很大的灵活性，很强的适应性，并且适合于ELF文件的自动分析。

＃参考

1. YARA：适用于恶意软件研究人员的模式匹配瑞士刀，http：//virustotal.github.io/yara/
2.托马斯·科伊姆。“ Clam AntiVirus用户手册。” （2012）。
3. Jacobson V，Leres C，McCanneS。tcpdump手册页[J]。劳伦斯·伯克利实验室（CA），1989，143。
4. DRAIOS INC。sysdig，2014年。http：//www.sysdig.org/
5. Sylve，J.（2012）。Lime-linux内存提取器。在ShmooCon'12
6.波动性基金会。波动性框架。https://github.com/volatilityfoundation
7. Butler，J.（2004）。Dkom（直接内核对象操纵）。Black Hat Windows安全性。
8. Gandotra，E.，Bansal，D.和Sofat，S.（2014）。恶意软件分析和分类：调查。信息安全学报，2014年。
9.有效载荷安全公司。有效负载安全性。https：//www.hybrid-analysis.com，2016年。
10. Guarnieri，C.，Tanasi，A.，Bremer，J.，＆Schloesser，M.（2012）。杜鹃沙盒。
11. Monnappa，使用Limon沙盒自动进行Linux恶意软件分析。黑帽（Black Hat）2015年。