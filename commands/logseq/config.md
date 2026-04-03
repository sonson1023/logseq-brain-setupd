---
allowed-tools: [Read, Write, Bash, AskUserQuestion, mcp__logseq-graph__read_file, mcp__logseq-graph__write_file]
description: "Configure Logseq memory settings (memory mode, project namespace, preferences)"
---

# /logseq:config - Logseq Configuration

## Purpose
Interactive configuration for Logseq memory system. Allows users to choose memory mode, set project namespace, and configure preferences.

## Execution

1. **Read Current Config**
   - Check if `~/logseq-graph/logseq/brain-config.json` exists
   - If exists, load current settings
   - If not, use defaults

2. **Ask User Preferences** (using AskUserQuestion)

   a. **Memory Mode**
   - `logseq` — Logseq 파일에만 저장 (기본값, 추천)
   - `claude` — Claude 메모리(MEMORY.md)에만 저장
   - `both` — 둘 다 저장

   b. **Language**
   - `ko` — 한국어 (기본값)
   - `en` — English

   c. **Auto Journal**
   - `true` — 세션 종료 시 자동 일지 기록 (기본값)
   - `false` — 수동으로만 기록

   d. **Polaris Check**
   - `true` — 세션 시작 시 목표 정렬 체크 표시 (기본값)
   - `false` — 컨텍스트만 조용히 로드

3. **Save Config**
   Save to `~/logseq-graph/logseq/brain-config.json`:
   ```json
   {
     "memory_mode": "logseq",
     "language": "ko",
     "auto_journal": true,
     "polaris_check": true,
     "initialized": true,
     "initialized_at": "2026-04-03"
   }
   ```
   Use `mcp__logseq-graph__write_file` to save.

4. **Update CLAUDE.md Addon** (if memory_mode changed)
   - If `both` or `claude`: append instruction to also save to `~/.claude/projects/*/memory/MEMORY.md`
   - If `logseq` only: ensure CLAUDE.md only references Logseq

5. **Confirm**
   ```
   ## ✅ 설정 완료

   | 항목 | 값 |
   |------|-----|
   | 메모리 모드 | logseq / claude / both |
   | 언어 | ko / en |
   | 자동 일지 | ON / OFF |
   | Polaris 체크 | ON / OFF |

   설정 파일: ~/logseq-graph/logseq/brain-config.json
   변경하려면: /logseq:config
   ```

## First Run Detection
- If `brain-config.json` doesn't exist, this is the first run
- SessionStart hook will detect this and suggest running `/logseq:config`
- All settings have sensible defaults, so skipping config also works

## Behavior
- 한국어로 응답 (unless language is set to en)
- Show current values when reconfiguring
- Never lose existing config — merge updates
