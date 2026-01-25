# CareMateFamily

移动互联网编程课程项目，面向互联网医院家属端的 HarmonyOS NEXT 移动应用，围绕“康养用户管理 + 服务/问诊/健康数据查看”构建主要业务流程。

## 1. 项目简介

CareMateFamily 是一款运行在 HarmonyOS NEXT 上的家属端应用，目标是：

- 使用 ArkTS + ArkUI 完成多页面业务 Demo；
- 覆盖家属端常见场景（康养用户、服务订单、问诊记录、入住申请、健康管理等）；
- 支持本地 KvStore 数据持久化，便于演示多用户数据隔离。

## 2. 功能概览

### 2.1 账号与登录

- 注册：用户名、手机号、密码、验证码；
- 登录：用户名 + 密码 + 验证码；
- 用户名唯一校验，登录后保存当前用户信息。

### 2.2 首页 / 咨询

- 首页展示 Banner、核心入口（问诊记录/服务订单/服务采购/入住申请）；
- 健康宣教列表支持下拉刷新与懒加载；
- 首页/咨询页提供“回到顶部”浮动按钮；
- 详情页可阅读宣教文章分段内容。

### 2.3 健康模块

- 健康卡片：心率曲线、血氧/压力树状图、体温/血糖/血压图片展示等；
- 支持切换康养用户查看健康信息；
- 健康详情页支持按指标查看曲线与记录；
- 右下角“+”按钮进入表单页录入健康数据（保存到 KvStore）。

### 2.4 用户档案

- 康养用户列表、添加表单、详情页；
- 数据按当前登录用户隔离；
- 支持清空档案数据。

### 2.5 服务采购 / 预约 / 订单

- 服务详情页展示对应项目内容；
- 预约下单填写表单后写入 KvStore；
- 服务订单页读取并渲染当前用户的预约记录（保留少量静态示例）。

### 2.6 入住申请

- 入住申请列表与详情；
- 申请表单提交后写入 KvStore；
- 支持清空已提交记录。

### 2.7 问诊记录

- 问诊记录列表 → 详情；
- 未支付订单进入支付页，支付后同步状态（演示用本地状态更新）。

## 3. 数据与存储

- KvStore（本地持久化）：
  - 用户账号：`UserStoreManager`
  - 康养用户：`CareUserStoreManager`（按登录用户名作为前缀）
  - 服务预约：`ReservationStoreManager`（按登录用户名作为前缀）
  - 健康记录：`HealthRecordStoreManager`（按登录用户名作为前缀）
  - 入住申请：`KvStoreManager`
- 业务演示数据：
  - 健康宣教内容、问诊记录、部分服务订单为静态示例；
  - 健康基础数据保留一些静态示例，其他用户来自 KvStore。

## 4. 运行环境与开发工具

- HarmonyOS NEXT 真机或模拟器
- DevEco Studio
- ArkTS / ArkUI

## 5. 快速开始

```
git clone https://github.com/yourname/CareMateFamily.git
cd CareMateFamily
```

在 DevEco Studio 中打开项目并选择 `entry` 模块运行即可。

## 6. 目录结构

```
CareMateFamily/
  entry/
    src/main/ets/
      entryability/                 # EntryAbility 入口
      components/                   # 业务组件与公共 UI
      model/                        # 业务数据模型与静态数据
      utils/                        # KvStore 封装、懒加载工具
      pages/
        MainTabPage.ets             # 底部 Tabs
        HomeTab.ets                 # 首页
        ConsultTab.ets              # 咨询/宣教
        HealthTab.ets               # 健康首页
        HealthDetailPage.ets        # 健康详情
        HealthRecordFormPage.ets    # 健康记录表单
        HealthEduDetailPage.ets     # 宣教详情
        ArchiveTab.ets              # 用户档案
        AddCareUserPage.ets         # 新增档案
        CareUserDetailPage.ets      # 档案详情
        ServicePurchasePage.ets     # 服务采购
        ServiceItemDetailPage.ets   # 服务详情
        ServiceReservationPage.ets  # 预约下单
        ServiceOrdersPage.ets       # 服务订单
        ServiceOrderDetailPage.ets  # 服务订单详情
        AdmissionApplyPage.ets      # 入住申请
        AdmissionRecordsPage.ets    # 入住记录
        AdmissionRecordDetailPage.ets # 入住详情
        VisitRecordsPage.ets        # 问诊记录
        VisitRecordDetailPage.ets   # 问诊详情
        VisitRecordPayPage.ets      # 支付页面
        LoginPage.ets               # 登录
        RegisterPage.ets            # 注册
        ProfileTab.ets              # 我的
    src/main/resources/
      rawfile/service_catalog.json  # 服务项目数据
      base/profile/main_pages.json  # 页面注册清单
```

## 7. 关键实现点

- Canvas 绘制健康曲线与柱状图；
- LazyLoadManager 实现懒加载分页；
- KvStore 持久化与按用户前缀隔离；
- 路由参数驱动详情页动态渲染。

## 8. 许可协议

MIT License
