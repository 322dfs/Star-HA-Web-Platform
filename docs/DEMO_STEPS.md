# Star-HA-Web-Platform 视频演示操作步骤

---

## 准备工作

### 1. 启动系统
打开 PowerShell，执行：
```powershell
cd c:\Users\beeplux\Desktop\工作内容\Web集群项目\Star-HA-Web-Platform
docker compose up -d
```

### 2. 等待服务启动（约30秒）
```powershell
docker ps
```
确认看到 8 个容器状态都是 "Up"

---

## 第一幕：项目介绍

### 操作
1. 打开浏览器
2. 访问：https://github.com/322dfs/Star-HA-Web-Platform
3. 滚动浏览 README.md 内容

### 解说
> "今天演示 Star-HA-Web-Platform 高可用 Web 集群平台，基于 Docker 容器化一键部署。"

---

## 第二幕：服务状态检查

### 操作
在 PowerShell 执行：
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 解说
> "可以看到 8 个容器全部正常运行。"

---

## 第三幕：Web 服务访问

### 操作
1. 打开浏览器新标签页
2. 访问：http://localhost
3. 观察页面显示的 "Server: webapp1" 或 "Server: webapp2"
4. 刷新页面几次，观察服务器名称变化

5. 打开另一个新标签页
6. 访问：http://localhost:8080
7. 这是备用负载均衡器

### 解说
> "通过主负载均衡器访问 Web 服务，每次刷新请求会分发到不同服务器。备用负载均衡器通过 8080 端口访问。"

---

## 第四幕：负载均衡演示

### 操作
在 PowerShell 执行：
```powershell
for ($i=1; $i -le 6; $i++) { curl.exe -s http://localhost/server-info; Write-Host ""; Start-Sleep -Milliseconds 300 }
```

### 预期结果
```
{"server": "webapp1"}
{"server": "webapp2"}
{"server": "webapp1"}
{"server": "webapp2"}
{"server": "webapp1"}
{"server": "webapp2"}
```

### 解说
> "请求交替由 webapp1 和 webapp2 响应，证明负载均衡正常工作。"

---

## 第五幕：故障切换演示

### 步骤1：查看当前状态
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String "webapp"
```

### 步骤2：停止 webapp1
```powershell
docker stop webapp1
```

### 步骤3：验证服务仍可用
```powershell
for ($i=1; $i -le 3; $i++) { curl.exe -s http://localhost/server-info; Write-Host ""; Start-Sleep -Milliseconds 300 }
```

### 预期结果
```
{"server": "webapp2"}
{"server": "webapp2"}
{"server": "webapp2"}
```

### 步骤4：恢复 webapp1
```powershell
docker start webapp1
```

### 步骤5：验证恢复
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String "webapp"
```

### 解说
> "停止 webapp1 后，服务仍然可用，所有请求由 webapp2 响应。恢复后，两个服务器重新参与负载均衡。这就是高可用的核心价值。"

---

## 第六幕：共享存储演示

### 操作
1. 打开浏览器新标签页
2. 访问：http://localhost:8082
3. 展示 FileBrowser 文件管理界面
4. 可以点击 index.html 查看内容

### 解说
> "FileBrowser 是共享存储管理界面，可以上传、编辑、删除 Web 内容文件。"

---

## 第七幕：监控系统演示

### 操作1：Prometheus
1. 打开浏览器新标签页
2. 访问：http://localhost:9090
3. 点击顶部菜单 "Status" → "Targets"
4. 展示监控目标列表

### 操作2：Grafana
1. 打开浏览器新标签页
2. 访问：http://localhost:3001
3. 登录：
   - 用户名：admin
   - 密码：admin123
4. 展示监控仪表盘

### 解说
> "Prometheus 采集所有服务的监控数据，Grafana 提供可视化仪表盘，可以看到 CPU、内存、磁盘等关键指标。"

---

## 第八幕：总结

### 操作
回到 GitHub 页面

### 解说
> "演示完成。项目实现了负载均衡、高可用、共享存储和实时监控。项目已开源，欢迎 Star 和 Fork。"

---

## 演示结束

### 可选：停止系统
```powershell
docker compose down
```

---

## 服务地址汇总

| 服务 | 地址 | 账号 |
|------|------|------|
| Web（主） | http://localhost | - |
| Web（备） | http://localhost:8080 | - |
| FileBrowser | http://localhost:8082 | 无需登录 |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3001 | admin / admin123 |
