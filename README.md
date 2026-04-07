# Star-HA-Web-Platform (Docker 容器化版本)

> 一个基于 Docker 的高可用 Web 集群演示平台，一键容器化部署，适用于学习、演示和开发测试环境。

[![Docker](https://img.shields.io/badge/Docker-容器化-blue)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 📌 项目背景

在企业级 Web 服务架构中，高可用性是核心需求之一。本项目通过 Docker 容器化技术，实现了一套轻量级的高可用 Web 服务集群，旨在帮助开发者快速理解和实践以下技术：

- 负载均衡与故障切换
- 共享存储与数据一致性
- 容器化部署与服务编排
- 系统监控与可视化

本项目适合作为学习演示、技术分享、面试展示或开发测试环境使用。

---

## ✨ 项目特性

| 特性 | 说明 |
|------|------|
| 🚀 一键部署 | `docker compose up -d` 即可启动全部服务 |
| 🔄 高可用架构 | 主备负载均衡器 + 多后端 Web 服务器 |
| 📦 共享存储 | Docker Volume + FileBrowser 文件管理 |
| 📊 全方位监控 | Prometheus + Grafana 实时监控仪表盘 |
| 🐳 容器化 | 跨平台支持 Windows/Mac/Linux |
| 📝 文档完备 | 部署文档、测试文档、测试报告齐全 |

---

## 🏗️ 系统架构

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                        用户访问                              │
                    └─────────────────────────────────────────────────────────────┘
                                                │
                                                ▼
                    ┌─────────────────────────────────────────────────────────────┐
                    │                    负载均衡层 (HA)                           │
                    │  ┌─────────────────────┐    ┌─────────────────────┐         │
                    │  │   nginx-lb-master   │    │   nginx-lb-backup   │         │
                    │  │    (172.28.0.11)    │    │    (172.28.0.12)    │         │
                    │  │      Port: 80       │    │     Port: 8080      │         │
                    │  └─────────────────────┘    └─────────────────────┘         │
                    └─────────────────────────────────────────────────────────────┘
                                                │
                                                ▼
                    ┌─────────────────────────────────────────────────────────────┐
                    │                      Web 服务层                              │
                    │  ┌─────────────────────┐    ┌─────────────────────┐         │
                    │  │      webapp1        │    │      webapp2        │         │
                    │  │   (172.28.0.21)     │    │   (172.28.0.22)     │         │
                    │  └─────────────────────┘    └─────────────────────┘         │
                    └─────────────────────────────────────────────────────────────┘
                                                │
                                                ▼
                    ┌─────────────────────────────────────────────────────────────┐
                    │                     共享存储层                               │
                    │  ┌─────────────────────────────────────────────────────┐   │
                    │  │              Docker Volume (shared-webapp)           │   │
                    │  └─────────────────────────────────────────────────────┘   │
                    │  ┌─────────────────────────────────────────────────────┐   │
                    │  │              FileBrowser (172.28.0.41)               │   │
                    │  │                   Port: 8082                         │   │
                    │  └─────────────────────────────────────────────────────┘   │
                    └─────────────────────────────────────────────────────────────┘
                                                │
                                                ▼
                    ┌─────────────────────────────────────────────────────────────┐
                    │                       监控层                                 │
                    │  ┌─────────────────────────┐  ┌─────────────────────────┐   │
                    │  │   Prometheus            │  │   Grafana               │   │
                    │  │   (172.28.0.30)         │  │   (172.28.0.31)         │   │
                    │  │   Port: 9090            │  │   Port: 3001            │   │
                    │  └─────────────────────────┘  └─────────────────────────┘   │
                    │  ┌─────────────────────────┐                                │
                    │  │   Node Exporter         │                                │
                    │  │   (172.28.0.32)         │                                │
                    │  │   Port: 9100            │                                │
                    │  └─────────────────────────┘                                │
                    └─────────────────────────────────────────────────────────────┘
```

---

## 📦 组件说明

| 组件 | 版本 | 功能 | 端口 |
|------|------|------|------|
| nginx-lb-master | custom | 主负载均衡器 | 80, 443 |
| nginx-lb-backup | custom | 备负载均衡器 | 8080 |
| webapp1/2 | nginx:alpine | Web 应用服务器 | - |
| filebrowser | latest | 共享存储文件管理 | 8082 |
| prometheus | latest | 监控数据采集 | 9090 |
| grafana | 11.0.0 | 监控可视化 | 3001 |
| node-exporter | latest | 系统指标采集 | 9100 |

---

## 🚀 快速开始

### 环境要求

- Docker Desktop (Windows/Mac) 或 Docker Engine (Linux)
- Docker Compose v2.x
- 至少 8GB 内存
- 至少 4 核 CPU

### 一键部署

```bash
# 克隆项目
git clone https://github.com/322dfs/Star-HA-Web-Platform.git
cd Star-HA-Web-Platform

# 启动所有服务
docker compose up -d

# 查看服务状态
docker compose ps
```

### 访问服务

| 服务 | 地址 | 账号/密码 |
|------|------|-----------|
| Web 服务 (主) | http://localhost | - |
| Web 服务 (备) | http://localhost:8080 | - |
| FileBrowser | http://localhost:8082 | 无需登录 |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3001 | admin / admin123 |

---

## 📁 项目结构

```
Star-HA-Web-Platform/
├── docker-compose.yml          # Docker Compose 配置
├── configs/
│   ├── nginx/
│   │   ├── nginx.conf          # 负载均衡器配置
│   │   └── webapp-nginx.conf   # Web 应用配置
│   ├── prometheus/
│   │   └── prometheus.yml      # Prometheus 配置
│   └── grafana/
│       └── provisioning/       # Grafana 自动配置
│           ├── dashboards/
│           └── datasources/
├── docker/
│   └── nginx-keepalived/       # Nginx 镜像构建文件
├── webapp/                     # Web 应用静态文件
└── docs/
    ├── PROJECT_GOALS.md        # 项目目标文档
    ├── TEST_PLAN.md            # 测试计划文档
    └── TEST_REPORT.md          # 测试报告
```

---

## 🎯 适用场景

### ✅ 推荐场景

| 场景 | 说明 |
|------|------|
| 学习演示 | 理解高可用架构、负载均衡、容器化部署 |
| 技术分享 | 展示企业级 Web 服务架构设计 |
| 面试展示 | 展示技术能力和项目经验 |
| 开发测试 | 本地快速搭建测试环境 |
| 原型验证 | 验证架构设计的可行性 |

### ⚠️ 不适用场景

- 生产环境（需要更多安全加固和高可用保障）
- 大规模高并发场景（需要分布式架构）
- 需要真实 VIP 漂移的场景（容器环境限制）

---

## 🔮 后续优化方向

### 高可用增强
- [ ] 引入 Keepalived 实现 VIP 漂移（需多机部署）
- [ ] 添加健康检查和自动故障转移
- [ ] 实现容器编排平台 (Kubernetes)

### 安全加固
- [ ] 添加 HTTPS 支持 (SSL/TLS 证书)
- [ ] 配置认证和访问控制
- [ ] 网络隔离和安全组配置
- [ ] 添加堡垒机组件

### 功能扩展
- [ ] 添加数据库集群 (MySQL/PostgreSQL)
- [ ] 添加缓存层 (Redis Cluster)
- [ ] 添加消息队列 (RabbitMQ/Kafka)
- [ ] 支持 CI/CD 流水线集成

### 监控增强
- [ ] 添加告警规则和通知
- [ ] 集成日志收集 (ELK Stack)
- [ ] 添加分布式追踪 (Jaeger/Zipkin)
- [ ] 自定义业务指标监控

### 部署优化
- [ ] 支持 Kubernetes 部署
- [ ] 支持 Helm Chart
- [ ] 支持多云部署 (AWS/阿里云/腾讯云)
- [ ] 自动化测试和发布流程

---

## 📊 测试结果

| 测试类别 | 用例数 | 通过数 | 通过率 |
|----------|--------|--------|--------|
| 功能测试 | 6 | 6 | 100% |
| 高可用测试 | 3 | 2.5 | 83% |
| 监控测试 | 3 | 3 | 100% |
| **总计** | **12** | **11.5** | **96%** |

详细测试报告请查看 [TEST_REPORT.md](docs/TEST_REPORT.md)

---

## 📖 文档

- [项目目标](docs/PROJECT_GOALS.md) - 项目设计目标和架构说明
- [测试计划](docs/TEST_PLAN.md) - 测试用例和测试流程
- [测试报告](docs/TEST_REPORT.md) - 测试结果和截图清单

---

## 🛠️ 故障排查

### 容器无法启动
```bash
# 查看容器日志
docker compose logs <container_name>

# 检查端口占用
netstat -tlnp | grep <port>
```

### 服务无法访问
```bash
# 检查容器状态
docker compose ps

# 检查网络
docker network inspect star-ha-web-platform_ha-network
```

### Grafana 显示 No Data
```bash
# 检查 Prometheus targets
curl http://localhost:9090/api/v1/targets

# 重启 Prometheus
docker compose restart prometheus
```

---

## 📄 License

MIT License

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📮 联系方式

- **作者**: SUBENCAI
- **邮箱**: 2080981057@qq.com
- **GitHub**: [https://github.com/322dfs](https://github.com/322dfs)

如有问题或建议，欢迎提交 [Issue](https://github.com/322dfs/Star-HA-Web-Platform/issues)
