# Star-HA-Web-Platform 项目记忆库

> 本文件用于记录项目关键信息，方便快速恢复上下文

---

## 项目概述

**项目名称**: Star-HA-Web-Platform  
**项目类型**: 高可用 Web 集群平台  
**部署方式**: Docker 容器化一键部署  
**作者**: SUBENCAI  
**邮箱**: 2080981057@qq.com  
**GitHub**: https://github.com/322dfs/Star-HA-Web-Platform

---

## 系统架构

```
用户访问
    │
    ▼
┌─────────────────────────────────────┐
│         负载均衡层 (HA)              │
│  nginx-lb-master (172.28.0.11:80)   │
│  nginx-lb-backup (172.28.0.12:8080) │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│          Web 服务层                  │
│  webapp1 (172.28.0.21)              │
│  webapp2 (172.28.0.22)              │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│         共享存储层                   │
│  Docker Volume (shared-webapp)      │
│  FileBrowser (172.28.0.41:8082)     │
└─────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────┐
│          监控层                      │
│  Prometheus (172.28.0.30:9090)      │
│  Grafana (172.28.0.31:3001)         │
│  Node Exporter (172.28.0.32:9100)   │
└─────────────────────────────────────┘
```

---

## 容器清单

| 容器名称 | 镜像 | IP地址 | 端口映射 | 功能 |
|----------|------|--------|----------|------|
| nginx-lb-master | 自建 | 172.28.0.11 | 80:80, 443:443 | 主负载均衡器 |
| nginx-lb-backup | 自建 | 172.28.0.12 | 8080:80 | 备用负载均衡器 |
| webapp1 | nginx:alpine | 172.28.0.21 | - | Web服务器1 |
| webapp2 | nginx:alpine | 172.28.0.22 | - | Web服务器2 |
| filebrowser | filebrowser/filebrowser | 172.28.0.41 | 8082:80 | 文件管理器 |
| prometheus | prom/prometheus | 172.28.0.30 | 9090:9090 | 监控数据采集 |
| grafana | grafana/grafana:11.0.0 | 172.28.0.31 | 3001:3000 | 监控可视化 |
| node-exporter | prom/node-exporter | 172.28.0.32 | 9100:9100 | 系统指标采集 |
| storage-init | alpine:latest | 172.28.0.40 | - | 存储初始化 |

---

## 服务访问地址

| 服务 | 地址 | 账号/密码 |
|------|------|-----------|
| Web 服务（主） | http://localhost | - |
| Web 服务（备） | http://localhost:8080 | - |
| FileBrowser | http://localhost:8082 | 无需登录 |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3001 | admin / admin123 |

---

## 文件结构

```
Star-HA-Web-Platform/
├── README.md                    # 项目说明文档
├── LICENSE                      # MIT 开源协议
├── .gitignore                   # Git 忽略配置
├── docker-compose.yml           # Docker 编排配置
├── configs/                     # 配置文件目录
│   ├── nginx/
│   │   ├── nginx.conf           # 负载均衡器配置
│   │   └── webapp-nginx.conf    # Web服务器配置
│   ├── prometheus/
│   │   └── prometheus.yml       # Prometheus 配置
│   ├── grafana/
│   │   └── provisioning/
│   │       ├── dashboards/      # 仪表盘配置
│   │       └── datasources/     # 数据源配置
│   └── keepalived/
│       ├── keepalived-master.conf
│       └── keepalived-backup.conf
├── docker/
│   └── nginx-keepalived/
│       ├── Dockerfile
│       └── docker-entrypoint.sh
├── webapp/
│   └── index.html               # Web 页面
├── docs/
│   ├── PROJECT_GOALS.md         # 项目目标文档
│   ├── TEST_PLAN.md             # 测试计划
│   ├── TEST_REPORT.md           # 测试报告
│   ├── DEMO_SCRIPT.md           # 演示剧本
│   └── DEMO_STEPS.md            # 演示操作步骤
└── scripts/
    └── demo-test.ps1            # 演示测试脚本
```

---

## 常用命令

### 启动系统
```powershell
cd c:\Users\beeplux\Desktop\工作内容\Web集群项目\Star-HA-Web-Platform
docker compose up -d
```

### 停止系统
```powershell
docker compose down
```

### 查看服务状态
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 测试负载均衡
```powershell
for ($i=1; $i -le 6; $i++) { curl.exe -s http://localhost/server-info; Write-Host ""; Start-Sleep -Milliseconds 300 }
```

### 故障切换测试
```powershell
docker stop webapp1
curl.exe -s http://localhost/server-info
docker start webapp1
```

---

## 已解决的问题

### 1. 端口冲突
- **问题**: Grafana 默认端口 3000 被占用
- **解决**: 改为 3001:3000

### 2. 镜像拉取失败
- **问题**: gcr.io 镜像无法拉取
- **解决**: 使用替代镜像源

### 3. Grafana 重启循环
- **问题**: datasource 配置导致容器重启
- **解决**: 设置固定 UID，使用 Grafana 11.0.0

### 4. 监控数据无数据
- **问题**: Prometheus 无法采集 nginx 指标
- **解决**: 使用 /nginx-status 端点

### 5. 负载均衡演示不明显
- **问题**: 页面不显示服务器名称
- **解决**: 添加 /server-info 端点，前端 JS 获取并显示

---

## 技术栈

- **容器编排**: Docker Compose
- **负载均衡**: Nginx
- **高可用**: Keepalived（配置已预留）
- **共享存储**: Docker Volume + FileBrowser
- **监控采集**: Prometheus + Node Exporter
- **监控可视化**: Grafana
- **Web 服务器**: Nginx Alpine

---

## 后续优化方向

### 高可用增强
- [ ] 引入 Keepalived 实现 VIP 漂移（需多机部署）
- [ ] 添加健康检查和自动故障转移
- [ ] 实现容器编排平台 (Kubernetes)

### 安全加固
- [ ] 添加 HTTPS 支持 (SSL/TLS 证书)
- [ ] 配置认证和访问控制
- [ ] 网络隔离和安全组配置

### 功能扩展
- [ ] 添加数据库集群
- [ ] 添加缓存层
- [ ] 添加消息队列
- [ ] 支持 CI/CD 流水线集成

---

## 项目状态

- ✅ 核心功能完成
- ✅ 文档编写完成
- ✅ 测试通过
- ✅ GitHub 发布完成
- ✅ 视频演示完成

---

## 更新记录

| 日期 | 更新内容 |
|------|----------|
| 2026-04-07 | 项目初始化，完成 Docker 容器化部署 |
| 2026-04-07 | 添加监控系统 (Prometheus + Grafana) |
| 2026-04-07 | 添加共享存储 (FileBrowser) |
| 2026-04-07 | 完成项目文档和测试报告 |
| 2026-04-07 | 发布到 GitHub |
| 2026-04-07 | 添加视频演示脚本和操作步骤 |
| 2026-04-07 | 优化负载均衡演示效果（添加服务器名称显示） |
