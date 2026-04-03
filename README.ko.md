# Logseq + Claude 메모리 스택

> Claude를 세션이 바뀌어도 **모든 것을 기억하는 시니어 동료**로 만들어줍니다.

**세션 간 기억 연속성** 시스템 — 프로젝트 DNA, 개인 지식 그래프, 세션 히스토리를 하나의 검색 가능한 두뇌로 연결합니다.

[Logseq](https://logseq.com) + [Claude](https://claude.ai) 기반. **macOS와 Windows 지원.**

---

## 문제

Claude 세션이 바뀔 때마다 모든 것을 잊어버립니다 — 어제 내린 아키텍처 결정, 지난밤 고친 버그, 합의한 네이밍 규칙. 세션마다 **30-40분을 컨텍스트 재설명**에 낭비합니다.

## 해결

한 번 설치하면, 이후 모든 세션에서:

```
┌─ 세션 시작 ──────────────────────────────────────┐
│  ✓ Logseq 자동 실행                               │
│  ✓ 이전 세션 일지 로드                             │
│  ✓ 미완료 태스크 로드                              │
│  ✓ Polaris 목표 & 원칙 로드                        │
│  ✓ 현재 프로젝트 컨텍스트 감지                      │
│  → Claude가 전체 컨텍스트를 가지고 시작              │
├─ 작업 중 ────────────────────────────────────────┤
│  ✓ /logseq:save — 결정 & 학습 영구 저장            │
│  ✓ /logseq:search — 과거 지식 검색                 │
│  ✓ 프로젝트별 격리                                 │
├─ 세션 종료 ──────────────────────────────────────┤
│  ✓ 작업 요약 자동 저장                             │
│  ✓ 결정 사항 기록                                  │
│  ✓ 미완료 태스크 캡처                              │
│  → 다음 세션이 정확히 여기서 이어감                  │
└──────────────────────────────────────────────────┘
```

---

## 빠른 시작

### macOS

```bash
git clone https://github.com/sonson1023/logseq-brain-setupd.git
cd logseq-brain-setupd
bash install.sh
```

### Windows (PowerShell)

```powershell
git clone https://github.com/sonson1023/logseq-brain-setupd.git
cd logseq-brain-setupd
.\install.ps1
```

### 설치 후 수동 설정 (최초 1회)

1. **Logseq** 앱 열기 → **Add a graph** → `~/logseq-graph` 선택
2. **Settings** → **Advanced** → **Developer mode** → ON
3. **Settings** → **Advanced** → **HTTP APIs server** → ON
4. **Settings** → **Advanced** → **Authorization tokens** → `config.env`의 토큰 붙여넣기

### 첫 세션

설치 후 첫 Claude Code 세션에서:

```
/logseq:config
```

메모리 모드와 환경설정을 선택하세요. 건너뛰어도 기본값으로 자동 동작합니다.

---

## 세션 기억 연속성 작동 원리

### 메모리 아키텍처

```
                    ┌──────────────┐
                    │  Logseq 앱   │ ← 사람이 직접 열람/편집 가능
                    │  (그래프 UI)  │
                    └──────┬───────┘
                           │
┌─────────────┐    ┌──────┴───────┐    ┌──────────────┐
│ Claude Code │◄──►│~/logseq-graph│◄──►│Claude Desktop│
│  (MCP x3)   │    │   (파일)     │    │   (MCP x3)   │
└──────┬──────┘    └──────────────┘    └──────────────┘
       │
       ▼
┌──────────────┐
│  MEMORY.md   │ ← 선택사항 (both 모드)
│ (Claude 메모리)│
└──────────────┘
```

### 세션 라이프사이클

| 이벤트 | 동작 | 저장 위치 |
|--------|------|----------|
| **세션 시작** | Hook이 이전 일지 + 태스크 + Polaris + 프로젝트 컨텍스트 로드 | → Claude 컨텍스트 |
| **작업 중** | `/logseq:save`로 결정 저장, `/logseq:search`로 과거 지식 검색 | → Logseq pages |
| **세션 종료** | Stop Hook이 작업 요약, 결정, 미완료 태스크 자동 저장 | → Logseq 일지 |
| **다음 세션** | Start Hook이 위 내용을 읽음 | → 완전한 연속성 |

### 메모리 모드

`/logseq:config`로 설정:

| 모드 | 단기 기억 | 장기 기억 | 적합한 경우 |
|------|----------|----------|------------|
| `logseq` (기본) | Logseq 일지 | Logseq pages | 검색 + 시각화가 필요한 경우 |
| `claude` | MEMORY.md | MEMORY.md | 최소 설정, Logseq 의존 없이 |
| `both` | 둘 다 | 둘 다 | 최대 안정성 & 유연성 |

### MEMORY.md만으로 부족한 이유

| | MEMORY.md | Logseq |
|---|-----------|--------|
| 용량 | ~200줄 (초과 시 잘림) | 무제한 |
| 검색 | 전체 로드만 | BM25 + 시맨틱 검색 |
| 구조 | 단일 텍스트 파일 | 네임스페이스 + 그래프 연결 |
| 히스토리 | 최신 상태만 | 시간순 일지 축적 |
| 사람 접근 | 탐색 어려움 | 앱에서 그래프 뷰 |

**MEMORY.md** = 빠른 포스트잇. **Logseq** = 장기 두뇌.

---

## 설치 스크립트가 하는 일

| # | 작업 | macOS | Windows |
|---|------|-------|---------|
| 1 | 패키지 매니저 | Homebrew | winget |
| 2 | Node.js | `brew install node` | `winget install OpenJS.NodeJS.LTS` |
| 3 | Logseq 앱 | `brew install --cask logseq` | `winget install Logseq.Logseq` |
| 4 | MCP npm 패키지 | `qmd`, `server-filesystem`, `logseq-mcp` | 동일 |
| 5 | 그래프 구조 | `~/logseq-graph/` | `%USERPROFILE%\logseq-graph\` |
| 6 | Claude Code MCP | `claude mcp add --scope user` (3개 서버) | 동일 |
| 7 | Claude Desktop MCP | `claude_desktop_config.json` | 동일 |
| 8 | 스킬 | 7개 슬래시 커맨드 → `~/.claude/commands/logseq/` | 동일 |
| 9 | Hook | SessionStart (컨텍스트 로드) + Stop (일지 저장) | 동일 |
| 10 | 자동 시작 | Login Items | 시작 프로그램 폴더 |

---

## 스킬 (슬래시 커맨드)

7개 커맨드가 `~/.claude/commands/logseq/`에 글로벌 설치:

| 커맨드 | 설명 |
|--------|------|
| `/logseq:config` | 메모리 모드, 언어, 환경설정 |
| `/logseq:init` | 프로젝트 네임스페이스 초기화 (프로젝트당 1회) |
| `/logseq:polaris` | Top of Mind와 목표 정렬 체크 |
| `/logseq:save` | 결정/학습을 atomic note로 저장 |
| `/logseq:search` | 지식 그래프 검색 (키워드 + 시맨틱) |
| `/logseq:journal` | 오늘 일지 작성/업데이트 |
| `/logseq:ingest` | URL/텍스트를 inbox에 구조화 저장 |

---

## 프로젝트 격리

각 프로젝트는 그래프 내 고유 네임스페이스를 갖습니다. 프로젝트 간 노트가 섞이지 않습니다.

### 설정

```bash
cd ~/my-project
/logseq:init my-project
```

### 작동 방식

```
~/logseq-graph/pages/
├── polaris___top-of-mind.md              ← 글로벌 (공유)
├── commonplace___docker-patterns.md      ← 글로벌 지식
├── project___my-project___decisions.md   ← 프로젝트 전용
└── project___other-project___decisions.md ← 다른 프로젝트
```

| 범위 | 읽기 | 쓰기 |
|------|------|------|
| 글로벌 (`polaris/`, `commonplace/`) | 모든 프로젝트 | `global:` 접두사로만 |
| 프로젝트 (`project/<name>/`) | 현재 프로젝트만 | 기본 저장 위치 |

---

## MCP 서버

3개 서버가 글로벌(`--scope user`)로 등록:

| 서버 | 타입 | 용도 |
|------|------|------|
| `logseq` | HTTP API | 검색, 블록, 태스크, 그래프 쿼리 |
| `logseq-graph` | 파일시스템 | 파일 직접 read/write |
| `qmd` | 검색 엔진 | BM25 키워드 + 시맨틱 검색 |

```bash
claude mcp list  # 연결 확인
```

---

## 자동화

### SessionStart Hook
1. Logseq 미실행 시 자동 시작
2. 이전 세션 일지 로드
3. 미완료 태스크 로드
4. Polaris 목표 로드
5. 현재 프로젝트 네임스페이스 감지
6. 첫 실행 감지 → `/logseq:config` 안내

### Stop Hook
1. 이번 세션 작업 요약
2. 결정 사항 기록
3. 미완료 태스크 TODO로 캡처
4. 오늘 일지에 저장
5. 프로젝트 태그 자동 추가

### 로그인 시 자동 시작
- **macOS**: Login Item (숨김)
- **Windows**: 시작 프로그램 폴더 (최소화)

---

## 레포 구조

```
logseq-brain-setupd/
├── install.sh                    # macOS 설치
├── install.ps1                   # Windows 설치
├── config.env                    # 토큰 & 설정
├── commands/logseq/              # 스킬 (→ ~/.claude/commands/logseq/)
│   ├── config.md
│   ├── init.md
│   ├── polaris.md
│   ├── save.md
│   ├── search.md
│   ├── journal.md
│   └── ingest.md
├── scripts/
│   ├── logseq-session-start.sh   # SessionStart hook (macOS)
│   ├── logseq-session-start.ps1  # SessionStart hook (Windows)
│   ├── ensure-logseq.sh
│   └── ensure-logseq.ps1
└── templates/
    ├── config.edn
    ├── polaris___top-of-mind.md
    ├── inbox.md
    └── claude-md-addon.md
```

---

## 멱등성

설치 스크립트는 여러 번 실행해도 안전:
- 이미 설치된 도구 스킵
- 기존 파일 덮어쓰지 않음
- MCP 서버 제거 후 재등록
- 스킬은 항상 최신으로 복사
- Hook은 미존재 시에만 추가

---

## 문제 해결

| 증상 | 원인 | 해결 |
|------|------|------|
| `logseq` MCP: Failed | Logseq 미실행 또는 API 비활성화 | Logseq 열고 HTTP API 활성화 |
| 401 Unauthorized | 토큰 불일치 | `config.env`와 Logseq 설정 토큰 확인 |
| 포트 12315 미응답 | HTTP 서버 꺼짐 | Settings → Advanced → HTTP APIs server ON |
| `qmd` 결과 없음 | 임베딩 미생성 | `qmd embed` 실행 |
| 시작 시 컨텍스트 없음 | 그래프 비어있음 | `polaris/top-of-mind` 작성, `/logseq:journal` 사용 |
| 첫 실행 안내 | 정상 | `/logseq:config` 실행 또는 무시 |

---

## 보안

- `config.env`에 API 토큰 포함 → **private 레포** 사용 필수
- Logseq 데이터는 **100% 로컬** — 별도 설정 없이 클라우드 동기화 없음
- MCP 서버는 `~/logseq-graph/`만 접근 — 다른 파일시스템 접근 없음

---

## 크레딧

[3-Layer Memory Stack](https://x.com/intheworldofai/status/2039255561280057794) 개념에서 영감을 받았으며, Obsidian에서 블록 기반 로컬 우선 지식 관리를 위한 Logseq로 전환하고, 세션 간 기억 연속성을 추가했습니다.
