---
allowed-tools: [Read, Write, Bash, WebFetch, mcp__logseq-graph__write_file, mcp__logseq-graph__read_file, mcp__qmd__query]
description: "Ingest external content (URL, text) into the Logseq inbox for review"
---

# /logseq:ingest - Content Ingestion Pipeline

## Project Namespace Detection
Before execution, detect the current project scope:
1. Read `.claude/CLAUDE.md` in current working directory
2. Look for `Logseq namespace: project/<name>` line
3. If found → tag ingested content with project and save to project inbox
4. If not found → save to global inbox

## Arguments
- `$ARGUMENTS` - URL to ingest, or raw text/idea to capture

## Execution

1. **Detect Input Type**
   - URL (http/https) → fetch and extract
   - Raw text → structure directly

2. **For URLs**
   - Use `WebFetch` to retrieve content
   - Extract: Title, Key Claims, Frameworks, Action Items, Open Questions, Source

3. **For Raw Text/Ideas**
   - Structure: Core Idea, Details, Connections

4. **Check for Related Notes**
   - Use `mcp__qmd__query` to find related notes
   - If project scoped, search project namespace first
   - Add `[[wikilinks]]`

5. **Generate Note**
   - **Project scoped** → save to `pages/project___<name>___inbox___<slug>.md`
   ```markdown
   ---
   title: project/<name>/inbox/<slug>
   tags: inbox, <name>, <topic-tags>
   date: <today>
   source: <url>
   status: review
   project: <name>
   ---

   - ## <Title>
     - **Project**: [[project/<name>]]
     - **Source**: [<title>](<url>)
   - ## Key Claims
     - ...
   - ## Action Items
     - TODO ...
   - ## Connections
     - [[project/<name>/decisions]] 관련 가능
   ```

   - **Global** → save to `pages/inbox___<slug>.md` (existing behavior)

6. **Suggest Next Step**
   - Project: "검토 후 `project/<name>/`의 적절한 페이지로 이동하세요"
   - Global: "검토 후 `commonplace/`로 이동하세요"

## Behavior
- Always add project backlink for project-scoped ingestion
- Tag with `status: review` for easy filtering
- 한국어로 응답
