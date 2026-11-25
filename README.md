# 国风非遗 · HarmonyOS + Spring Boot 全栈文化电商平台

[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-ArkTS-blue)](https://developer.huawei.com/consumer/cn/harmonyos/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7-green)](https://spring.io/projects/spring-boot)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-orange)](https://www.mysql.com/)
[![WebSocket](https://img.shields.io/badge/WebSocket-Real--time-purple)](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)

非遗文化内容社区 + 手工品电商 + "小法庭"纠纷维权系统。HarmonyOS 原生应用 + Java Spring Boot 后端全栈项目。

---

## 📸 功能概览

| 模块 | 功能 |
|------|------|
| 🏠 内容社区 | 非遗作品发布与浏览（图文/视频）、标签筛选、热榜排序、内容审核工作流 |
| 🛒 电商系统 | 手工品上架、SKU 管理、下单→付款→发货→收货完整订单生命周期 |
| ⚖️ 小法庭 | 买家发起维权 → 协商 → 随机邀请陪审团 → 投票 → 66%支持率自动裁决 |
| 💬 即时通讯 | WebSocket 实时聊天，支持会话列表、未读计数 |
| 🎨 国风 UI | 朱砂红/宣纸色/鎏金色彩体系，印章式选中态，方正雅致微圆角 |

## 🧱 技术架构

```
┌─────────────────┐     REST / WebSocket     ┌──────────────────┐
│  HarmonyOS App   │ ◄──────────────────────► │  Spring Boot API │
│  ArkTS (22 pgs)  │                          │  MyBatis / JPA   │
│  API 12          │                          │  MySQL 8.0       │
└─────────────────┘                          └──────────────────┘
```

## 🚀 快速启动

```bash
# 1. 初始化数据库
mysql -u root -p < java/src/main/resources/init.sql

# 2. 启动后端
cd java && mvn spring-boot:run

# 3. 启动前端
# DevEco Studio 打开 arkts/ 目录 → Run
```

## 📁 项目结构

```
├── arkts/                     # HarmonyOS 前端 (22 pages)
│   ├── pages/                 # Login/Index/ProductDetail/Chat...
│   ├── components/            # 复用组件
│   ├── service/               # API 调用 + WebSocket 管理
│   └── model/                 # 数据模型
├── java/                      # Spring Boot 后端 (主版本)
│   ├── controller/            # REST API (18 个)
│   ├── service/               # 业务逻辑
│   ├── scheduler/             # 定时任务 (纠纷自动裁决)
│   └── deploy/                # 部署配置 (Caddy + systemd)
├── backend/                   # Spring Boot 后端 (JPA 版)
└── init.sql                   # 数据库初始化 + 种子数据
```

## 🔑 技术亮点

- **WebSocket 实时聊天**：Spring WebSocket + ArkTS WebSocket，支持 Token 鉴权握手
- **小法庭陪审团**：随机邀请 → 投票 → 定时任务自动裁决（66% 买家支持率阈值）
- **服务发现**：ArkTS 端 `ServerDiscovery` 自动探测局域网服务器 IP
- **国风设计系统**：`Theme.ets` 统一管理色彩/圆角/字体，全局可切换
- **内容审核流**：发布→审核中→通过/驳回，管理员 HTML 面板

## 📄 License

MIT
