#!/bin/bash
# Claude Code SessionStart — 세션 ���텍스트 로드 + 첫 실행 감지
# Logseq에서 이전 세션 기록 + 태���크 + Polaris 읽어서 Claude에 전달

GRAPH="$HOME/logseq-graph"
CONFIG="$GRAPH/logseq/brain-config.json"
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)

# ── Logseq 실행 확인 ──
if ! lsof -i :12315 &>/dev/null; then
  open -a Logseq -g 2>/dev/null || true
  for i in {1..10}; do
    lsof -i :12315 &>/dev/null && break
    sleep 1
  done
fi

# ── 첫 실행 감지 ──
if [ ! -f "$CONFIG" ]; then
  echo "=== LOGSEQ BRAIN: 첫 실행 감지 ==="
  echo ""
  echo "Logseq Memory Stack이 아직 설정되지 않았습니다."
  echo "/logseq:config 를 실행하여 메모리 모드 등을 설정하세요."
  echo "(설정 없이도 기본값(logseq 모드)으로 동작합니다)"
  echo ""
fi

# ── 설정 읽기 ──
MEMORY_MODE="logseq"
POLARIS_CHECK="true"
if [ -f "$CONFIG" ]; then
  MEMORY_MODE=$(python3 -c "import json; print(json.load(open('$CONFIG')).get('memory_mode','logseq'))" 2>/dev/null || echo "logseq")
  POLARIS_CHECK=$(python3 -c "import json; print(json.load(open('$CONFIG')).get('polaris_check','true'))" 2>/dev/null || echo "true")
fi

echo "=== LOGSEQ SESSION CONTEXT ==="
echo "메모리 모드: $MEMORY_MODE"
echo ""

# ── 1. Polaris Top of Mind ──
if [ "$POLARIS_CHECK" = "true" ]; then
  POLARIS="$GRAPH/pages/polaris___top-of-mind.md"
  if [ -f "$POLARIS" ]; then
    echo "## Polaris (Top of Mind)"
    cat "$POLARIS" | grep -v "^---" | head -30
    echo ""
  fi
fi

# ── 2. 오늘 일지 ──
TODAY_JOURNAL="$GRAPH/journals/${TODAY}.md"
if [ -f "$TODAY_JOURNAL" ]; then
  echo "## Today's Journal ($TODAY)"
  cat "$TODAY_JOURNAL"
  echo ""
fi

# ── 3. 이전 일지 ──
YESTERDAY_JOURNAL="$GRAPH/journals/${YESTERDAY}.md"
if [ -f "$YESTERDAY_JOURNAL" ]; then
  echo "## Previous Session ($YESTERDAY)"
  cat "$YESTERDAY_JOURNAL"
  echo ""
elif [ ! -f "$TODAY_JOURNAL" ]; then
  LATEST=$(ls -t "$GRAPH/journals/"*.md 2>/dev/null | head -1)
  if [ -n "$LATEST" ]; then
    echo "## Latest Journal ($(basename "$LATEST" .md))"
    cat "$LATEST"
    echo ""
  fi
fi

# ── 4. 미완료 태스크 ──
echo "## Pending Tasks"
grep -rn "TODO\|DOING\|WAITING" "$GRAPH/pages/" "$GRAPH/journals/" 2>/dev/null | \
  grep -v "\.md:.*tags:" | grep -v "brain-config" | \
  sed 's|.*/||; s|___| / |g; s|\.md:| → |' | \
  head -20
echo ""

# ── 5. 프로젝트 감지 ──
if [ -f ".claude/CLAUDE.md" ]; then
  NS=$(grep -o 'Logseq namespace: project/[^ ]*' .claude/CLAUDE.md 2>/dev/null | head -1)
  if [ -n "$NS" ]; then
    PROJECT_NAME=$(echo "$NS" | sed 's/Logseq namespace: project\///')
    echo "## Current Project: $PROJECT_NAME"
    PROJECT_PAGE="$GRAPH/pages/project___${PROJECT_NAME}.md"
    if [ -f "$PROJECT_PAGE" ]; then
      cat "$PROJECT_PAGE" | grep -v "^---" | head -20
    fi
    echo ""
  fi
fi

# ── 6. Claude 메모리 (both 모드) ──
if [ "$MEMORY_MODE" = "both" ] || [ "$MEMORY_MODE" = "claude" ]; then
  echo "## Claude Memory"
  MEMORY_DIR="$HOME/.claude/projects"
  if [ -d "$MEMORY_DIR" ]; then
    LATEST_MEMORY=$(find "$MEMORY_DIR" -name "MEMORY.md" -type f 2>/dev/null | head -1)
    if [ -n "$LATEST_MEMORY" ]; then
      head -30 "$LATEST_MEMORY"
    fi
  fi
  echo ""
fi

echo "=== END CONTEXT ==="
echo ""
echo "이전 세션의 작업을 이어갈 수 있습니다. 세션 종료 시 자동으��� 일지가 기록됩니다."
