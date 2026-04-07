<#
.SYNOPSIS
    Star-HA-Web-Platform 视频演示脚本
    
.DESCRIPTION
    用于演示高可用 Web 集群的各项功能，包括：
    - 服务状态检查
    - Web 服务访问测试
    - 负载均衡演示
    - 故障切换演示
    - 监控系统检查
    
.AUTHOR
    SUBENCAI
#>

param(
    [string]$ProjectPath = "c:\Users\beeplux\Desktop\工作内容\Web集群项目\Star-HA-Web-Platform"
)

$Host.UI.RawUI.WindowTitle = "Star-HA-Web-Platform 演示脚本"

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Step)
    Write-Host ">>> $Step" -ForegroundColor Green
}

function Pause-Demo {
    param([string]$Message = "按任意键继续...")
    Write-Host ""
    Write-Host $Message -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host ""
}

function Test-Service {
    param([string]$Url, [string]$Name)
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "  [OK] $Name - 状态码: $($response.StatusCode)" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "  [FAIL] $Name - 错误: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host ""
Write-Host "  ███████╗ █████╗  ██████╗ ██╗     ███████╗" -ForegroundColor Cyan
Write-Host "  ██╔════╝██╔══██╗██╔════╝ ██║     ██╔════╝" -ForegroundColor Cyan
Write-Host "  ███████╗███████║██║  ███╗██║     █████╗  " -ForegroundColor Cyan
Write-Host "  ╚════██║██╔══██║██║   ██║██║     ██╔══╝  " -ForegroundColor Cyan
Write-Host "  ███████║██║  ██║╚██████╔╝███████╗███████╗" -ForegroundColor Cyan
Write-Host "  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  High Availability Web Platform - Docker Edition" -ForegroundColor Yellow
Write-Host "  Author: SUBENCAI" -ForegroundColor DarkGray
Write-Host ""

Pause-Demo "按任意键开始演示..."

# ============================================
# 第一部分：服务状态检查
# ============================================
Write-Header "第一部分：服务状态检查"

Write-Step "检查 Docker 服务状态..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | Where-Object { $_ -match "nginx|webapp|prometheus|grafana|filebrowser|node-exporter" }

Write-Host ""
Write-Step "检查容器健康状态..."
$containers = @("nginx-lb-master", "nginx-lb-backup", "webapp1", "webapp2", "prometheus", "grafana", "filebrowser", "node-exporter")
foreach ($container in $containers) {
    $status = docker inspect -f '{{.State.Status}}' $container 2>$null
    if ($status -eq "running") {
        Write-Host "  [OK] $container - 运行中" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $container - $status" -ForegroundColor Red
    }
}

Pause-Demo

# ============================================
# 第二部分：Web 服务访问测试
# ============================================
Write-Header "第二部分：Web 服务访问测试"

Write-Step "测试主负载均衡器 (http://localhost)..."
Test-Service -Url "http://localhost" -Name "主负载均衡器"

Write-Step "测试备用负载均衡器 (http://localhost:8080)..."
Test-Service -Url "http://localhost:8080" -Name "备用负载均衡器"

Write-Host ""
Write-Step "获取 Web 服务响应内容..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing
    Write-Host "响应内容预览:" -ForegroundColor DarkGray
    $response.Content.Substring(0, [Math]::Min(500, $response.Content.Length))
} catch {
    Write-Host "获取响应失败: $($_.Exception.Message)" -ForegroundColor Red
}

Pause-Demo

# ============================================
# 第三部分：负载均衡演示
# ============================================
Write-Header "第三部分：负载均衡演示"

Write-Step "多次请求观察负载均衡效果..."
Write-Host ""
for ($i = 1; $i -le 6; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing
        if ($response.Content -match "Server:\s*(webapp\d+)") {
            $server = $Matches[1]
            Write-Host "  请求 $i : 由 $server 响应" -ForegroundColor Cyan
        } else {
            Write-Host "  请求 $i : 响应正常" -ForegroundColor Cyan
        }
        Start-Sleep -Milliseconds 500
    } catch {
        Write-Host "  请求 $i : 失败" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "说明: 负载均衡器采用轮询算法，将请求分发到 webapp1 和 webapp2" -ForegroundColor DarkGray

Pause-Demo

# ============================================
# 第四部分：故障切换演示
# ============================================
Write-Header "第四部分：故障切换演示"

Write-Step "当前服务状态..."
docker ps --format "table {{.Names}}\t{{.Status}}" | Where-Object { $_ -match "webapp" }

Write-Host ""
Write-Step "模拟 webapp1 故障 (停止容器)..."
docker stop webapp1
Write-Host "  webapp1 已停止" -ForegroundColor Yellow

Write-Host ""
Write-Step "测试服务是否仍然可用..."
Start-Sleep -Seconds 2

for ($i = 1; $i -le 3; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost" -UseBasicParsing -TimeoutSec 5
        Write-Host "  请求 $i : 服务正常响应 (状态码: $($response.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "  请求 $i : 服务异常" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "说明: 即使 webapp1 故障，webapp2 仍可提供服务，实现高可用" -ForegroundColor DarkGray

Pause-Demo

Write-Step "恢复 webapp1 服务..."
docker start webapp1
Write-Host "  webapp1 已恢复" -ForegroundColor Green

Start-Sleep -Seconds 3

Write-Host ""
Write-Step "验证服务恢复..."
docker ps --format "table {{.Names}}\t{{.Status}}" | Where-Object { $_ -match "webapp" }

Pause-Demo

# ============================================
# 第五部分：共享存储演示
# ============================================
Write-Header "第五部分：共享存储演示 (FileBrowser)"

Write-Step "测试 FileBrowser 服务..."
Test-Service -Url "http://localhost:8082" -Name "FileBrowser"

Write-Host ""
Write-Host "FileBrowser 功能说明:" -ForegroundColor DarkGray
Write-Host "  - 访问地址: http://localhost:8082" -ForegroundColor White
Write-Host "  - 无需登录即可使用" -ForegroundColor White
Write-Host "  - 可上传、编辑、删除共享存储中的文件" -ForegroundColor White
Write-Host "  - 所有 Web 服务器共享同一存储" -ForegroundColor White

Write-Host ""
Write-Host "请在浏览器中打开 http://localhost:8082 查看文件管理界面" -ForegroundColor Yellow

Pause-Demo

# ============================================
# 第六部分：监控系统演示
# ============================================
Write-Header "第六部分：监控系统演示"

Write-Step "测试 Prometheus 服务..."
Test-Service -Url "http://localhost:9090" -Name "Prometheus"

Write-Step "测试 Grafana 服务..."
Test-Service -Url "http://localhost:3001" -Name "Grafana"

Write-Host ""
Write-Host "监控系统访问信息:" -ForegroundColor DarkGray
Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "  Grafana:    http://localhost:3001" -ForegroundColor White
Write-Host "  账号: admin" -ForegroundColor White
Write-Host "  密码: admin123" -ForegroundColor White

Write-Host ""
Write-Step "检查 Prometheus 采集目标状态..."
try {
    $targets = Invoke-RestMethod -Uri "http://localhost:9090/api/v1/targets" -TimeoutSec 5
    $upTargets = ($targets.data.activeTargets | Where-Object { $_.health -eq "up" }).Count
    $totalTargets = $targets.data.activeTargets.Count
    Write-Host "  目标状态: $upTargets/$totalTargets 在线" -ForegroundColor Green
} catch {
    Write-Host "  无法获取目标状态" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "请在浏览器中打开 Grafana 查看监控仪表盘" -ForegroundColor Yellow

Pause-Demo

# ============================================
# 第七部分：架构总结
# ============================================
Write-Header "第七部分：架构总结"

Write-Host "系统架构组成:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [负载均衡层]" -ForegroundColor Yellow
Write-Host "    - nginx-lb-master (主) - 172.28.0.11:80"
Write-Host "    - nginx-lb-backup (备) - 172.28.0.12:8080"
Write-Host ""
Write-Host "  [Web 服务层]" -ForegroundColor Yellow
Write-Host "    - webapp1 - 172.28.0.21"
Write-Host "    - webapp2 - 172.28.0.22"
Write-Host ""
Write-Host "  [共享存储层]" -ForegroundColor Yellow
Write-Host "    - Docker Volume (shared-webapp)"
Write-Host "    - FileBrowser - 172.28.0.41:8082"
Write-Host ""
Write-Host "  [监控层]" -ForegroundColor Yellow
Write-Host "    - Prometheus - 172.28.0.30:9090"
Write-Host "    - Grafana - 172.28.0.31:3001"
Write-Host "    - Node Exporter - 172.28.0.32:9100"
Write-Host ""

Write-Host "高可用特性:" -ForegroundColor Cyan
Write-Host "  1. 主备负载均衡器 - 故障自动切换"
Write-Host "  2. 多后端服务器 - 单点故障不影响服务"
Write-Host "  3. 共享存储 - 数据一致性保证"
Write-Host "  4. 实时监控 - 系统状态可视化"
Write-Host ""

Pause-Demo "演示结束，按任意键退出..."

Write-Host ""
Write-Host "感谢观看 Star-HA-Web-Platform 演示!" -ForegroundColor Green
Write-Host "GitHub: https://github.com/322dfs/Star-HA-Web-Platform" -ForegroundColor DarkGray
Write-Host ""
