---
allowed-tools: [Read, Write, Bash, mcp__logseq-graph__write_file, mcp__logseq-graph__read_file, mcp__logseq__page, mcp__qmd__query]
description: "Save a decision, learning, or insight as an atomic note in the knowledge graph"
---

# /logseq:save - Save Knowledge to Graph

## Project Namespace Detection
Before execution, detect the current project scope:
1. Read `.claude/CLAUDE.md` in current working directory
2. Look for `Logseq namespace: project/<name>` line
3. If found → save to `project/<name>/` namespace by default
4. If not found → save to `commonplace/` namespace

## Arguments
- `$ARGUMENTS` - Description of what to save

## Execution

1. **Determine Save Location**
   - **Project scoped** → `pages/project___<name>___<topic>.md`
   - **Global knowledge** (explicitly requested or no project) → `pages/commonplace___<topic>.md`
   - User can prefix with `global:` to force save to commonplace even in project scope

2. **Check for Existing Notes**
   - Use `mcp__qmd__query` with lex search
   - Search in both project namespace AND commonplace for duplicates
   - If related note exists, suggest updating instead

3. **Generate Atomic Note**
   ```markdown
   ---
   title: <namespace>/<topic>
   tags: <namespace-tags>, <topic-tags>
   date: <today YYYY-MM-DD>
   project: <name>  (if project scoped)
   ---

   - ## <Topic Title>
     - <Core insight or decision in 1-2 sentences>
     - **Context**: <Why this decision was made>
     - **Alternatives considered**: <What was rejected and why>
     - **Related**: [[<wikilinks>]]
     - **Project**: [[project/<name>]] (if project scoped)
   ```

4. **Save the File**
   - Use `mcp__logseq-graph__write_file`
   - Path: `/Users/formsdev/logseq-graph/pages/<namespace>___<topic>.md`

5. **Confirm** — Show saved location and wikilinks

## Examples
- `/logseq:save JWT 대신 session 방식 선택` → project scoped: `project/taxsaas/jwt-vs-session`
- `/logseq:save global: Docker multi-stage build 패턴` → always: `commonplace/docker-multi-stage`

## Behavior
- Keep notes atomic — one concept per note
- Always add `[[project/<name>]]` backlink for project notes
- 한국어로 응답
