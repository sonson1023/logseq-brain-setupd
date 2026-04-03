---
allowed-tools: [Read, Bash, mcp__logseq-graph__read_file, mcp__logseq__page, mcp__qmd__query]
description: "Read Polaris Top of Mind and evaluate current work alignment with goals"
---

# /logseq:polaris - Polaris Strategy Check

## Purpose
Read the user's Top of Mind document and evaluate how current work aligns with quarterly goals and Life Razors. Act as an accountability partner.

## Execution

1. **Read Top of Mind**
   - Use `mcp__logseq-graph__read_file` to read `pages/polaris___top-of-mind.md`
   - If not found, check via `mcp__logseq__page` with name `polaris/top-of-mind`

2. **Extract Key Elements**
   - Current quarterly goals
   - Active projects and success criteria
   - Life Razors (non-negotiable principles)
   - Tech stack & standards

3. **Evaluate Alignment**
   - If the user has described current work or task context, evaluate:
     - Does this work directly support a quarterly goal?
     - Does it conflict with any Life Razor?
     - Is it the highest-leverage task right now?
   - If no task context, summarize the current state and ask what we're working on

4. **Output Format**
   ```
   ## 🎯 Polaris Check

   ### 현재 목표
   - [분기 목표 요약]

   ### Life Razors
   - [원칙 나열]

   ### 정렬 평가
   - [현재 작업이 목표와 어떻게 연결되는지]
   - [어긋나는 부분이 있다면 경고]

   ### 제안
   - [다음 행동 제안]
   ```

## Behavior
- Be direct about misalignments — don't sugarcoat
- Reference specific goals and razors by name
- If the Top of Mind is empty/template, prompt the user to fill it in first
- 한국어로 응답
