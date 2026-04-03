---
allowed-tools: [Read, Bash, mcp__logseq-graph__read_file, mcp__logseq-graph__search_files, mcp__logseq__query, mcp__qmd__query, mcp__qmd__get, mcp__qmd__multi_get]
description: "Search the Logseq knowledge graph using keyword and semantic search"
---

# /logseq:search - Knowledge Graph Search

## Purpose
Search across the entire Logseq knowledge graph to find notes, decisions, code snippets, and past learnings.

## Arguments
- `$ARGUMENTS` - Search query (e.g., "Docker Compose 설정", "인증 패턴", "Q1 회고")

## Execution

1. **Multi-Strategy Search**
   Run parallel searches for best coverage:

   a. **Keyword Search (QMD lex)**
      ```
      mcp__qmd__query: searches=[{type:'lex', query:'<extracted keywords>'}], intent='<user intent>'
      ```

   b. **Semantic Search (QMD vec)** — if embeddings available
      ```
      mcp__qmd__query: searches=[{type:'vec', query:'<natural language query>'}], intent='<user intent>'
      ```

   c. **File Search (logseq-graph)** — for filename patterns
      ```
      mcp__logseq-graph__search_files: path='pages', pattern='<keyword>'
      ```

2. **Aggregate & Rank Results**
   - Deduplicate across search methods
   - Prioritize by relevance score (minScore: 0.3)
   - Group by namespace (polaris/, commonplace/, project/, journals/)

3. **Retrieve Top Results**
   - Use `mcp__qmd__get` or `mcp__logseq-graph__read_file` to fetch full content of top 3-5 results

4. **Output Format**
   ```
   ## 🔍 검색 결과: "<query>"

   ### 📄 <Note Title 1> (commonplace/topic)
   > 관련 내용 발췌...

   ### 📄 <Note Title 2> (journals/2026-03-15)
   > 관련 내용 발췌...

   ---
   총 N개 결과 | 검색 방법: lex + vec
   ```

## Behavior
- If no results found, suggest alternative search terms
- Show the source file path so user can open it in Logseq
- Highlight the most relevant snippet from each result
- 한국어로 응답
