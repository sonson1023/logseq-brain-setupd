---
allowed-tools: [Read, Write, Bash, WebFetch, mcp__logseq-graph__write_file, mcp__logseq-graph__read_file, mcp__qmd__query]
description: "Ingest external content (URL, text) into the Logseq inbox for review"
---

# /logseq:ingest - Content Ingestion Pipeline

## Purpose
Ingest external content (articles, URLs, ideas, meeting notes) into the Logseq inbox as structured atomic notes ready for review.

## Arguments
- `$ARGUMENTS` - URL to ingest, or raw text/idea to capture

## Execution

1. **Detect Input Type**
   - URL (starts with http/https) → fetch and extract
   - Raw text → structure directly

2. **For URLs**
   - Use `WebFetch` to retrieve the content
   - Extract:
     - **Title**: Article/page title
     - **Key Claims**: Main arguments or points (bullet list)
     - **Frameworks**: Mental models or frameworks mentioned
     - **Action Items**: Actionable takeaways
     - **Open Questions**: Unanswered questions worth exploring
     - **Source**: Original URL and author

3. **For Raw Text/Ideas**
   - Structure the input into:
     - **Core Idea**: One-sentence summary
     - **Details**: Expanded notes
     - **Connections**: What existing knowledge this relates to

4. **Check for Related Notes**
   - Use `mcp__qmd__query` to find existing related notes
   - Add `[[wikilinks]]` to connect

5. **Generate Inbox Note**
   ```markdown
   ---
   title: inbox/<slugified-title>
   tags: inbox, <source-type>, <topic-tags>
   date: <today YYYY-MM-DD>
   source: <url-if-applicable>
   status: review
   ---

   - ## <Title>
     - **Source**: [<title>](<url>)
     - **Date Ingested**: <today>
   - ## Key Claims
     - <claim 1>
     - <claim 2>
   - ## Frameworks
     - <framework or mental model>
   - ## Action Items
     - TODO <actionable takeaway>
   - ## Open Questions
     - <question worth exploring>
   - ## Connections
     - Related: [[<existing note>]]
   ```

6. **Save to Inbox**
   - Use `mcp__logseq-graph__write_file` to save to `pages/inbox___<slug>.md`
   - Report what was saved

7. **Suggest Next Step**
   - "Logseq에서 검토 후 `commonplace/`로 이동하세요"
   - Or suggest specific namespace based on content type

## Behavior
- Keep extraction concise — focus on signal, not noise
- Always add source attribution for URLs
- Tag with content type (article, video, paper, idea, meeting)
- Use `status: review` so unreviewed items are easily queryable
- 한국어로 응답
