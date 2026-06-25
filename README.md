# 国风非遗 - 非物质文化遗产展示与交易平台

> HarmonyOS + SpringBoot + MySQL 全栈期末项目

## 项目简介

国风非遗是一个集非遗内容展示、商品交易、小法庭维权于一体的移动应用。用户可以浏览非遗文化内容、购买非遗相关商品，在交易纠纷时通过"小法庭"陪审团机制进行民主裁决。

**前端**：HarmonyOS ArkTS 应用（API 12）  
**后端**：Spring Boot 2.7.18 RESTful API  
**数据库**：MySQL 8.0

## 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| 前端框架 | HarmonyOS ArkTS (Stage 模型) | API 12 / 5.0.0 |
| 开发工具 | DevEco Studio | 6.1.0.830 |
| 后端框架 | Spring Boot | 2.7.18 |
| 持久层 | Spring Data JPA / Hibernate | - |
| 数据库 | MySQL | 8.0 |
| 构建工具 | Maven | 3.x |
| 语言 | Java / ArkTS | 17 / TypeScript |

## 功能模块

### 用户模块
- 手机号注册/登录
- Token 身份认证
- 个人信用分体系
- 角色管理（普通用户 / 管理员）

### 内容模块
- 非遗内容发布（图文/视频）
- 内容列表浏览（最新/最热排序）
- 标签筛选
- 点赞、浏览统计
- 内容审核（管理员通过/驳回）

### 商城模块
- 商品发布（关联非遗内容）
- 商品购买（下单 → 付款 → 发货 → 确认收货）
- 库存管理

### 小法庭维权模块
- 交易纠纷发起
- 协商 / 申请陪审团介入
- 随机抽取陪审员（信用分 ≥ 60）
- 陪审团投票（支持买家/卖家）
- 自动裁决（24 小时内投票超时自动判定）

## 系统架构

```
┌─────────────────────────────────────────┐
│         HarmonyOS App (ArkTS)            │
│  Login → Feed → Detail → Order → Dispute │
│         HttpUtil (Bearer Token)          │
└──────────────────┬──────────────────────┘
                   │ HTTP REST
┌──────────────────▼──────────────────────┐
│       Spring Boot Backend (8080)         │
│  Interceptor → Controller → Service      │
│                    → Repository (JPA)    │
└──────────────────┬──────────────────────┘
                   │ JDBC
┌──────────────────▼──────────────────────┐
│         MySQL 8.0 (nonheritage_db)       │
│  8 tables: user, content, product,       │
│  order_table, dispute, jury_invitation,  │
│  jury_vote, audit_log                    │
└─────────────────────────────────────────┘
```

## 数据库设计

| 表名 | 说明 | 核心字段 |
|------|------|----------|
| `user` | 用户 | id, username, password, phone, role, credit_score, status |
| `content` | 非遗内容 | id, user_id, title, type, media_urls, tags, status, like_count |
| `product` | 商品 | id, content_id, seller_id, name, price, stock, status |
| `order_table` | 订单 | id, buyer_id, seller_id, product_id, amount, status, after_sale_status |
| `dispute` | 纠纷 | id, order_id, initiator_id, reason, status, result, buyer_support_rate |
| `jury_invitation` | 陪审邀请 | id, dispute_id, user_id, status, invite_time |
| `jury_vote` | 陪审投票 | id, dispute_id, voter_id, vote_side |
| `audit_log` | 审核日志 | id, content_id, auditor_id, action, reason |

完整建表语句包含外键约束，见 `init.sql`。

## API 接口一览

### 用户
| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/api/users/register` | 注册 | 否 |
| POST | `/api/users/login` | 登录 | 否 |
| GET | `/api/users/me` | 当前用户信息 | 是 |

### 内容
| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/api/contents` | 内容列表（分页+排序） | 否 |
| GET | `/api/contents/{id}` | 内容详情 | 否 |
| POST | `/api/contents` | 发布内容 | 是 |
| PUT | `/api/contents/{id}/like` | 点赞 | 否 |
| GET | `/api/contents/mine` | 我的发布 | 是 |
| GET | `/api/contents/tag/{tag}` | 标签筛选 | 否 |

### 商品
| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/api/products` | 商品列表 | 否 |
| GET | `/api/products?contentId=` | 按内容查商品 | 否 |

### 订单
| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/api/orders` | 下单 | 是 |
| GET | `/api/orders/{id}` | 订单详情 | 是 |
| PUT | `/api/orders/{id}/pay` | 付款 | 是 |
| PUT | `/api/orders/{id}/ship` | 发货 | 是 |
| PUT | `/api/orders/{id}/confirm` | 确认收货 | 是 |
| GET | `/api/orders/bought` | 买到的 | 是 |
| GET | `/api/orders/sold` | 卖出的 | 是 |

### 纠纷
| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/api/disputes` | 发起纠纷 | 是 |
| GET | `/api/disputes/{id}` | 纠纷详情 | 是 |
| GET | `/api/disputes/mine` | 我的纠纷 | 是 |
| PUT | `/api/disputes/{id}/request-jury` | 申请陪审团 | 是 |
| GET | `/api/disputes/{id}/vote-stats` | 投票统计 | 是 |

### 陪审
| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/api/jury/invitations/mine` | 我的陪审邀请 | 是 |
| POST | `/api/jury/votes` | 投票 | 是 |

### 管理
| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/api/admin/audit/list` | 待审核列表 | 是 |
| PUT | `/api/admin/audit/{id}/pass` | 审核通过 | 是 |
| PUT | `/api/admin/audit/{id}/reject` | 审核驳回 | 是 |

## 快速开始

### 环境要求
- JDK 17+
- Maven 3.6+
- MySQL 8.0+
- DevEco Studio 5.0+ (API 12+)
- Node.js 18+ (用于 ohpm)

### 1. 数据库初始化
```bash
mysql -u root -p < init.sql
```
数据库名：`nonheritage_db`，默认包含 5 个测试用户和模拟数据。

### 2. 后端启动
```bash
cd backend
# 修改 application.yml 中的数据库密码
mvn spring-boot:run
```
服务运行在 `http://localhost:8080`。

> 如需手机/模拟器访问，修改 `application.yml` 中 `server.address` 为 `0.0.0.0`，并确保防火墙放行 8080 端口。

### 3. 前端运行
1. 用 DevEco Studio 打开 `harmony_app_new` 目录
2. 修改 `entry/src/main/ets/common/HttpUtil.ets` 中的 `BASE_URL` 为你的后端 IP
3. 签名配置：File → Project Structure → Signing Configs
4. Build → Run 到模拟器或真机

### 测试账号
| 角色 | 手机号 | 密码 |
|------|--------|------|
| 管理员 | 13800000000 | 123456 |
| 普通用户 | 13800000001 | 123456 |
| 普通用户 | 13800000002 | 123456 |

## 项目结构

```
nonheritage-app/
├── init.sql                          # 数据库初始化脚本
├── admin_audit.html                  # 管理员审核页面（独立）
├── backend/                          # SpringBoot 后端
│   ├── pom.xml
│   └── src/main/
│       ├── resources/application.yml
│       └── java/com/nonheritage/demo/
│           ├── NonHeritageApplication.java
│           ├── config/               # 拦截器、CORS、数据源配置
│           ├── entity/               # JPA 实体（8 张表）
│           ├── dto/                  # 请求/响应 DTO
│           ├── controller/           # REST 控制器（7 个）
│           ├── service/              # 业务逻辑（6 个）
│           ├── repository/           # JPA 仓库（8 个）
│           ├── util/                 # Token 工具
│           ├── exception/            # 全局异常处理
│           └── scheduler/            # 定时任务（纠纷自动裁决）
└── harmony_app_new/                  # HarmonyOS 前端
    ├── build-profile.json5
    ├── AppScope/app.json5
    └── entry/src/main/
        ├── module.json5
        ├── ets/
        │   ├── entryability/         # 应用入口
        │   ├── common/               # HttpUtil、DataModels
        │   └── pages/                # 13 个页面/组件
        └── resources/
            └── base/profile/main_pages.json
```

## 业务流程

### 完整交易 + 维权流程
```
发布内容 → 审核通过 → 用户浏览 → 购买商品
  → 下单 → 付款 → 卖家发货 → 确认收货
  → (如有纠纷) 发起纠纷 → 协商不成就申请陪审团
  → 随机抽取陪审员 → 投票 → 自动裁决
```

### 小法庭裁决规则
- 陪审员资格：信用分 ≥ 60，非纠纷当事人
- 每案随机抽取 10-20 名陪审员
- 24 小时内投票数 > 10 票时自动判定
- 买家支持率 > 66% → 买家胜诉，否则卖家胜诉

## 说明

本项目为 HarmonyOS 应用开发课程期末作业，演示了完整的移动端全栈开发流程，包括用户认证、内容管理、电商交易和众包裁决等核心功能。
