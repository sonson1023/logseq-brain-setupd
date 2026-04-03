---
allowed-tools: [Read, Write, Bash, mcp__logseq-graph__write_file, mcp__logseq-graph__read_file, mcp__logseq__page, mcp__qmd__query]
description: "Save a decision, learning, or insight as an atomic note in the knowledge graph"
---

# /logseq:save - Save Knowledge to Graph

## Purpose
Save important decisions, resolved bugs, architecture choices, or learnings as atomic notes in the Logseq knowledge graph.

## Arguments
- `$ARGUMENTS` - Description of what to save (e.g., "auth 리팩터에서 JWT 대신 session 방식 선택한 이유")

## Execution

1. **Parse Input**
   - Extract the topic from `$ARGUMENTS`
   - Determine the best namespace:
     - `commonplace/` — general knowledge, patterns, tech decisions
     - `polaris/` — goals, strategy changes
     - `project/` — project-specific decisions

2. **Check for Existing Notes**
   - Use `mcp__qmd__query` with lex search to find related existing notes
   - If a related note exists, suggest updating it instead of creating a duplicate

3. **Generate Atomic Note**
   - Create a focused, single-concept note in Logseq block format:
   ```markdown
   ---
   title: commonplace/<topic>
   tags: <relevant-tags>
   date: <today YYYY-MM-DD>
   ---

   - ## <Topic Title>
     - <Core insight or decision in 1-2 sentences>
     - **Context**: <Why this decision was made>
     - **Alternatives considered**: <What was rejected and why>
     - **Related**: [[<wikilinks to related notes>]]
   ```

4. **Save the File**
   - Use `mcp__logseq-graph__write_file` to save to `pages/commonplace___<topic>.md`
   - Filename: lowercase, hyphens, no spaces (e.g., `commonplace___jwt-vs-session.md`)

5. **Confirm**
   - Show what was saved and where
   - Show any wikilinks to existing notes

## Behavior
- Keep notes atomic — one concept per note
- Always add `date` tag for temporal context
- Use `[[wikilinks]]` to connect to existing notes when relevant
- 한국어로 응답
