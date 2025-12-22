# Star-HA-Web-Platform
一个基于开源技术栈构建的轻量级、高可用 Web 服务基础设施方案，适用于中小规模企业内网或准生产环境。

# 星辰高可用 Web 服务平台（Star-HA Web Platform）

> 一个基于开源技术栈构建的轻量级、高可用 Web 服务基础设施方案，适用于中小规模企业内网或准生产环境。

## 📌 项目背景

在公司内部测试及准生产环境中，原有 Web 服务架构存在单点故障风险，缺乏统一监控与安全运维入口。为提升系统稳定性、可维护性与安全性，本项目独立设计并落地了一套高可用 Web 服务平台，最终被公司 DevOps 团队采纳为标准参考架构。

## 🧩 技术栈

- **负载均衡**：Nginx + Keepalived（VRRP 协议）
- **共享存储**：NFS（用于同步 Web 配置与静态资源）
- **监控告警**：Prometheus + Grafana + Node Exporter + 自定义指标
- **安全运维**：JumpServer 堡垒机（统一 SSH 入口、操作审计、权限控制）
- **操作系统**：CentOS 7 / Rocky Linux 8
- **自动化**：Shell 脚本 + 手动部署（适配中小规模环境）

## 🏗️ 架构概览

```text
                    +---------------------+
                    |   Client / User     |
                    +----------+----------+
                               |
                  (访问 VIP: 192.168.x.100)
                               |
          +-------------------+-------------------+
          |                                       |
+---------v---------+                 +-----------v---------+
|  Nginx + Keepalived |               |  Nginx + Keepalived |
|      (Master)       |<-- VRRP ----->|      (Backup)       |
+---------+---------+                 +-----------+---------+
          |                                       |
          +------------------+--------------------+
                             |
                   +---------v---------+
                   |    NFS Server     |
                   | (共享配置/静态文件)|
                   +---------+---------+
                             |
          +------------------+------------------+
          |                  |                  |
+---------v---------+ +------v------+ +---------v---------+
|   Web App Node 1  | | Web App Node 2| |   Web App Node N  |
+-------------------+ +-------------+ +-------------------+
          |                  |                  |
          +------------------+------------------+
                             |
                   +---------v---------+
                   |   JumpServer      |
                   | (堡垒机 - 运维入口)|
                   +-------------------+

                     +------------------+
                     |  Prometheus +    |
                     |    Grafana       |
                     | (监控 & 可视化)   |
                     +------------------+

```

## ✅ 核心特性

- **高可用**：双 Nginx 节点通过 Keepalived 实现 VIP 自动漂移，故障切换时间 < 10 秒。
- **配置一致**：Web 应用节点通过 NFS 挂载统一目录，确保配置与静态资源同步。
- **全面监控**：实时采集 CPU、内存、磁盘、网络、HTTP 状态码等 20+ 指标，支持阈值告警。
- **安全合规**：所有服务器仅允许通过 JumpServer 堡垒机访问，操作全程录像、权限分级。
- **文档完备**：包含完整部署手册、故障排查指南、日常巡检清单。
📂 目录结构
```
star-ha-web-platform/
├── docs/
│   ├── deployment-guide.md        # 部署手册（含步骤、命令、配置样例）
│   ├── troubleshooting.md         # 常见问题与解决方案
│   └── maintenance-checklist.md   # 日常巡检清单
├── scripts/
│   ├── deploy-nginx.sh           # Nginx 安装与配置脚本
│   ├── setup-nfs-client.sh       # NFS 客户端挂载脚本
│   └── install-node-exporter.sh  # Prometheus Exporter 安装脚本
├── configs/
│   ├── nginx.conf.example
│   ├── keepalived.conf.master
│   ├── keepalived.conf.backup
│   └── prometheus.yml.example
└── README.md

```
```text
## 🚀 快速开始
⚠️ 本方案适用于 2 台 LB + N 台 Web + 1 台 NFS + 1 台 JumpServer 的典型中小规模场景。
1. 准备环境
● 确保所有节点时间同步（建议使用 chrony 或 ntpd）
● 关闭 SELinux 和 firewalld（或按需开放端口）
2. 部署 NFS Server
#### 在 NFS 服务器上执行
yum install -y nfs-utils
echo "/data/webshare *(rw,sync,no_root_squash)" > /etc/exports
systemctl enable --now nfs-server
3. 部署 Nginx + Keepalived（主备）
#### 在两台 LB 节点上执行
./scripts/deploy-nginx.sh
#### 根据角色选择 master 或 backup 配置
cp configs/keepalived.conf.master /etc/keepalived/keepalived.conf  # 主节点
cp configs/keepalived.conf.backup /etc/keepalived/keepalived.conf  # 备节点
systemctl enable --now keepalived
4. 部署 Web 节点
● 安装 Web 服务（如 Tomcat / Apache）
● 挂载 NFS 共享目录：
./scripts/setup-nfs-client.sh 192.168.x.NFS_IP:/data/webshare /var/www/html
5. 部署监控
./scripts/install-node-exporter.sh
#### 配置 Prometheus 抓取目标（参考 configs/prometheus.yml.example）
6. 接入 JumpServer
● 在 JumpServer 控制台添加所有 Linux 节点资产
● 配置用户权限与授权规则
```

## 📝 文档说明
详细部署步骤、参数解释、安全加固建议请参阅 docs/deployment-guide.md。
## 🛡️ 安全提示
● 请勿在公网直接暴露 Keepalived VIP 或 NFS 端口。
● 建议在内网 VLAN 或防火墙策略下运行本架构。
● JumpServer 应启用 MFA（多因素认证）并定期审计会话日志。
## 📄 许可证

-  本项目采用 Apache License 2.0 开源协议，可用于学习、研究及商业用途（需保留版权声明）。
---
💡 备注：
本项目为脱敏版本，已移除公司 IP、域名、业务逻辑等敏感信息。实际生产部署请结合具体网络与安全策略调整。


 
 
