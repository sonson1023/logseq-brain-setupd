# Logseq + Claude Memory Stack

3-Layer Compounding Memory Stack for Claude Code & Claude Desktop with Logseq.

Supports **macOS** and **Windows**.

## Quick Start

### macOS

```bash
git clone https://github.com/<your-username>/logseq-brain-setup.git
cd logseq-brain-setup
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/<your-username>/logseq-brain-setup.git
cd logseq-brain-setup
.\install.ps1
```

## What it does

| Step | macOS | Windows |
|------|-------|---------|
| Package Manager | Homebrew | winget |
| Logseq 설치 | `brew --cask` | `winget install` |
| npm 패키지 | `qmd`, `server-filesystem`, `logseq-mcp` | same |
| 그래프 생성 | `~/logseq-graph/` | `%USERPROFILE%\logseq-graph\` |
| Claude Code MCP | `claude mcp add --scope user` | same |
| Claude Desktop | `~/Library/.../claude_desktop_config.json` | `%APPDATA%\Claude\claude_desktop_config.json` |
| Hook | `bash ensure-logseq.sh` | `powershell ensure-logseq.ps1` |
| 자동 시작 | Login Items (osascript) | Startup 폴더 바로가기 |

## After install (1회 수동)

1. Logseq 앱 → **Add graph** → `~/logseq-graph` (또는 `%USERPROFILE%\logseq-graph`)
2. **Settings → Advanced → Developer mode** ON
3. **Settings → Advanced → HTTP APIs server** ON
4. **Settings → Advanced → API auth token** → `config.env`의 토큰 붙여넣기

## Config

`config.env`에서 토큰 변경 가능:

```env
LOGSEQ_TOKEN="your-token-here"
```

## Structure

```
logseq-brain-setup/
├── install.sh                # macOS 설치 스크립트
├── install.ps1               # Windows 설치 스크립트
├── config.env                # 설정 (토큰 등)
├── scripts/
│   ├── ensure-logseq.sh      # SessionStart hook (macOS)
│   └── ensure-logseq.ps1     # SessionStart hook (Windows)
└── templates/
    ├── config.edn            # Logseq 앱 설정
    ├── polaris___top-of-mind.md
    ├── inbox.md
    └── claude-md-addon.md    # CLAUDE.md에 추가될 내용
```

## MCP Servers

| Server | Purpose |
|--------|---------|
| `logseq` | Logseq HTTP API (검색, 블록 생성, 태스크 관리) |
| `logseq-graph` | 파일시스템 직접 read/write |
| `qmd` | 고속 하이브리드 검색 (BM25 + semantic) |
