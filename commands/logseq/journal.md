---
allowed-tools: [Read, Write, Bash, mcp__logseq-graph__write_file, mcp__logseq-graph__read_file, mcp__logseq__page, mcp__logseq__tasks]
description: "Create or update today's Logseq daily journal with work logs, decisions, and tasks"
---

# /logseq:journal - Daily Journal Management

## Project Namespace Detection
Before execution, detect the current project scope:
1. Read `.claude/CLAUDE.md` in current working directory
2. Look for `Logseq namespace: project/<name>` line
3. If found → tag journal entries with project name

## Arguments
- `$ARGUMENTS` - (optional) Content to add to today's journal

## Execution

1. **Determine Today's Date**
   - Format: `YYYY-MM-DD` (e.g., `2026-04-03`)
   - Journal path: `/Users/formsdev/logseq-graph/journals/<today>.md`

2. **Read or Create Journal**
   - Try `mcp__logseq-graph__read_file` for journal file
   - If not exists, create with template:
   ```markdown
   - ## Daily Log
     - 
   - ## Decisions Made
     - 
   - ## Tasks
     - TODO 
   - ## Notes
     - 
   - ## Tomorrow
     - 
   ```

3. **If Arguments Provided**
   - **Project scoped**: prefix entry with `[[project/<name>]]` tag
   ```
   - [[project/taxsaas]] JWT 인증 방식을 session으로 변경 결정
   ```
   - **Global**: no prefix
   - Parse content type:
     - "TODO" / "할일" → Tasks section
     - "결정" / "decision" → Decisions section
     - "내일" / "tomorrow" → Tomorrow section
     - Otherwise → Notes section
   - Append to appropriate section

4. **Show Current State**
   - Display today's journal
   - If project scoped, highlight entries for current project

## Behavior
- Never overwrite existing journal content — always append
- Project tags (`[[project/<name>]]`) make journal entries filterable in Logseq
- 한국어로 응답
