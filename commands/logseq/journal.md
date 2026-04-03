---
allowed-tools: [Read, Write, Bash, mcp__logseq-graph__write_file, mcp__logseq-graph__read_file, mcp__logseq__page, mcp__logseq__tasks]
description: "Create or update today's Logseq daily journal with work logs, decisions, and tasks"
---

# /logseq:journal - Daily Journal Management

## Purpose
Create or update today's Logseq daily journal entry with work summaries, decisions made, and task tracking.

## Arguments
- `$ARGUMENTS` - (optional) Content to add to today's journal
  - If empty: show today's journal or create a new one
  - If provided: append the content to today's journal

## Execution

1. **Determine Today's Date**
   - Format: `YYYY-MM-DD` (e.g., `2026-04-03`)
   - Journal filename: `journals/2026-04-03.md`

2. **Read or Create Journal**
   - Try `mcp__logseq-graph__read_file` for `journals/<today>.md`
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
   - Parse the content type:
     - Starts with "TODO" or "할일" → add to Tasks section
     - Starts with "결정" or "decision" → add to Decisions section
     - Starts with "내일" or "tomorrow" → add to Tomorrow section
     - Otherwise → add to Notes section
   - Append to the appropriate section using `mcp__logseq-graph__write_file`

4. **Show Current State**
   - Display today's journal contents
   - Show task count (TODO/DOING/DONE)

## Behavior
- Never overwrite existing journal content — always append
- Use Logseq block format (bullet points with indentation)
- Add timestamps to entries when relevant
- Link to relevant pages with `[[wikilinks]]` when context is clear
- 한국어로 응답
