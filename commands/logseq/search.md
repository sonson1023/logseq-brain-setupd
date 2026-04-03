---
allowed-tools: [Read, Bash, mcp__logseq-graph__read_file, mcp__logseq-graph__search_files, mcp__logseq__query, mcp__qmd__query, mcp__qmd__get, mcp__qmd__multi_get]
description: "Search the Logseq knowledge graph using keyword and semantic search"
---

# /logseq:search - Knowledge Graph Search

## Project Namespace Detection
Before execution, detect the current project scope:
1. Read `.claude/CLAUDE.md` in current working directory
2. Look for `Logseq namespace: project/<name>` line
3. If found → search project namespace first, then global
4. If not found → search entire graph

## Arguments
- `$ARGUMENTS` - Search query
- Prefix with `project:` to search only current project
- Prefix with `global:` to search only global (polaris/, commonplace/)
- No prefix → search both (project first, then global)

## Execution

1. **Multi-Strategy Search**

   a. **If project scoped** — search project namespace first:
   ```
   mcp__qmd__query: searches=[{type:'lex', query:'project/<name> <keywords>'}], intent='<intent>'
   ```

   b. **Global search**:
   ```
   mcp__qmd__query: searches=[{type:'lex', query:'<keywords>'}], intent='<intent>'
   ```

   c. **File pattern search** (for project-scoped):
   ```
   mcp__logseq-graph__search_files: path='/Users/formsdev/logseq-graph/pages', pattern='project___<name>'
   ```

2. **Aggregate & Rank**
   - Deduplicate across methods
   - Group results:
     - 📁 **프로젝트** (`project/<name>/`) — show first if project scoped
     - 🌐 **글로벌** (`polaris/`, `commonplace/`)
     - 📅 **일지** (`journals/`)

3. **Retrieve Top Results**
   - Fetch full content of top 3-5 results

4. **Output Format**
   ```
   ## 🔍 검색: "<query>"
   [범위: project/<name> + 글로벌]

   ### 📁 프로젝트 결과
   #### <Note Title> (project/<name>/<topic>)
   > 관련 내용 발췌...

   ### 🌐 글로벌 결과
   #### <Note Title> (commonplace/<topic>)
   > 관련 내용 발췌...

   ---
   프로젝트 N개 + 글로벌 N개 결과
   ```

## Behavior
- Project results shown first when project scoped
- If no project results, still show global results
- 한국어로 응답
