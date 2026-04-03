#!/bin/bash
# Claude Code SessionStart — 세션 컨텍스트 로드
# Logseq에서 이전 세션 기록 + 태스크 + Polaris 읽어서 Claude에 전달

GRAPH="$HOME/logseq-graph"
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

echo "=== LOGSEQ SESSION CONTEXT ==="
echo ""

# ── 1. Polaris Top of Mind ──
POLARIS="$GRAPH/pages/polaris___top-of-mind.md"
if [ -f "$POLARIS" ]; then
  echo "## Polaris (Top of Mind)"
  cat "$POLARIS" | grep -v "^---" | head -30
  echo ""
fi

# ── 2. 오늘 일지 (이미 있으면) ──
TODAY_JOURNAL="$GRAPH/journals/${TODAY}.md"
if [ -f "$TODAY_JOURNAL" ]; then
  echo "## Today's Journal ($TODAY)"
  cat "$TODAY_JOURNAL"
  echo ""
fi

# ── 3. 어제 일지 (이전 세션 기록) ──
YESTERDAY_JOURNAL="$GRAPH/journals/${YESTERDAY}.md"
if [ -f "$YESTERDAY_JOURNAL" ]; then
  echo "## Previous Session ($YESTERDAY)"
  cat "$YESTERDAY_JOURNAL"
  echo ""
fi

# ── 4. 가장 최근 일지 찾기 (오늘/어제 없을 때) ──
if [ ! -f "$TODAY_JOURNAL" ] && [ ! -f "$YESTERDAY_JOURNAL" ]; then
  LATEST=$(ls -t "$GRAPH/journals/"*.md 2>/dev/null | head -1)
  if [ -n "$LATEST" ]; then
    echo "## Latest Journal ($(basename "$LATEST" .md))"
    cat "$LATEST"
    echo ""
  fi
fi

# ── 5. 미완료 태스크 수집 ──
echo "## Pending Tasks"
grep -rn "TODO\|DOING\|WAITING" "$GRAPH/pages/" "$GRAPH/journals/" 2>/dev/null | \
  grep -v "\.md:.*tags:" | \
  sed 's|.*/||; s|___| / |g; s|\.md:| → |' | \
  head -20
echo ""

# ── 6. 프로젝트 감지 (현재 디렉토리) ──
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

echo "=== END CONTEXT ==="
echo ""
echo "위 컨텍스트를 바탕으로 이전 세션의 작업을 이어갈 수 있습니다."
echo "세션 종료 시 자동으로 일지가 기록됩니다."
