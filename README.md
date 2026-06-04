# 🏥 CareMateFamily - HarmonyOS 互联网医疗家属端应用

<div align="center">

**一款基于 HarmonyOS NEXT 的互联网医疗家属端应用，展示完整的医疗行业垂直应用开发实践**

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT-FF0000?style=flat-square)
![ArkTS](https://img.shields.io/badge/Language-ArkTS-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

[功能概览](#-功能模块) • [技术栈](#-技术栈) • [项目亮点](#-项目亮点) • [快速开始](#-快速开始)

</div>

---

## 📋 项目概述

**CareMateFamily** 是一款面向家属的互联网医院移动应用，帮助家属管理康养用户、查看健康数据、预约医疗服务。
该项目完整展示了如何使用 **ArkTS + ArkUI** 构建多页面、多模块的医疗行业应用，具备完善的本地数据持久化、用户隔离和业务流程实现。

### 核心特性
- ✅ **完整的用户认证系统**：注册、登录、验证码验证，用户名唯一性校验
- ✅ **多用户数据隔离**：基于 KvStore 的用户隔离设计，确保数据安全
- ✅ **丰富的业务功能**：5 大核心模块，12+ 个业务场景
- ✅ **专业的 UI/UX**：自定义组件、下拉刷新、懒加载、平滑动画
- ✅ **实战级代码质量**：模块化架构、规范的代码组织、最佳实践

---

## 🎯 功能模块

### 1️⃣ 用户认证模块
| 功能 | 说明 |
|------|------|
| **注册** | 用户名、手机号、密码、图形验证码 |
| **登录** | 用户名 + 密码 + 验证码验证 |
| **验证码** | 自定义 Canvas 绘制的图形验证码 |
| **账户隔离** | 基于 KvStore 的多用户数据隔离 |

**相关页面**: `LoginPage.ets`, `RegisterPage.ets`

---

### 2️⃣ 健康管理模块
展示康养用户的实时健康数据与历史记录

**核心功能**:
- 📊 **7 大健康指标卡片**：心率、血氧、体温、血糖、血压、压力、睡眠
- 👥 **用户切换**：下拉选择器快速切换康养用户，查看不同用户数据
- 📈 **曲线展示**：使用 Canvas 绘制实时曲线图表
- 📝 **数据录入**：浮动按钮进入表单页面，添加新的健康记录
- 💾 **智能存储**：融合静态示例数据与 KvStore 用户数据

**相关页面**: `HealthTab.ets`, `HealthDetailPage.ets`, `HealthRecordFormPage.ets`

**数据流**:
```
HealthTab (指标卡片)
    ↓ 点击卡片
HealthDetailPage (按指标查看曲线+记录)
    ↓ 点击 + 按钮
HealthRecordFormPage (表单录入)
    ↓ 保存
HealthRecordStoreManager (KvStore 存储)
```

---

### 3️⃣ 健康宣教模块
专业的健康知识库，包含 8+ 篇详细文章

**内容覆盖**:
- 老年痴呆预防与照护
- 帕金森病管理
- 运动与健康
- 骨质疏松预防
- 高血压管理
- 睡眠健康
- 糖尿病饮食
- 更多健康主题

**特性**:
- 🔄 下拉刷新、懒加载分页（每页 2-3 条）
- 📱 响应式卡片布局
- ⬆️ 返回顶部浮动按钮
- 📖 分段内容详情页面

**相关页面**: `ConsultTab.ets`, `HealthEduDetailPage.ets`

---

### 4️⃣ 康养用户档案模块
完整的用户信息管理系统

**功能清单**:
- ➕ **添加用户**：完整的表单，支持9个信息字段
- 👤 **用户列表**：卡片式展示，性别、关系、生日、身份证等信息
- 📄 **详情编辑**：查看和修改用户信息
- 🗑️ **删除功能**：支持单条删除或全部清空
- 🔐 **数据隔离**：按登录用户名隔离，确保每个用户只能看到自己添加的档案

**表单字段**: 姓名、性别、关系、生日、身份证、职业、地址

**相关页面**: `ArchiveTab.ets`, `AddCareUserPage.ets`, `CareUserDetailPage.ets`

**存储方案**:
```
KvStore Key: care_users_{userName}_{userId}
确保多用户数据完全隔离
```

---

### 5️⃣ 医疗服务模块
完整的服务预约与订单管理流程

**子模块划分**:

#### 📦 服务采购
- 展示可预约的医疗服务列表
- 服务卡片显示：图片、名称、机构、类型、价格
- 详情页展示：服务介绍、预约须知、详细费用明细

#### 🎯 预约下单
- 表单化预约流程
- 支持用户信息保存
- 提交后自动存储到 KvStore

#### 📋 订单查询
- 展示当前用户的全部预约订单
- 订单详情查看
- 订单状态展示

**相关页面**:
- `ServicePurchasePage.ets` - 服务列表
- `ServiceItemDetailPage.ets` - 服务详情
- `ServiceReservationPage.ets` - 预约表单
- `ServiceOrdersPage.ets` - 订单列表
- `ServiceOrderDetailPage.ets` - 订单详情

**数据来源**: `rawfile/service_catalog.json`

---

### 6️⃣ 问诊记录模块
完整的远程问诊与支付流程演示

**业务流程**:
- 📋 **问诊记录列表**：展示历史问诊，显示患者、医生、金额、支付状态
- 📖 **详情查看**：症状、病史、过敏史、医生诊断、处方信息
- 💳 **支付流程**：未支付订单进入支付页面
- ✅ **状态同步**：支付后本地状态更新

**相关页面**:
- `VisitRecordsPage.ets` - 问诊列表
- `VisitRecordDetailPage.ets` - 问诊详情
- `VisitRecordPayPage.ets` - 支付页面

**数据模型**:
```
OrderInfo: 订单基础信息 (患者、医生、时间、金额、支付状态)
PrescriptionDetail: 处方详情 (药物、用量、频次、用法)
MedicineInfo: 药物信息
```

---

### 7️⃣ 入住申请模块
机构入住申请的完整流程

**功能**:
- 📝 **申请表单**：机构、科室、房间、备注等信息
- 📋 **申请记录**：展示已提交的申请及状态
- 🔍 **详情查看**：查看完整的申请信息
- 🗑️ **清空记录**：一键删除所有申请记录

**相关页面**:
- `AdmissionApplyPage.ets` - 申请表单
- `AdmissionRecordsPage.ets` - 申请列表
- `AdmissionRecordDetailPage.ets` - 申请详情

**数据结构**:
```
AdmissionRecord {
  id: string              // 唯一ID（时间戳+随机数）
  type: SINGLE | MULTI    // 申请类型
  submitTime: number      // 提交时间
  status: PENDING | APPROVED | REJECTED
  data: ApplyFormData
}
```

---

### 8️⃣ 个人中心模块
用户信息展示与快捷导航

**功能**:
- 👤 **个人信息展示**：头像、昵称、手机号
- 🔐 **登录状态**：未登录/已登录状态切换
- 🔗 **快捷入口**：一键跳转到问诊记录、服务订单、入住申请、健康记录

**相关页面**: `ProfileTab.ets`

---

## 🏗️ 架构设计

### 页面导航结构
```
EntryAbility (应用入口)
    ↓ 加载
MainTabPage (5 个底部 Tabs)
    ├─ Tab 1: HomeTab (首页)
    │   ├─ Banner
    │   ├─ 4 个功能入口
    │   └─ 宣教列表
    │
    ├─ Tab 2: HealthTab (健康)
    │   ├─ 用户选择器
    │   ├─ 7 个指标卡片
    │   └─ → HealthDetailPage
    │
    ├─ Tab 3: ConsultTab (咨询)
    │   ├─ 宣教列表
    │   └─ → HealthEduDetailPage
    │
    ├─ Tab 4: ArchiveTab (档案)
    │   ├─ 用户列表
    │   ├─ → AddCareUserPage
    │   └─ → CareUserDetailPage
    │
    └─ Tab 5: ProfileTab (我的)
        ├─ 个人信息
        └─ 功能快捷导航
```

### 数据存储架构

| 功能 | Store ID | Key 前缀 | 隔离方式 | Manager |
|------|----------|---------|---------|---------|
| 用户账号 | `app_user_store` | `users` | 全局 | `UserStoreManager` |
| 康养用户 | `care_user_store` | `care_users_{userName}` | 按用户名 | `CareUserStoreManager` |
| 健康记录 | `health_record_store` | `health_records_{userName}` | 按用户名 | `HealthRecordStoreManager` |
| 服务预约 | `reservation_store` | `reservations_{userName}` | 按用户名 | `ReservationStoreManager` |
| 入住申请 | 通用 KvStore | （自定义） | 全局 | `KvStoreManager` |

**设计亮点**:
- 🔐 **用户隔离**: 通过用户名前缀确保数据安全
- 💾 **本地优先**: 所有业务数据都存储在本地 KvStore
- 🔄 **单例模式**: Store Manager 采用单例模式，避免重复初始化

---

## 🛠️ 技术栈

### 核心框架
- **HarmonyOS NEXT** - 操作系统平台
- **ArkTS** - 编程语言（TypeScript 超集）
- **ArkUI** - 声明式 UI 框架

### 关键技术

| 技术点 | 应用场景 |
|--------|---------|
| **Canvas 绘制** | 健康曲线图表、验证码生成 |
| **下拉刷新组件** | 列表页面数据刷新 |
| **懒加载管理器** | 列表分页加载优化 |
| **KvStore 持久化** | 多模块数据本地存储 |
| **路由参数传递** | 页面间数据通信 |
| **AppStorage/PersistentStorage** | 全局状态管理 |
| **自定义组件** | 可复用 UI 组件库 |

### 工具与依赖
- **DevEco Studio** - 官方 IDE
- **HarmonyOS SDK** - 开发工具包
- **MPChart** (可选) - 图表库

---

## 📁 项目结构

```
CareMateFamily/
├── entry/                              # 主应用模块
│   └── src/main/
│       ├── ets/
│       │   ├── entryability/
│       │   │   ├── EntryAbility.ets   # 应用入口
│       │   │   └── EntryBackupAbility.ets # 备份能力
│       │   │
│       │   ├── pages/                  # 业务页面（25+ 个页面）
│       │   │   ├── MainTabPage.ets     # 底部导航框架
│       │   │   ├── HomeTab.ets         # 首页
│       │   │   ├── HealthTab.ets       # 健康首页
│       │   │   ├── HealthDetailPage.ets # 健康详情
│       │   │   ├── HealthRecordFormPage.ets
│       │   │   ├── ConsultTab.ets      # 咨询/宣教
│       │   │   ├── HealthEduDetailPage.ets
│       │   │   ├── ArchiveTab.ets      # 用户档案
│       │   │   ├── AddCareUserPage.ets # 新增用户
│       │   │   ├── CareUserDetailPage.ets
│       │   │   ├── ServicePurchasePage.ets # 服务采购
│       │   │   ├── ServiceItemDetailPage.ets
│       │   │   ├── ServiceReservationPage.ets
│       │   │   ├── ServiceOrdersPage.ets
│       │   │   ├── ServiceOrderDetailPage.ets
│       │   │   ├── AdmissionApplyPage.ets # 入住申请
│       │   │   ├── AdmissionRecordsPage.ets
│       │   │   ├── AdmissionRecordDetailPage.ets
│       │   │   ├── VisitRecordsPage.ets # 问诊记录
│       │   │   ├── VisitRecordDetailPage.ets
│       │   │   ├── VisitRecordPayPage.ets
│       │   │   ├── ProfileTab.ets      # 我的
│       │   │   ├── LoginPage.ets       # 登录
│       │   │   └── RegisterPage.ets    # 注册
│       │   │
│       │   ├── components/             # 可复用组件
│       │   │   ├── PullToRefresh.ets   # 下拉刷新
│       │   │   └── CaptchaCanvas.ets   # 验证码画布
│       │   │
│       │   ├── model/                  # 数据模型与静态数据
│       │   │   ├── HealthData.ets      # 健康数据模型
│       │   │   ├── HealthEduCatalog.ets # 宣教文章数据
│       │   │   ├── ServiceCatalog.ets  # 服务目录（从 rawfile 加载）
│       │   │   ├── AdmissionRecord.ets # 入住申请模型
│       │   │   ├── VisitRecordStore.ets # 问诊记录数据
│       │   │   └── CareUserRecord.ets  # 用户档案模型
│       │   │
│       │   └── utils/                  # 工具类
│       │       ├── UserStoreManager.ets # 用户账号管理
│       │       ├── CareUserStoreManager.ets # 档案管理
│       │       ├── HealthRecordStoreManager.ets # 健康记录管理
│       │       ├── ReservationStoreManager.ets # 预约管理
│       │       ├── KvStoreManager.ets  # 入住申请管理
│       │       └── LazyLoadManager.ets # 懒加载管理
│       │
│       └── resources/                  # 资源文件
│           ├── base/
│           │   ├── element/string.json # 字符串常量
│           │   ├── media/              # 图片资源
│           │   ├── color.json          # 颜色定义
│           │   └── float.json          # 尺寸定义
│           ├── dark/                   # 深色模式资源
│           └── rawfile/
│               └── service_catalog.json # 服务项目数据（JSON）
│
├── AppScope/
│   ├── app.json5
│   └── resources/
│
├── hvigorfile.ts
├── oh-package.json5
├── oh-package-lock.json5
└── README.md
```

---

## 🎨 UI 设计

### 设计语言
- **主色调**: 绿色 `0xFF2ECFA8` (医疗、健康主题)
- **辅助色**: 灰色 `0xFF999999`, 红色 `0xFFFF3B30`
- **背景**: 绿色渐变（顶部深绿 → 底部白色）

### 自定义组件
- `PullToRefresh` - 下拉刷新容器
- `CaptchaCanvas` - 图形验证码
- `HealthSmallCard` - 健康指标卡片
- `HealthTrendCard` - 健康趋势图表
- `HealthEduCard` - 宣教卡片
- `ServiceItemCard` - 服务卡片
- `OrderCard` - 订单卡片
- `UserCard` - 用户档案卡片

### 交互特性
- ✨ 下拉刷新动画
- 📜 列表懒加载
- ⬆️ 返回顶部浮动按钮
- 🎯 表单验证反馈
- 📱 响应式布局

---

## ⭐ 项目亮点

### 1. 完整的业务闭环
从登录认证 → 用户管理 → 数据查看 → 服务预约 → 支付处理，涵盖医疗应用的完整流程

### 2. 专业的数据隔离
基于 KvStore 的按用户名隔离设计，确保多用户数据安全，无服务端依赖

### 3. 丰富的 UI/UX 交互
- 自定义下拉刷新
- 列表懒加载优化
- Canvas 绘制图表
- 浮动按钮交互

### 4. 规范的代码架构
- 模块化设计（页面、组件、模型、工具分离）
- 单例模式管理 KvStore
- 统一的错误处理和提示机制
- 完整的类型定义和接口

### 5. 实战级学习价值
- 展示 ArkTS 的最佳实践
- 完整的大型应用架构参考
- 医疗行业垂直应用示例
- 适合毕业设计、课程项目、技术积累

---

## 🚀 快速开始

### 前置要求
- HarmonyOS NEXT 真机或模拟器（API 12+）
- DevEco Studio 5.0+
- HarmonyOS SDK 已配置

### 克隆项目
```bash
git clone https://github.com/Suzuran737/CareMateFamily.git
cd CareMateFamily
```

### 打开项目
1. 启动 DevEco Studio
2. 选择 **File > Open**，选择项目根目录
3. 等待 Gradle 同步完成

### 运行应用
1. 连接 HarmonyOS 设备或启动模拟器
2. 在 **Run** 菜单中选择 **Run 'entry'**
3. 或按快捷键 `Shift + F10`

### 首次登录
- **注册新账户**: 点击注册按钮，填写用户名、手机号、密码
- **测试登录**: 使用注册的账户登录
- **体验功能**: 添加康养用户 → 查看健康数据 → 预约服务

---

## 📖 学习指南

### 初学者路线
1. 阅读 `EntryAbility` 理解应用入口
2. 查看 `MainTabPage` 学习 Tabs 导航框架
3. 研究 `LoginPage` 和 `RegisterPage` 学习表单验证
4. 学习 `HomeTab` 了解列表刷新和分页

### 进阶学习
1. 深入 `UserStoreManager` 系列，学习 KvStore 使用
2. 研究 `HealthDetailPage` 的 Canvas 绘制逻辑
3. 分析 `ServiceCatalog` 的 rawfile 文件加载机制
4. 学习 `LazyLoadManager` 的懒加载实现

### 项目扩展建议
- [ ] 添加网络请求，连接真实后端服务
- [ ] 集成支付 SDK，实现真实支付流程
- [ ] 添加推送通知，提醒用户重要事件
- [ ] 优化性能，引入更多图表库
- [ ] 适配不同屏幕尺寸和折叠屏

---

## 📝 主要文件说明

### 核心模块

| 文件 | 功能说明 |
|------|---------|
| `EntryAbility.ets` | 应用生命周期管理 |
| `MainTabPage.ets` | 5 Tab 导航框架 |
| `UserStoreManager.ets` | 用户账号持久化 |
| `CareUserStoreManager.ets` | 康养用户数据隔离 |
| `HealthRecordStoreManager.ets` | 健康记录存储 |
| `ReservationStoreManager.ets` | 服务预约管理 |
| `LazyLoadManager.ets` | 列表分页懒加载 |
| `HealthEduCatalog.ets` | 宣教文章数据（8 篇） |
| `ServiceCatalog.ets` | 服务项目数据（从 rawfile 加载） |
| `VisitRecordStore.ets` | 问诊记录示例数据 |

---

## 🔗 相关资源

- [HarmonyOS 官方文档](https://developer.harmonyos.com/)
- [ArkTS 语言指南](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-0000001000033729)
- [ArkUI 组件库](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkui-overview-0000001000033728)
- [KvStore 使用指南](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/kvstore-overview-0000001000033730)

---

## 📄 许可协议

本项目采用 **MIT License** 开源许可，详见 [LICENSE](LICENSE) 文件。

---

## 👤 作者

**CareMateFamily** - 移动互联网编程课程项目

如有问题或建议，欢迎提交 Issue 或 Pull Request！

---

<div align="center">

**⭐ 如果这个项目对您有帮助，请给个 Star 支持一下！**

</div>
