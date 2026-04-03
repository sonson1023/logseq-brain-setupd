#!/bin/bash
set -e

# ─────────────────────────────────────────────────
# Logseq + Claude Memory Stack — One-Line Installer
#
# 사용법:
#   git clone https://github.com/<you>/logseq-brain-setup.git
#   cd logseq-brain-setup
#   bash install.sh
# ─────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOGSEQ_GRAPH="$HOME/logseq-graph"
CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$HOME/scripts"

# ── 설정 로드 ──
if [ -f "$SCRIPT_DIR/config.env" ]; then
  source "$SCRIPT_DIR/config.env"
else
  echo "⚠ config.env 없음 — 기본값 사용"
  LOGSEQ_TOKEN="$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')"
  echo "새 토큰 생성됨: $LOGSEQ_TOKEN"
fi

echo ""
echo "══════════════════════════════════════════════"
echo "  Logseq + Claude Memory Stack Installer"
echo "══════════════════════════════════════════════"
echo ""

# ── 1. Homebrew ──
if ! command -v brew &>/dev/null; then
  echo "→ [1/8] Homebrew 설치..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "✓ [1/8] Homebrew"
fi

# ── 2. Node.js ──
if ! command -v node &>/dev/null; then
  echo "→ [2/8] Node.js 설치..."
  brew install node
else
  echo "✓ [2/8] Node.js $(node -v)"
fi

# ── 3. Logseq 앱 ──
if [ ! -d "/Applications/Logseq.app" ]; then
  echo "→ [3/8] Logseq 앱 설치..."
  brew install --cask logseq
else
  echo "✓ [3/8] Logseq 앱"
fi

# ── 4. npm 패키지 ──
echo "→ [4/8] MCP 패키지 설치..."
npm install -g @tobilu/qmd @modelcontextprotocol/server-filesystem logseq-mcp 2>&1 | tail -1

# ── 5. Logseq 그래프 구조 ──
echo "→ [5/8] Logseq 그래프 생성..."
mkdir -p "$LOGSEQ_GRAPH"/{pages,journals,assets,logseq}

# 템플릿 파일 복사 (존재하지 않을 때만)
for tmpl in "$SCRIPT_DIR"/templates/*; do
  filename="$(basename "$tmpl")"
  if [ "$filename" = "config.edn" ]; then
    dest="$LOGSEQ_GRAPH/logseq/config.edn"
  else
    dest="$LOGSEQ_GRAPH/pages/$filename"
  fi
  if [ ! -f "$dest" ]; then
    cp "$tmpl" "$dest"
    echo "  + $dest"
  fi
done

# ── 6. Claude Code MCP 서버 등록 ──
echo "→ [6/8] Claude Code MCP 서버..."
QMD_PATH=$(which qmd)
FS_MCP_PATH=$(npm root -g)/@modelcontextprotocol/server-filesystem/dist/index.js

claude mcp remove --scope user logseq-graph 2>/dev/null || true
claude mcp remove --scope user qmd 2>/dev/null || true
claude mcp remove --scope user logseq 2>/dev/null || true

claude mcp add --scope user logseq-graph -- node "$FS_MCP_PATH" "$LOGSEQ_GRAPH" 2>/dev/null
claude mcp add --scope user qmd -- "$QMD_PATH" mcp --root "$LOGSEQ_GRAPH/pages" 2>/dev/null
claude mcp add --scope user logseq \
  -e LOGSEQ_API_URL=http://localhost:12315 \
  -e LOGSEQ_TOKEN="$LOGSEQ_TOKEN" \
  -- npx logseq-mcp 2>/dev/null

# ── 7. Claude Desktop 설정 ──
echo "→ [7/8] Claude Desktop 설정..."
DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

if [ -d "$(dirname "$DESKTOP_CONFIG")" ]; then
  python3 << EOFPY
import json, os

config_path = os.path.expanduser('~/Library/Application Support/Claude/claude_desktop_config.json')

if os.path.exists(config_path):
    with open(config_path, 'r') as f:
        config = json.load(f)
else:
    config = {}

config['mcpServers'] = {
    'logseq': {
        'command': 'npx',
        'args': ['logseq-mcp'],
        'env': {
            'LOGSEQ_API_URL': 'http://localhost:12315',
            'LOGSEQ_TOKEN': '${LOGSEQ_TOKEN}'
        }
    },
    'logseq-graph': {
        'command': 'node',
        'args': ['${FS_MCP_PATH}', '${LOGSEQ_GRAPH}']
    },
    'qmd': {
        'command': '${QMD_PATH}',
        'args': ['mcp', '--root', '${LOGSEQ_GRAPH}/pages']
    }
}

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print('  ✓ Claude Desktop 설정 완료')
EOFPY
else
  echo "  ⚠ Claude Desktop 미설치 — 스킵"
fi

# ── 8. Hook & 자동 실행 ──
echo "→ [8/8] Hook & 자동 실행 설정..."

# ensure-logseq.sh 복사
mkdir -p "$SCRIPTS_DIR"
cp "$SCRIPT_DIR/scripts/ensure-logseq.sh" "$SCRIPTS_DIR/ensure-logseq.sh"
chmod +x "$SCRIPTS_DIR/ensure-logseq.sh"

# CLAUDE.md에 Logseq 섹션 추가 (없을 때만)
mkdir -p "$CLAUDE_DIR"
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  if ! grep -q "Global Knowledge Graph" "$CLAUDE_DIR/CLAUDE.md"; then
    cat "$SCRIPT_DIR/templates/claude-md-addon.md" >> "$CLAUDE_DIR/CLAUDE.md"
    echo "  + CLAUDE.md Logseq 섹션 추가"
  fi
fi

# settings.json에 SessionStart hook 추가 (없을 때만)
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  if ! grep -q "SessionStart" "$CLAUDE_DIR/settings.json"; then
    python3 << EOFHOOK
import json
with open('$CLAUDE_DIR/settings.json', 'r') as f:
    s = json.load(f)
s['hooks'] = {
    'SessionStart': [{
        'hooks': [{
            'type': 'command',
            'command': 'bash ~/scripts/ensure-logseq.sh',
            'timeout': 15,
            'statusMessage': 'Logseq 연결 확인 중...'
        }]
    }]
}
with open('$CLAUDE_DIR/settings.json', 'w') as f:
    json.dump(s, f, indent=2)
EOFHOOK
    echo "  + SessionStart Hook 추가"
  fi
fi

# macOS 로그인 시 Logseq 자동 실행
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Logseq.app", hidden:true}' 2>/dev/null || true

echo ""
echo "══════════════════════════════════════════════"
echo "  ✓ 설치 완료!"
echo "══════════════════════════════════════════════"
echo ""
echo "남은 수동 작업 (최초 1회):"
echo "  1. Logseq 앱 열기 → Add graph → ~/logseq-graph"
echo "  2. Settings → Advanced → Developer mode ON"
echo "  3. Settings → Advanced → HTTP APIs server ON"
echo "  4. Settings → Advanced → API auth token:"
echo "     $LOGSEQ_TOKEN"
echo ""
echo "확인: claude mcp list"
