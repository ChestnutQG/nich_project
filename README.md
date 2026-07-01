# 锤子铺 — 国风非遗手工艺品电商平台

非遗文化传承人与消费者之间的垂直电商应用，内置**小法庭维权系统**，以社区陪审团机制解决交易纠纷。

## 技术栈

| 层级 | 技术 |
|------|------|
| 移动端 | HarmonyOS ArkTS (API 12) |
| 后端 | Spring Boot 3.2 + MyBatis |
| 数据库 | MySQL 8.0 |
| 管理端 | 纯 HTML/CSS/JS（单页，直接调用 API） |

## 功能模块

### 用户端（HarmonyOS App）

- 手机号登录/注册
- 非遗商品浏览、搜索、按分类筛选
- 商品详情（视频、文化故事、工艺步骤、SKU 选择）
- 购物车、下单、订单管理
- 收货地址管理
- 匠人列表与详情、关注匠人
- 商品收藏
- **小法庭维权**：发起纠纷、申请陪审团、投票裁决

### 管理端（Web）

- 纠纷管理：查看所有纠纷、直接裁决（通过/驳回）、查看陪审员列表
- 用户管理：冻结/解冻、调整信用分、修改角色
- 内容审核：商品上架通过/驳回
- 统计面板：纠纷数量、待审核商品数

## 项目结构

```
├── arkts/                          # HarmonyOS 前端
│   └── entry/src/main/ets/
│       ├── pages/                  # 22 个页面组件
│       ├── components/             # 公共组件（NavBar、ProductCard 等）
│       ├── service/                # API 请求层
│       ├── model/                  # 数据模型
│       ├── mock/                   # Mock 数据
│       └── util/                   # 工具（ServerDiscovery 等）
├── java/                           # Spring Boot 后端
│   └── src/main/
│       ├── java/com/chuizhipu/shop/
│       │   ├── controller/         # REST 控制器
│       │   ├── service/            # 业务逻辑
│       │   ├── mapper/             # MyBatis Mapper 接口
│       │   ├── entity/             # 实体类
│       │   ├── vo/                 # 视图对象
│       │   ├── config/             # CORS、静态资源配置
│       │   ├── interceptor/        # 认证拦截器
│       │   ├── scheduler/          # 定时任务（纠纷超时裁决）
│       │   └── util/               # Token 工具
│       └── resources/
│           ├── mapper/             # MyBatis XML 映射
│           ├── static/             # 管理端 HTML
│           ├── init.sql            # 数据库初始化脚本
│           └── application.properties
└── admin.html                      # 管理端入口（同 resources/static/）
```

## 快速开始

### 1. 数据库

在 MySQL 中创建数据库并导入初始化脚本：

```sql
CREATE DATABASE chuizhi_shop DEFAULT CHARACTER SET utf8mb4;
USE chuizhi_shop;
SOURCE java/src/main/resources/init.sql;
```

### 2. 后端

环境要求：JDK 17+、Maven 3.6+

```bash
cd java
# 修改 src/main/resources/application.properties 中的数据库连接信息
mvn spring-boot:run
# 或 Windows: 双击 dev.bat
```

服务启动在 `http://localhost:8080`。

### 3. 前端

1. DevEco Studio 打开 `arkts/` 目录
2. 复制 `entry/src/main/ets/util/LocalConfig.example.ets` 为 `LocalConfig.ets`
3. 修改 `SERVER_IP` 为后端服务器 IP（模拟器用 `10.0.2.2`，真机用局域网 IP）
4. Build → Run

## API 概览

所有接口统一返回 `{code: 0, message: "ok", data: ...}` 格式。

### 用户
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/users/login` | 手机号登录 |
| GET | `/api/users/me` | 当前用户信息 |
| PUT | `/api/users/profile` | 修改个人资料 |

### 商品
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/products` | 商品列表（分页+筛选） |
| GET | `/api/products/{id}` | 商品详情 |
| POST | `/api/products` | 发布商品（传承人） |
| GET | `/api/products/mine` | 当前用户发布的作品 |
| DELETE | `/api/products/{id}` | 删除自己的作品 |

### 订单
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/orders` | 创建订单 |
| GET | `/api/orders` | 我的订单列表 |
| GET | `/api/orders/{id}` | 订单详情 |
| PUT | `/api/orders/{id}/status` | 更新订单状态 |

### 小法庭
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/disputes` | 创建纠纷 |
| GET | `/api/disputes/{id}` | 纠纷详情 |
| GET | `/api/disputes/mine` | 我的纠纷 |
| PUT | `/api/disputes/{id}/request-jury` | 申请陪审团 |
| GET | `/api/disputes/{id}/vote-stats` | 投票统计 |
| POST | `/api/jury/vote` | 投陪审票 |
| GET | `/api/jury/invitations` | 我的陪审邀请 |

### 管理端
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/admin/stats` | 统计面板 |
| GET | `/api/admin/disputes` | 所有纠纷 |
| PUT | `/api/admin/disputes/{id}/resolve` | 管理员裁决 |
| GET | `/api/admin/disputes/{id}/jurors` | 纠纷陪审员列表 |
| GET | `/api/admin/users` | 用户列表 |
| PUT | `/api/admin/users/{id}/freeze` | 冻结/解冻 |
| PUT | `/api/admin/users/{id}/credit` | 调整信用分 |
| PUT | `/api/admin/users/{id}/role` | 修改角色 |
| GET | `/api/admin/products/pending` | 待审核商品 |
| PUT | `/api/admin/products/{id}/audit` | 审核商品 |
| GET | `/api/admin/products` | 全部未删除作品 |
| DELETE | `/api/admin/products/{id}` | 管理员删除作品 |

## 小法庭维权流程

```
买家收货 → 发起维权（协商阶段）
              ↓
        双方协商无果 → 申请陪审团
              ↓
        系统随机选取 15-20 名合格陪审员
              ↓
        陪审员投票（买家方 / 卖家方）
              ↓
        满足条件（≥10票 或 全员已投）→ 自动裁决
        买家得票 ≥66% → 买家胜诉（退款）
        否则 → 卖家胜诉（订单恢复正常）
              ↓
        超时 24h → 追加 3 名陪审员 → 强制裁决
```

管理员可在任意阶段通过管理端直接裁决纠纷。

## 数据库表

| 表 | 说明 |
|----|------|
| t_user | 用户（角色、信用分、状态） |
| t_address | 收货地址 |
| t_category | 非遗分类（树形，10 个一级类目） |
| t_artisan | 传承人（认证等级、证书、地区） |
| t_product | 商品（图片/视频/文化故事/工艺步骤） |
| t_product_sku | 商品规格 |
| t_cart_item | 购物车 |
| t_order | 订单（状态 0-5，地址快照） |
| t_order_item | 订单明细 |
| t_favorite | 商品收藏 |
| t_follow | 匠人关注 |
| t_dispute | 纠纷（状态、结果、投票数） |
| t_jury_invitation | 陪审邀请 |
| t_jury_vote | 陪审投票 |

## 默认账号

| 角色 | 手机号 | 密码 |
|------|--------|------|
| 管理员 | 13800000001 | 123456 |
| 传承人 | 13800000002 | 123456 |
| 用户 | 13800000003 | 123456 |

管理端地址：`http://localhost:8080/admin.html`

## 开发说明

- 前端认证：登录后 token 持久化到 HarmonyOS Preferences，后续请求自动携带 `Authorization: Bearer <token>`
- 后端认证：`AuthInterceptor` 拦截所有请求，`currentUserId` 通过 request attribute 注入 Controller
- 图片上传：`FileController` 处理 multipart 上传，文件存 `uploads/` 目录
- 定时任务：`DisputeScheduler` 每 60 秒检查超时纠纷
- 价格单位：数据库中价格以**分**存储，前端以**元**展示
