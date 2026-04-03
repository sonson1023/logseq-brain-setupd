# ─────────────────────────────────────────────────
# Logseq + Claude Memory Stack — Windows Installer
#
# 사용법:
#   git clone https://github.com/<you>/logseq-brain-setup.git
#   cd logseq-brain-setup
#   .\install.ps1
# ─────────────────────────────────────────────────

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogseqGraph = "$env:USERPROFILE\logseq-graph"
$ClaudeDir = "$env:USERPROFILE\.claude"
$ScriptsDir = "$env:USERPROFILE\scripts"

# ── 설정 로드 ──
$ConfigFile = Join-Path $ScriptDir "config.env"
if (Test-Path $ConfigFile) {
    Get-Content $ConfigFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=["'']?(.+?)["'']?\s*$') {
            Set-Variable -Name $Matches[1].Trim() -Value $Matches[2].Trim()
        }
    }
}
if (-not $LOGSEQ_TOKEN) {
    $LOGSEQ_TOKEN = python -c "import secrets; print(secrets.token_urlsafe(32))"
    Write-Host "새 토큰 생성됨: $LOGSEQ_TOKEN"
}

Write-Host ""
Write-Host "══════════════════════════════════════════════"
Write-Host "  Logseq + Claude Memory Stack Installer (Win)"
Write-Host "══════════════════════════════════════════════"
Write-Host ""

# ── 1. Node.js ──
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "→ [1/8] Node.js 설치..."
    winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
} else {
    Write-Host "✓ [1/8] Node.js $(node -v)"
}

# ── 2. Logseq 앱 ──
$LogseqInstalled = (Get-Command Logseq -ErrorAction SilentlyContinue) -or (Test-Path "$env:LOCALAPPDATA\Programs\Logseq\Logseq.exe")
if (-not $LogseqInstalled) {
    Write-Host "→ [2/8] Logseq 설치..."
    winget install Logseq.Logseq --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "✓ [2/8] Logseq"
}

# ── 3. npm 패키지 ──
Write-Host "→ [3/8] MCP 패키지 설치..."
npm install -g @tobilu/qmd @modelcontextprotocol/server-filesystem logseq-mcp 2>$null | Select-Object -Last 1

# ── 4. Logseq 그래프 구조 ──
Write-Host "→ [4/8] Logseq 그래프 생성..."
@("pages", "journals", "assets", "logseq") | ForEach-Object {
    New-Item -ItemType Directory -Path "$LogseqGraph\$_" -Force | Out-Null
}

# 템플릿 복사 (존재하지 않을 때만)
$TemplateDir = Join-Path $ScriptDir "templates"
Get-ChildItem $TemplateDir | ForEach-Object {
    if ($_.Name -eq "config.edn") {
        $dest = "$LogseqGraph\logseq\config.edn"
    } else {
        $dest = "$LogseqGraph\pages\$($_.Name)"
    }
    if (-not (Test-Path $dest)) {
        Copy-Item $_.FullName $dest
        Write-Host "  + $dest"
    }
}

# ── 5. Claude Code MCP 서버 등록 ──
Write-Host "→ [5/8] Claude Code MCP 서버..."
$QmdPath = (Get-Command qmd -ErrorAction SilentlyContinue).Source
$NpmGlobal = (npm root -g).Trim()
$FsMcpPath = "$NpmGlobal\@modelcontextprotocol\server-filesystem\dist\index.js"

claude mcp remove --scope user logseq-graph 2>$null
claude mcp remove --scope user qmd 2>$null
claude mcp remove --scope user logseq 2>$null

claude mcp add --scope user logseq-graph -- node $FsMcpPath $LogseqGraph 2>$null
claude mcp add --scope user qmd -- $QmdPath mcp --root "$LogseqGraph\pages" 2>$null
claude mcp add --scope user logseq `
    -e LOGSEQ_API_URL=http://localhost:12315 `
    -e LOGSEQ_TOKEN=$LOGSEQ_TOKEN `
    -- npx logseq-mcp 2>$null

# ── 6. Claude Desktop 설정 ──
Write-Host "→ [6/8] Claude Desktop 설정..."
$DesktopConfig = "$env:APPDATA\Claude\claude_desktop_config.json"

if (Test-Path (Split-Path $DesktopConfig)) {
    $config = if (Test-Path $DesktopConfig) {
        Get-Content $DesktopConfig -Raw | ConvertFrom-Json
    } else {
        [PSCustomObject]@{}
    }

    $mcpServers = @{
        logseq = @{
            command = "npx"
            args = @("logseq-mcp")
            env = @{
                LOGSEQ_API_URL = "http://localhost:12315"
                LOGSEQ_TOKEN = $LOGSEQ_TOKEN
            }
        }
        "logseq-graph" = @{
            command = "node"
            args = @($FsMcpPath, $LogseqGraph)
        }
        qmd = @{
            command = $QmdPath
            args = @("mcp", "--root", "$LogseqGraph\pages")
        }
    }

    $config | Add-Member -NotePropertyName mcpServers -NotePropertyValue $mcpServers -Force
    $config | ConvertTo-Json -Depth 10 | Set-Content $DesktopConfig -Encoding UTF8
    Write-Host "  ✓ Claude Desktop 설정 완료"
} else {
    Write-Host "  ⚠ Claude Desktop 미설치 — 스킵"
}

# ── 7. Hook 스크립트 복사 ──
Write-Host "→ [7/9] Hook 스크립트..."
New-Item -ItemType Directory -Path $ScriptsDir -Force | Out-Null
Copy-Item "$ScriptDir\scripts\ensure-logseq.ps1" "$ScriptsDir\ensure-logseq.ps1" -Force
Copy-Item "$ScriptDir\scripts\logseq-session-start.ps1" "$ScriptsDir\logseq-session-start.ps1" -Force

# ── 8. Logseq 스킬 설치 ──
Write-Host "→ [8/9] Logseq 스킬 설치..."
$CommandsDir = "$ClaudeDir\commands\logseq"
New-Item -ItemType Directory -Path $CommandsDir -Force | Out-Null
Get-ChildItem "$ScriptDir\commands\logseq\*.md" | ForEach-Object {
    Copy-Item $_.FullName "$CommandsDir\$($_.Name)" -Force
    $skillName = $_.BaseName
    Write-Host "  + /logseq:$skillName"
}

# ── 9. CLAUDE.md & Hook 설정 ──
Write-Host "→ [9/9] CLAUDE.md & SessionStart Hook..."

# CLAUDE.md에 Logseq 섹션 추가
New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
$ClaudeMd = "$ClaudeDir\CLAUDE.md"
if (Test-Path $ClaudeMd) {
    if (-not (Select-String -Path $ClaudeMd -Pattern "Global Knowledge Graph" -Quiet)) {
        Get-Content "$ScriptDir\templates\claude-md-addon.md" | Add-Content $ClaudeMd
        Write-Host "  + CLAUDE.md Logseq 섹션 추가"
    }
}

# settings.json에 Hook 추가
$SettingsFile = "$ClaudeDir\settings.json"
if (Test-Path $SettingsFile) {
    if (-not (Select-String -Path $SettingsFile -Pattern "SessionStart" -Quiet)) {
        $settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json
        $hook = @{
            SessionStart = @(
                @{
                    hooks = @(
                        @{
                            type = "command"
                            command = "powershell -ExecutionPolicy Bypass -File `"$env:USERPROFILE\scripts\logseq-session-start.ps1`""
                            timeout = 20
                            shell = "powershell"
                            statusMessage = "Logseq 세션 컨텍스트 로딩..."
                        }
                    )
                }
            )
            Stop = @(
                @{
                    hooks = @(
                        @{
                            type = "prompt"
                            prompt = "세션이 종료됩니다. 이번 세션에서 수행한 작업을 Logseq 일지에 기록하세요.`n`n1. mcp__logseq-graph__read_file로 오늘 일지(journals/YYYY-MM-DD.md)를 읽으세요`n2. 이번 세션에서 한 작업, 결정, 변경사항을 요약하세요`n3. mcp__logseq-graph__write_file로 일지에 추가하세요 (기존 내용 유지, 새 내용 append)`n4. 미완료 태스크가 있으면 TODO로 기록하세요`n`n형식:`n- ## Session Log (HH:MM)`n  - **작업**: 수행한 내용 요약`n  - **결정**: 내린 결정들`n  - **변경 파일**: 주요 변경 파일 목록`n  - **다음 할 일**: 이어서 해야 할 작업`n  - **프로젝트**: [[project/<name>]] (프로젝트 스코프인 경우)"
                            timeout = 30
                            statusMessage = "세션 기록 저장 중..."
                        }
                    )
                }
            )
        }
        $settings | Add-Member -NotePropertyName hooks -NotePropertyValue $hook -Force
        $settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8
        Write-Host "  + SessionStart Hook 추가"
    }
}

# Logseq 시작 프로그램 등록
$StartupFolder = [System.Environment]::GetFolderPath("Startup")
$ShortcutPath = "$StartupFolder\Logseq.lnk"
if (-not (Test-Path $ShortcutPath)) {
    $LogseqExe = "$env:LOCALAPPDATA\Programs\Logseq\Logseq.exe"
    if (Test-Path $LogseqExe) {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $LogseqExe
        $Shortcut.WindowStyle = 7  # Minimized
        $Shortcut.Save()
        Write-Host "  + Logseq 시작 프로그램 등록"
    }
}

Write-Host ""
Write-Host "══════════════════════════════════════════════"
Write-Host "  ✓ 설치 완료!"
Write-Host "══════════════════════════════════════════════"
Write-Host ""
Write-Host "남은 수동 작업 (최초 1회):"
Write-Host "  1. Logseq 앱 열기 → Add graph → $LogseqGraph"
Write-Host "  2. Settings → Advanced → Developer mode ON"
Write-Host "  3. Settings → Advanced → HTTP APIs server ON"
Write-Host "  4. Settings → Advanced → API auth token:"
Write-Host "     $LOGSEQ_TOKEN"
Write-Host ""
Write-Host "확인: claude mcp list"
