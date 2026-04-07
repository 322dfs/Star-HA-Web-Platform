# Star-HA-Web-Platform 视频演示剧本

**演示时长**: 约 10-15 分钟  
**演示人员**: SUBENCAI  
**录制日期**: ____年____月____日

---

## 演示前准备

### 环境检查清单
- [ ] Docker Desktop 已启动
- [ ] 所有容器正常运行
- [ ] 浏览器已打开（Chrome/Edge）
- [ ] 录屏软件已就绪

### 启动系统
```powershell
cd c:\Users\beeplux\Desktop\工作内容\Web集群项目\Star-HA-Web-Platform
docker compose up -d
docker ps
```

---

## 第一幕：项目介绍（约 2 分钟）

### 画面：GitHub 项目页面
**操作**:
1. 打开浏览器访问 https://github.com/322dfs/Star-HA-Web-Platform
2. 滚动浏览 README.md 内容

**解说词**:
> "大家好，今天为大家演示的是 Star-HA-Web-Platform 高可用 Web 集群平台。这是一个基于 Docker 容器化的一键部署方案，实现了负载均衡、共享存储和系统监控等核心功能。"

**重点展示**:
- 项目标题和徽章
- 系统架构图
- 一键部署说明

---

## 第二幕：服务状态检查（约 1 分钟）

### 画面：PowerShell 终端
**操作**:
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**解说词**:
> "首先检查所有服务的运行状态。可以看到 8 个容器全部正常运行，包括负载均衡器、Web 服务器、共享存储和监控组件。"

**重点展示**:
- 所有容器状态为 "Up"
- 端口映射正确

---

## 第三幕：Web 服务访问（约 2 分钟）

### 画面：浏览器
**操作**:
1. 打开新标签页，访问 http://localhost
2. 刷新页面几次，观察内容变化

**解说词**:
> "现在访问 Web 服务。通过主负载均衡器的 80 端口，我们可以正常访问网站内容。每次刷新，请求会被分发到不同的后端服务器。"

### 画面：浏览器新标签
**操作**:
1. 打开新标签页，访问 http://localhost:8080
2. 展示备用负载均衡器同样可以访问

**解说词**:
> "这是备用负载均衡器，通过 8080 端口访问。当主负载均衡器故障时，备用节点可以接管服务。"

---

## 第四幕：负载均衡演示（约 2 分钟）

### 画面：PowerShell 终端
**操作**:
```powershell
for ($i=1; $i -le 6; $i++) {
    curl.exe -s http://localhost | Select-String "Server"
    Start-Sleep -Milliseconds 500
}
```

**解说词**:
> "通过多次请求可以看到，负载均衡器采用轮询算法，将请求均匀分发到 webapp1 和 webapp2 两个后端服务器，实现了负载均衡。"

**重点展示**:
- 请求交替由 webapp1 和 webapp2 响应

---

## 第五幕：故障切换演示（约 3 分钟）

### 画面：PowerShell 终端
**操作**:
```powershell
# 查看当前状态
docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String "webapp"

# 停止 webapp1
docker stop webapp1

# 再次查看状态
docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String "webapp"
```

**解说词**:
> "现在模拟故障场景。停止 webapp1 容器，模拟一台服务器宕机。"

### 画面：浏览器
**操作**:
1. 刷新 http://localhost 页面
2. 连续刷新几次，确认服务仍可访问

**解说词**:
> "即使 webapp1 故障，服务仍然可以正常访问。因为 webapp2 仍在运行，负载均衡器会自动将请求转发到健康的服务器。这就是高可用的核心价值。"

### 画面：PowerShell 终端
**操作**:
```powershell
# 恢复 webapp1
docker start webapp1

# 验证恢复
docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String "webapp"
```

**解说词**:
> "恢复 webapp1 后，系统自动恢复正常，两个后端服务器重新参与负载均衡。"

---

## 第六幕：共享存储演示（约 2 分钟）

### 画面：浏览器
**操作**:
1. 打开新标签页，访问 http://localhost:8082
2. 展示 FileBrowser 文件管理界面
3. 上传一个测试文件或修改 index.html

**解说词**:
> "这是 FileBrowser 共享存储管理界面。通过它，我们可以方便地管理 Web 内容。所有后端服务器共享同一存储，修改会立即生效。"

**重点展示**:
- 文件列表
- 上传/编辑功能
- 修改后刷新 Web 页面看到变化

---

## 第七幕：监控系统演示（约 3 分钟）

### 画面：浏览器
**操作**:
1. 打开新标签页，访问 http://localhost:9090
2. 展示 Prometheus 界面
3. 点击 Status → Targets

**解说词**:
> "Prometheus 监控系统负责采集所有服务的指标数据。在 Targets 页面可以看到所有监控目标的状态。"

### 画面：浏览器新标签
**操作**:
1. 打开新标签页，访问 http://localhost:3001
2. 登录 Grafana（admin / admin123）
3. 展示监控仪表盘

**解说词**:
> "Grafana 提供了直观的监控仪表盘。可以看到 CPU 使用率、内存使用率、磁盘使用率等关键指标，以及各服务的运行状态。"

**重点展示**:
- CPU 使用率面板
- 内存使用率面板
- 服务状态面板

---

## 第八幕：总结（约 1 分钟）

### 画面：回到 GitHub 页面或架构图
**解说词**:
> "以上就是 Star-HA-Web-Platform 的核心功能演示。项目实现了：
> - 负载均衡：请求均匀分发到多个后端服务器
> - 高可用：单点故障不影响整体服务
> - 共享存储：数据一致性保证
> - 实时监控：系统状态可视化
> 
> 项目已开源在 GitHub，欢迎 Star 和 Fork。感谢观看！"

---

## 演示结束

### 停止系统（可选）
```powershell
docker compose down
```

---

## 附录：服务访问地址汇总

| 服务 | 地址 | 账号 |
|------|------|------|
| Web 服务（主） | http://localhost | - |
| Web 服务（备） | http://localhost:8080 | - |
| FileBrowser | http://localhost:8082 | 无需登录 |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3001 | admin / admin123 |

---

## 录制注意事项

1. **分辨率**: 建议 1920x1080 或更高
2. **帧率**: 30fps 即可
3. **字体**: 终端字体调大，确保清晰可读
4. **浏览器**: 隐藏书签栏，全屏录制效果更佳
5. **解说**: 语速适中，关键操作处稍作停顿
