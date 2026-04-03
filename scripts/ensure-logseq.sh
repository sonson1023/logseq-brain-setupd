#!/bin/bash
# Claude Code SessionStart hook
# Logseq 실행 확인 + 미실행 시 자동 시작

if ! lsof -i :12315 &>/dev/null; then
  open -a Logseq -g
  for i in {1..10}; do
    if lsof -i :12315 &>/dev/null; then
      break
    fi
    sleep 1
  done
fi

if lsof -i :12315 &>/dev/null; then
  echo "Logseq API: Connected (port 12315)"
else
  echo "Logseq API: Not ready"
fi
