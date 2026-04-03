---
allowed-tools: [Read, Bash, mcp__logseq-graph__read_file, mcp__logseq__page, mcp__qmd__query]
description: "Read Polaris Top of Mind and evaluate current work alignment with goals"
---

# /logseq:polaris - Polaris Strategy Check

## Project Namespace Detection
Before execution, detect the current project scope:
1. Read `.claude/CLAUDE.md` in current working directory
2. Look for `Logseq namespace: project/<name>` line
3. If found → this is a project-scoped session. Read project index too.
4. If not found → global session. Only read Polaris.

## Execution

1. **Read Top of Mind**
   - Use `mcp__logseq-graph__read_file` to read `/Users/formsdev/logseq-graph/pages/polaris___top-of-mind.md`

2. **If Project Scoped** (namespace detected)
   - Also read `/Users/formsdev/logseq-graph/pages/project___<name>.md` for project context
   - Evaluate alignment of project with quarterly goals

3. **Extract Key Elements**
   - Current quarterly goals
   - Active projects and success criteria
   - Life Razors (non-negotiable principles)
   - (If project scoped) Project-specific architecture and decisions

4. **Evaluate Alignment**
   - If the user has described current work or task context:
     - Does this work directly support a quarterly goal?
     - Does it conflict with any Life Razor?
     - (If project scoped) Is it aligned with project architecture decisions?
   - If no task context, summarize and ask what we're working on

5. **Output Format**
   ```
   ## 🎯 Polaris Check
   [프로젝트: <name> — if project scoped]

   ### 현재 목표
   - [분기 목표 요약]

   ### Life Razors
   - [원칙 나열]

   ### 프로젝트 컨텍스트 (if project scoped)
   - [프로젝트 상태 요약]

   ### 정렬 평가
   - [현재 작업이 목표와 어떻게 연결되는지]
   - [어긋나는 부분 경고]

   ### 제안
   - [다음 행동 제안]
   ```

## Behavior
- Be direct about misalignments
- If Top of Mind is template state, prompt to fill it in
- If project namespace not initialized, suggest `/logseq:init`
- 한국어로 응답
