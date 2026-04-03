# Logseq + Claude 메모리 스택

> Claude를 단순 자동완성에서 당신의 스택, 표준, 장기 목표를 아는 **진짜 시니어 동료**로 바꿔줍니다.

**프로젝트 DNA**, **개인 지식 그래프**, **외부 리서치**를 하나의 살아있는 검색 가능한 두뇌로 연결하는 3-Layer Compounding Memory 시스템 — [Logseq](https://logseq.com) + [Claude](https://claude.ai) 기반.

**macOS와 Windows를 지원합니다.**

---

## 왜 필요한가?

대부분의 개발자가 세션마다 **30-40분**을 AI에게 컨텍스트를 다시 설명하는 데 낭비합니다. 이 설정은 Claude에게 당신이 만들고, 결정하고, 배운 모든 것에 대한 영구적이고 검색 가능한 접근을 제공하여 이를 제거합니다.

| 레이어 | 내용 | 방법 |
|--------|------|------|
| **세션 메모리** | `CLAUDE.md` + Auto-Memory | Claude가 프로젝트 규칙을 읽고 스스로 학습 내용을 기록 |
| **지식 그래프** | Logseq + MCP 브릿지 | Claude가 당신의 세컨드 브레인을 실시간 탐색 |
| **수집** | Inbox → Commonplace | 소비한 모든 콘텐츠가 영구 검색 가능 |

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

스크립트가 모든 것을 자동으로 처리합니다.

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
| 7 | Claude Desktop MCP | `~/Library/.../claude_desktop_config.json` | `%APPDATA%\Claude\claude_desktop_config.json` |
| 8 | SessionStart Hook | `bash ensure-logseq.sh` | `powershell ensure-logseq.ps1` |
| 9 | 로그인 시 자동 실행 | Login Items (osascript) | 시작 프로그램 폴더 바로가기 |

---

## 설치 후 수동 설정 (최초 1회)

Logseq HTTP API는 앱 UI에서 활성화해야 합니다:

1. **Logseq** 앱 열기 → **Add a graph** → `~/logseq-graph` 선택 (Windows: `%USERPROFILE%\logseq-graph`)
2. **Settings** → **Advanced** → **Developer mode** → ON
3. **Settings** → **Advanced** → **HTTP APIs server** → ON
4. **Settings** → **Advanced** → **Authorization tokens** → `config.env`의 토큰 붙여넣기

확인:

```bash
# macOS / Linux
curl -s http://localhost:12315/api -H "Authorization: Bearer <your-token>"

# Windows PowerShell
Invoke-RestMethod -Uri http://localhost:12315/api -Headers @{Authorization="Bearer <your-token>"}
```

---

## 설정

### `config.env`

```env
# Logseq API 인증 토큰
LOGSEQ_TOKEN="your-token-here"

# 그래프 경로 변경 (선택)
# LOGSEQ_GRAPH="$HOME/logseq-graph"
```

> **보안**: 이 파일에 API 토큰이 포함되어 있으므로 반드시 **private 레포지토리**를 사용하세요.

### 새 토큰 생성

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

## MCP 서버

3개의 서버가 글로벌(`--scope user`)로 등록되어 **모든 프로젝트**에서 작동합니다:

| 서버 | 타입 | 용도 |
|------|------|------|
| `logseq` | HTTP API | 검색, 블록 생성, 태스크 관리, 그래프 DB 쿼리 |
| `logseq-graph` | 파일시스템 | 모든 Logseq 파일 직접 read/write |
| `qmd` | 검색 엔진 | BM25 키워드 + 시맨틱 검색 |

확인:

```bash
claude mcp list
```

---

## 그래프 구조

```
~/logseq-graph/
├── pages/                          # 모든 노트 (flat + namespace)
│   ├── polaris___top-of-mind.md    # 목표, 원칙, 활성 프로젝트
│   ├── commonplace___*.md          # Atomic 노트, 에버그린 아이디어
│   └── inbox.md                    # 임시 수집함
├── journals/                       # 일별 로그 (Logseq 자동 생성)
│   └── 2026-04-03.md
├── assets/                         # 첨부파일
└── logseq/
    └── config.edn                  # Logseq 앱 설정
```

### Logseq 네임스페이스

Logseq는 파일명에서 `___` (밑줄 3개)로 `/` 네임스페이스를 표현합니다:

| 파일명 | Logseq 페이지명 |
|--------|----------------|
| `polaris___top-of-mind.md` | `polaris/top-of-mind` |
| `commonplace___auth-patterns.md` | `commonplace/auth-patterns` |

---

## Polaris 전략

`polaris/top-of-mind`은 다음을 담는 살아있는 문서입니다:
- 현재 분기 목표
- 성공 기준이 있는 활성 프로젝트
- Life Razors (비타협 원칙)

중요한 작업 세션을 시작할 때마다:

```
내 polaris/top-of-mind 페이지를 읽어줘.
이 작업이 Q2 목표와 어떻게 연결되는지 평가하고,
방향이 어긋나는 부분이 있으면 시작 전에 알려줘.
```

Claude가 당신 스스로 정한 방향에서 벗어나려 할 때 제동을 거는 책임 파트너가 됩니다.

---

## 자동화

### SessionStart Hook

Claude Code가 시작될 때마다 Hook이 자동으로:
1. Logseq가 실행 중인지 확인 (포트 12315)
2. 실행 중이 아니면 백그라운드로 자동 시작
3. API 준비까지 최대 10초 대기

### 로그인 시 자동 실행

- **macOS**: Login Item으로 등록 (숨김 실행)
- **Windows**: 시작 프로그램 폴더에 바로가기 생성 (최소화 실행)

---

## 레포 구조

```
logseq-brain-setup/
├── install.sh                # macOS 설치 스크립트
├── install.ps1               # Windows 설치 스크립트
├── config.env                # 공유 설정 (토큰)
├── scripts/
│   ├── ensure-logseq.sh      # SessionStart hook (macOS)
│   └── ensure-logseq.ps1     # SessionStart hook (Windows)
└── templates/
    ├── config.edn            # Logseq 앱 설정
    ├── polaris___top-of-mind.md
    ├── inbox.md
    └── claude-md-addon.md    # ~/.claude/CLAUDE.md에 추가되는 내용
```

---

## 멱등성

설치 스크립트는 여러 번 실행해도 안전합니다:
- 이미 설치된 도구는 스킵
- 기존 파일은 덮어쓰지 않음
- MCP 서버는 제거 후 재등록
- CLAUDE.md 추가 내용은 미존재 시에만 추가

---

## 문제 해결

| 증상 | 원인 | 해결 |
|------|------|------|
| `logseq` MCP: Failed | Logseq 미실행 또는 API 비활성화 | Logseq 열고 HTTP API 활성화 |
| 401 Unauthorized | 토큰 불일치 | `config.env`와 Logseq 설정의 토큰 확인 |
| 포트 12315 미응답 | HTTP 서버 꺼짐 | Settings → Advanced → HTTP APIs server ON |
| `qmd` 결과 없음 | 임베딩 미생성 | `qmd embed` 실행 |

---

## 크레딧

[3-Layer Memory Stack](https://x.com/intheworldofai/status/2039255561280057794) 개념에서 영감을 받았으며, Obsidian에서 블록 기반 로컬 우선 지식 관리를 위한 Logseq로 전환했습니다.
