# Logseq + Claude Memory Stack

3-Layer Compounding Memory Stack for Claude Code & Claude Desktop with Logseq.

## Quick Start

```bash
git clone https://github.com/<your-username>/logseq-brain-setup.git
cd logseq-brain-setup
bash install.sh
```

## What it does

| Step | Action |
|------|--------|
| 1 | Homebrew / Node.js 확인 & 설치 |
| 2 | Logseq 앱 설치 (`brew --cask`) |
| 3 | MCP npm 패키지 설치 (`qmd`, `server-filesystem`, `logseq-mcp`) |
| 4 | `~/logseq-graph/` 그래프 구조 생성 |
| 5 | Claude Code MCP 서버 등록 (user scope) |
| 6 | Claude Desktop MCP 설정 |
| 7 | SessionStart Hook (Logseq 자동 실행) |
| 8 | macOS 로그인 시 Logseq 자동 시작 |

## After install (1회 수동)

1. Logseq 앱 → **Add graph** → `~/logseq-graph`
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
├── install.sh              # 메인 설치 스크립트
├── config.env              # 설정 (토큰 등)
├── scripts/
│   └── ensure-logseq.sh    # SessionStart hook
└── templates/
    ├── config.edn          # Logseq 앱 설정
    ├── polaris___top-of-mind.md
    ├── inbox.md
    └── claude-md-addon.md  # CLAUDE.md에 추가될 내용
```

## MCP Servers

| Server | Purpose |
|--------|---------|
| `logseq` | Logseq HTTP API (검색, 블록 생성, 태스크 관리) |
| `logseq-graph` | 파일시스템 직접 read/write |
| `qmd` | 고속 하이브리드 검색 (BM25 + semantic) |
