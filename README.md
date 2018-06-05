#### 项目背景
一个基于Jenkins 进行开发的自动构建系统，使用专门的机器负责所有App的构建任务，目的是解决所有与App打包构建以及内测分发相关的问题。经过不断的开发升级，已实现了最大程度的自动化水平，目前在公司内部所有 iOS/Android App 均已接入。系统根据不同项目主要分为两种类型的任务，一种是 iOS/Android 内测分发的构建任务，另一种则是iOS构建好后直接上传到 TestFlight/AppStore 的构建任务。

1、内测分发构建任务流程：选择想要构建的任务 ---> 选择需要构建的分支或tag ---> 点击开始构建 ---> 系统自动拉取项目代码 ---> 自动下载相关依赖项目后进行整体项目的集成  ---> 编译构建打包等 ---> 将生成的ipa/apk包上传到FTP服务器存档 ---> 将生成的ipa/apk包上传到蒲公英平台 ---> 根据构建的结果将生成的ipa/apk包相关基本信息、下载安装地址与途径、构建信息、构建日志、代码变更集等信息以邮件形式发送到不同的相关人员。

2、AppStore上传构建任务流程：选择想要构建的任务 ---> 选择需要构建的分支或tag ---> 点击开始构建 ---> 系统自动拉取项目代码 ---> 自动下载相关依赖项目后进行整体项目的集成  ---> 编译构建打包等 ---> 将生成的ipa/apk包上传到FTP服务器存档 ---> 将生成的ipa/apk包上传TestFlight/AppStore ---> 根据构建的结果将生成的ipa/apk包的构建信息、构建日志、代码变更集等信息以邮件形式发送到不同的相关人员，并提示相关人员去TestFlight下载测试以及到 iTunes Connect 进行提交审核。

#### 通过本文你将学会：
- 1、Mac 环境下 Jenkins 的安装配置。
- 2、iOS 自动构建企业包，AppStore 包，安卓项目的自动化构建。
- 3、Jenkins 开机自启动 / 网络开机自动登录认证。
- 4、使用脚本自动上传 iOS/Android 包到 FTP 服务器备份。
- 5、使用脚本自动上传 iOS/Android 包到蒲公英应用管理平台。
- 6、使用脚本将 AppStore 发布包自动上传到 TestFlight/AppStore。
- 7、Jenkins 邮件提醒。
- 8、Jenkins 部署 MacOS Slave 实现各自动构建平台的统一，构建机器集群。
> *注：本文的操作环境是 Mac Pro / MacOS 10.13.4 中进行。Jenkins 版本是 2.7.2，Xcode 版本是 9.3，Android Studio 版本是 3.0，Java 版本是 1.8.0_151。下文中所用到的所有 Shell 脚本文件我已上传到 Github：[https://github.com/whihail/AutoArchive]*

#### 安装 Jenkins
在 Mac 环境下，我们需要先安装 JDK，然后在 [Jenkins 的官网](https://jenkins.io) 下载最新的 war 包。下载完成后，打开终端，进入到 war 包所在目录，执行以下命令：
```
java -jar jenkins.war --httpPort=8080
```
待 Jenkins 启动后，在浏览器页面输入以下地址:
```
http://localhost:8080
```
这样就打开 Jenkins 管理页面了。

注意：使用 pkg 包的方式安装将会新建一个 Jenkins 操作系统用户，此用户和普通用户在系统资源和权限方面不一致。将会给后续步骤增加很多麻烦，并可能导致后续步骤失败，所以请确认使用本文介绍方式来安装 Jenkins。

#### 安装 Jenkins 相关插件
点击 系统管理 -> 管理插件 -> 可选插件，可搜索以下插件进行安装
- Git 插件 (GIT plugin)
- Git 参数化构建插件（Git Parameter）
- Gradle 插件 (Gradle plugin) - Android 专用
- Xcode 插件 (Xcode integration) - iOS 专用
- Jenkins 输出日志文字颜色插件（AnsiColor）
- 此插件允许对 Job 设置 Timeout 时间 (Build Timeout)
- 在 Build History 里面显示链接二维码 （description setter plugin）
- SSH 插件 (SSH Credentials Plugin)
- SSH Slaves 插件（SSH Slaves）- 配置 Jenkins Slaves 时需要
- 通过文件生成全局变量的插件（Environment Injector Plugin）-  构建布置之间进行传值
- Email 插件（Email Extension）

#### iOS Job 自动构建设置

新建一个 iOS 的项目来开始自动化构建。点击“新建”，输入 item 名称，选择“构建一个自由风格的软件项目”，然后点击“OK”。

<img src="https://github.com/whihail/AutoArchive/blob/master/Images/attach-1.png" width="720"><br/>


填写项目以及关于项目的描述，然后勾选参数化构建过程（此功能由上述 [Git Parameter](https://wiki.jenkins.io/display/JENKINS/Git+Parameter+Plugin) 插件提供），填写相应描述，Parameter Type 选项支持通过 Branch 构建，Tag 构建， 此处选择 Branch or Tag 构建。

<img src="https://github.com/whihail/AutoArchive/blob/master/Images/attach-2.png" width="720"><br/>


在源码管理项中分别 Repositories 的 git url 地址，Gredentials 此处使用的是 Username with password 方式，也可使用 SSH Username with private key 方式，Branch Specifier 填写 Git Parameter 插件填写的 branch 参数名。

构建触发器指的是触发时机，一般在做持续集成时用到，如每次有新代码提交触发构建、定时间隔触发构建等，此处未使用到，固不做说明。

<img src="https://github.com/whihail/AutoArchive/blob/master/Images/attach-3.png" width="720"><br/>

构建环境勾选 Color ANSI Console Output，ANSI color map 选择 xterm，此配置由[AnsiColor](https://wiki.jenkins.io/display/JENKINS/AnsiColor+Plugin) 插件支持，它可以使 Console Output 支持带颜色的文字输出。

构建中增加构建步骤选择 Execute shell，由于我们项目由多团队开发，使用 CocoaPods 进行集成后构建，所以在构建之前需要 update 各团队的最新代码。

继续增加构建步骤选择 Execute shell，通过获取项目的一些相关信息，进行打包、上传 FTP、蒲公英、TestFlight/AppStore 等操作，相关示例代码 [HrtiOSDemo.sh](https://github.com/whihail/AutoArchive/blob/master/HrtiOSDemo.sh)。

<img src="https://github.com/whihail/AutoArchive/blob/master/Images/attach-4.png" width="720">
<img src="https://github.com/whihail/AutoArchive/blob/master/Images/attach-5.png" width="720"><br/>

iOS Job 的配置到此结束，保存配置，就可进行构建了，下图是构建成功后的部分 Console Output。以上用到的相关脚本代码将在接下来的文章中做详细说明。

<img src="https://github.com/whihail/AutoArchive/blob/master/Images/attach-6.png" width="720"><br/>

#### Android Job 自动构建设置

Android Job 的配置在构建之前和 iOS 都是一致的，只是构建部分有所区别，此处我们使用上文提到的 [Gradle plugin](https://wiki.jenkins.io/display/JENKINS/Gradle+Plugin) 插件对项目进行构建，添加构建步骤 Invoke Gradle script，选中 Invoke Gradle，Gradle Version 选择 Default，Tasks 填写你需要构建的 Gradle Task。

继续增加构建步骤选择 Execute shell，通过获取项目的一些相关信息（此处 Android 项目相关信息在 version_config Json 文件中获取，在 Gradle Task 中每次对 version_Config 文件进行更改），将 APK 包上传 FTP、蒲公英 等操作，相关示例代码 [HrtAndroidDemo.sh](https://github.com/whihail/AutoArchive/blob/master/HrtAndroidDemo.sh)。

<img src="https://github.com/whihail/AutoArchive/blob/master/Images/attach-7.png" width="720"><br/>

Android Job 的配置到此结束，保存配置，就可进行构建了，下图是构建成功后的部分 Console Output。以上用到的相关脚本代码将在接下来的文章中做详细说明。

<img src="https://github.com/whihail/AutoArchive/blob/master/Images/attach-8.png" width="720"><br/>

#### 给机器分配固定 IP 地址

我们知道，在公司内网中，每台机器的 IP 都是随机分配，这就造成每次网络连接过后 IP 地址都有可能改变，也就是说当你把当前地址给别人时，也许明天就不能用啦，所以要想将系统能力开放和共享给内部所有人使用，就必须要有唯一不变的登录地址。

向公司运维人员提供 Jenkins 部署的机器网卡信息，让他给你分配固定 IP，配置之后机器的 IP 地址就不会再变化了。如有必要，还可向公司申请分配域名，方便记忆和之后的机器升级维护。

<img src="https://github.com/whihail/AutoArchive/blob/master/Images/attach-10.png" width="600"><br/>

#### Jenkins 开机自启动

Jenkins 服务通过上文方式启动以后，会一直在后台运行，但是有时也会有一些意外情况，比如说断电导致的物理机器关机。这个时候服务停了，所有人就都用不了了，这个时候你又得登录到机器上，手动启动Jenkins，这期间所有人都在等你。当然这个时候你在公司并且闲着还好，动手处理一下问题还是能解决，那如果你很忙、你请假了或你离职了，然后其它人就不会弄，这就会造成不必要的资源浪费。

这个时候开机自启动会显得很有必要，将上述启动 Jenkins 的命令放到一个 Shell 文件中，如公司网络连接需要进行认证，配合使用的还有开机网络自动账号密码认证。

将 [HrtAutoArchiveStartUp.sh](https://github.com/whihail/AutoArchive/blob/master/HrtAutoArchiveStartUp.sh) 和 [autoConnect.sh](https://github.com/whihail/AutoArchive/blob/master/autoConnect.sh) 的默认打开程序设置成终端，点击 +设置+->+用户和组+->+登录项+，添加这两个 Shell 文件到登录项中。重启机器，会自动运行这两个 Shell 文件启动 Jenkins 以及 自动登录验证网络。

<img src="https://github.com/whihail/AutoArchive/blob/master/Images/attach-11.png" width="600"><br/>

#### 项目展示

下图是公司目前接入 Jenkins 自动构建的一些客户端项目。

<img src="https://github.com/whihail/AutoArchive/blob/master/Images/attach-9.png" width="720"><br/>

#### 其它问题

以上是关于此项目的简介，想了解更多详情请查看该项目 [WiKi](https://github.com/whihail/AutoArchive/wiki)。

[客户端Jenkins自动构建指南之应用构建](https://github.com/whihail/AutoArchive/wiki/客户端Jenkins自动构建指南之应用构建)  
[客户端Jenkins自动构建指南之应用上传](https://github.com/whihail/AutoArchive/wiki/客户端Jenkins自动构建指南之应用上传)  
[客户端Jenkins自动构建指南之邮件通知](https://github.com/whihail/AutoArchive/wiki/客户端Jenkins自动构建指南之邮件通知)  
[客户端Jenkins自动构建指南之分布式应用](https://github.com/whihail/AutoArchive/wiki/客户端Jenkins自动构建指南之分布式应用)  
[客户端Jenkins自动构建指南之项目模块化](https://github.com/whihail/AutoArchive/wiki/客户端Jenkins自动构建指南之项目模块化)  
[客户端Jenkins自动构建指南之常见问题解答](https://github.com/whihail/AutoArchive/wiki/客户端Jenkins自动构建指南之常见问题解答)

#### 联系我们
QQ交流群：716728133   
<img src="https://github.com/whihail/AutoArchive/blob/master/Images/jenkins.png" width="240"><br/>

[https://github.com/whihail/AutoArchive]:https://github.com/whihail/AutoArchive
