---
allowed-tools: [Read, Write, Bash, mcp__logseq-graph__write_file, mcp__logseq-graph__read_file]
description: "Initialize Logseq namespace for the current project"
---

# /logseq:init - Project Logseq Setup

## Purpose
Initialize a Logseq namespace for the current project so all notes are scoped and isolated.

## Arguments
- `$ARGUMENTS` - (optional) Project name override. If empty, derive from current directory name.

## Execution

1. **Detect Project Name**
   - If `$ARGUMENTS` provided, use it as project name
   - Otherwise, derive from `basename $PWD` (e.g., `taxsaas-app`)
   - Slugify: lowercase, hyphens only (e.g., `taxsaas-app`)

2. **Create Logseq Namespace Pages**
   Use `mcp__logseq-graph__write_file` to create (skip if exists):

   a. **Project index page**: `pages/project___<name>.md`
   ```markdown
   ---
   title: project/<name>
   tags: project, <name>
   date: <today>
   ---

   - ## Project: <name>
     - **경로**: <current working directory>
     - **생성일**: <today>
   - ## Architecture
     - (작성 필요)
   - ## Decisions
     - 
   - ## Active Tasks
     - 
   ```

   b. **Project decisions page**: `pages/project___<name>___decisions.md`
   ```markdown
   ---
   title: project/<name>/decisions
   tags: project, <name>, decisions
   ---

   - ## Decisions Log
     - 
   ```

3. **Create Project CLAUDE.md Entry**
   - Check if `.claude/CLAUDE.md` exists in current project directory
   - If exists, append Logseq section (if not already present)
   - If not exists, create it with Logseq namespace config:

   ```markdown
   # Logseq Integration

   ## Project Namespace
   - **Logseq namespace**: project/<name>
   - 이 프로젝트 관련 노트는 `project___<name>___` 네임스페이스에 저장
   - 글로벌 지식 (`polaris/`, `commonplace/`)은 읽기 가능

   ## 사용 가능한 커맨드
   - `/logseq:save <내용>` — 프로젝트 결정/학습 저장
   - `/logseq:search <검색어>` — 프로젝트 + 글로벌 검색
   - `/logseq:journal <내용>` — 오늘 일지에 기록
   - `/logseq:polaris` — 목표 정렬 체크
   ```

4. **Confirm**
   - Show created namespace and files
   - Show available commands

## Behavior
- Never overwrite existing files
- 한국어로 응답
