# CareMateFamily

面向 互联网医院家属端 的移动应用，帮助家属在线管理康养用户信息、查看问诊与服务订单、申请入住康养机构、采购看护服务，并浏览健康宣教内容。

## 1. 项目简介

CareMateFamily 是一款运行在 HarmonyOS NEXT 上的家属端应用。本项目以课程作业为背景，目标是：

- 在真实业务场景下练习 HarmonyOS NEXT / ArkTS 开发；
- 实现与"家属端 APP 软件操作手册"中主要功能基本一致的 Demo；
- 通过真机 / 模拟器运行，完整体验从设计到实现的开发流程。

## 2. 功能概述

应用整体围绕"康养用户 + 家属服务"展开，主要模块包括：

### 2.1 账号与登录

#### 用户注册

- 在登录页点击"用户注册"进入注册页面；
- 输入：用户名、手机号码、密码、确认密码、验证码；
- 校验规则示例：
  - 手机号为 11 位；
  - 密码至少 8 位，包含数字和大小写字母；
  - 验证码 4 位数字、5 分钟内有效、每日最多获取 10 次。

#### 用户登录

- 使用手机号 + 密码 + 验证码登录；
- 登录成功后进入首页。

### 2.2 首页与核心业务

#### 首页

- 顶部 Banner 宣传图；
- 主要功能入口（图标 + 文本）：
  - 问诊记录
  - 服务订单
  - 服务采购
  - 入住申请
- 下方展示"健康宣教"列表条目，可点击查看详情。

#### 问诊记录

- 展示通过中控屏智慧康养 APP 与医生视频问诊后生成的问诊订单列表；
- 可查看问诊订单详情、处方信息、用药信息；
- 填写收件信息（联系人、电话、地址）并完成支付，等待发药。

#### 服务订单

- 展示看护服务订单列表；
- 在订单详情中查看：
  - 服务介绍
  - 看护信息
  - 服务记录
  - 看护评估。

#### 服务采购

- 展示可预约的服务项目列表；
- 查看服务项目详情；
- 填写预约信息（康养用户、看护名称、预约时间、联系人、电话、地址、备注）提交预约；
- 预约成功后等待护工接单并上门服务。

#### 入住申请

- 展示入住申请记录列表；
- 提交新的入住申请：
  - 选择康养用户、机构名称、部门名称，填写备注说明；
  - 等待机构审核与安排入住。

### 2.3 健康与档案

#### 健康宣教 / 咨询

- 展示健康宣教内容列表（如：老年痴呆、帕金森病、运动健康等）；
- 支持点击进入详情页面浏览具体内容。

#### 健康模块（健康 Tab）

- 切换不同康养用户；
- 查看对应用户的健康信息与相关数据（具体内容可根据作业要求取舍）。

#### 用户档案

- 管理康养用户列表；
- 新增/编辑康养用户信息：
  - 用户姓名、与家属关系、性别、出生日期、身份证号、地址、职业等。

#### 我的

- 展示当前登录家属用户的基本信息；
- 提供常用入口：问诊记录、服务订单、入住申请等；
- 支持退出登录，返回登录页进行账号切换。

## 3. 运行环境与开发工具

- 操作系统：HarmonyOS NEXT
- 运行环境：鸿蒙真机 或 HarmonyOS NEXT 模拟器
- 开发工具：DevEco Studio
- 开发语言：ArkTS（基于 ArkUI 的声明式 UI 框架）

## 4. 快速开始

以下步骤假设你已经安装好了 DevEco Studio，并配置好 HarmonyOS NEXT 开发环境。

### 4.1 克隆项目

SSH 示例：

```
git clone git@github.com:你的用户名/CareMateFamily.git
cd CareMateFamily
```

如需使用 HTTPS：

```
git clone https://github.com/你的用户名/CareMateFamily.git
cd CareMateFamily
```

### 4.2 使用 DevEco Studio 导入

1. 打开 DevEco Studio。
2. 选择「Open Project」。
3. 选中本仓库所在目录（例如 CareMateFamily）。
4. 等待 Gradle/依赖索引与 ArkTS 工程同步完成。

### 4.3 配置运行设备

在 DevEco Studio 右上角选择运行目标设备：

- 已连接的 HarmonyOS NEXT 真机，或
- 启动一个 HarmonyOS NEXT 模拟器。

确认设备在线状态正常。

### 4.4 编译与运行

1. 在运行目标选择 entry 模块；
2. 点击运行按钮，进行编译与部署；
3. 编译成功后，应用会自动安装并在真机 / 模拟器中启动。

如遇编译错误，请在 DevEco Studio 的 Build / Problems 面板中查看报错信息并逐项修复。

## 5. 项目结构

```
CareMateFamily/
 entry/
   src/main/ets/
     entryability/             # EntryAbility 入口
     components/
       AppPageScaffold.ets    # 全局背景框架
     pages/
        MainTabPage.ets        # 底部 Tabs（首页/健康/咨询/用户档案/我的）
        HomeTab.ets            # 首页内容，使用 pageScaffoldBg
        HealthTab.ets          # "健康"模块
        ConsultTab.ets         # "咨询"模块
        ArchiveTab.ets         # "用户档案"模块
        ProfileTab.ets         # "我的"模块
        VisitRecordsPage.ets   # 问诊记录模块
        ServiceOrdersPage.ets  # 服务订单模块
        ServicePurchasePage.ets# 服务采购模块
        AdmissionApplyPage.ets # 入住申请模块
   src/main/resources/
      base/profile/main_pages.json  # 页面打包清单
      base/media/                   # 图片资源
 ...
```

## 6. 主要技术点

### ArkTS + ArkUI 声明式开发

- 使用 @Entry、@Component 定义页面与组件；
- 使用 Column、Row、Tabs 等组件构建布局；
- 使用 @State、@Prop、@Builder 管理状态与 UI 片段。

### 页面导航

- 当前版本采用 @ohos.router.pushUrl / router.back 进行页面跳转与返回；
- 后续可根据需要迁移至 Navigation + NavPathStack 方案。

### 统一页面背景

- 自定义 AppPageScaffold 组件，实现顶部绿色渐变、底部白色的统一背景；
- 所有业务页面在 Scaffold 内渲染内容，保证整体视觉风格统一。

### 底部 Tab 导航

- 使用 Tabs 实现底部五个标签页（首页 / 健康 / 咨询 / 用户档案 / 我的）；
- tab 图标与文字支持根据选中状态动态变色（未选中灰色、选中绿色）。

## 7. 许可协议
- MIT License


