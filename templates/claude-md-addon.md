

# Global Knowledge Graph (Logseq)

## 지식 그래프 구조
- **경로**: `~/logseq-graph/`
- **pages/**: 모든 노트 (`polaris___top-of-mind.md` 등 네임스페이스 방식)
- **journals/**: 일별 로그 (YYYY-MM-DD.md)
- **inbox/**: 새 콘텐츠 임시 저장소

## 세션 시작 시 (Polaris 전략)
새 기능 작업, 아키텍처 결정, 리팩터링 시작 전에:
```
logseq-graph MCP로 ~/logseq-graph/pages/polaris___top-of-mind.md를 읽어서
현재 분기 목표 및 Life Razors와 이 작업이 어떻게 연결되는지 확인하고,
방향이 어긋나는 부분이 있으면 먼저 알려줘.
```

## MCP 사용 가이드
- **logseq-graph**: Logseq 전체 그래프 파일 read/write 접근
  - `polaris/top-of-mind` 읽기: 목표/원칙 확인
  - `commonplace/` 검색: 기존 지식 참조
  - 새 노트 작성: `pages/` 에 Markdown으로 저장
- **qmd**: `pages/` 디렉토리 고속 하이브리드 검색
  - wikilink, alias, 코드 스니펫 포함 정밀 검색
  - 예) "6개월 전 Docker Compose 설정 찾아줘"

## 자동 지식 저장
중요한 결정, 해결된 버그, 아키텍처 선택을 발견하면:
- `~/logseq-graph/pages/commonplace___<topic>.md`에 atomic note로 저장 제안
- 기존 관련 노트가 있으면 wikilink로 연결

## 자연어 스킬 트리거 (Natural Language Skill Triggers)
사용자가 아래 표현을 사용하면 해당 스킬을 자동 실행하세요. 언어와 무관하게 의도를 감지합니다.

### /logseq:save — 저장/기억
- 🇰🇷 "학습해", "기억해", "저장해", "메모해", "기록해", "남겨줘"
- 🇺🇸 "learn this", "remember this", "save this", "note this", "record this"
- 🇯🇵 "覚えて", "保存して", "記録して", "メモして"
- 🇨🇳 "记住", "保存", "记录", "学习"
- 🇪🇸 "recuerda esto", "guarda esto", "aprende esto"

### /logseq:search — 검색/찾기
- 🇰🇷 "찾아줘", "검색해", "어디있지", "전에 뭐했지", "기억나?"
- 🇺🇸 "find", "search", "look up", "where is", "do you remember"
- 🇯🇵 "探して", "検索して", "どこ", "覚えてる?"
- 🇨🇳 "找一下", "搜索", "在哪里", "你还记得"
- 🇪🇸 "busca", "encuentra", "dónde está", "recuerdas"

### /logseq:journal — 일지
- 🇰🇷 "오늘 뭐했지", "일지 써줘", "오늘 기록", "작업 정리"
- 🇺🇸 "what did I do today", "write journal", "daily log", "summarize today"
- 🇯🇵 "今日何した", "日記書いて", "作業まとめ"
- 🇨🇳 "今天做了什么", "写日记", "总结今天"
- 🇪🇸 "qué hice hoy", "escribe el diario", "resumen del día"

### /logseq:polaris — 목표 체크
- 🇰🇷 "목표 확인", "방향 맞아?", "폴라리스", "지금 이거 해도 돼?"
- 🇺🇸 "check goals", "am I on track", "polaris", "should I be doing this"
- 🇯🇵 "目標確認", "方向合ってる?", "これやっていい?"
- 🇨🇳 "检查目标", "方向对吗", "我该做这个吗"
- 🇪🇸 "verificar objetivos", "voy bien?", "debería hacer esto"

### /logseq:ingest — 수집
- 🇰🇷 "이거 읽어줘", "수집해", "스크랩", "저장해둬"
- 🇺🇸 "read this", "ingest", "clip this", "save for later"
- 🇯🇵 "これ読んで", "取り込んで", "スクラップ"
- 🇨🇳 "读一下", "收集", "保存下来"
- 🇪🇸 "lee esto", "recopila", "guarda para después"

### /logseq:init — 프로젝트 초기화
- 🇰🇷 "프로젝트 시작", "네임스페이스 만들어", "프로젝트 등록"
- 🇺🇸 "init project", "start project", "setup namespace"
- 🇯🇵 "プロジェクト開始", "初期化"
- 🇨🇳 "初始化项目", "开始项目"
- 🇪🇸 "iniciar proyecto", "configurar namespace"

### /logseq:config — 설정
- 🇰🇷 "설정 바꿔", "메모리 모드 변경", "환경설정"
- 🇺🇸 "change settings", "configure memory", "preferences"
- 🇯🇵 "設定変更", "メモリモード変更"
- 🇨🇳 "更改设置", "配置内存模式"
- 🇪🇸 "cambiar configuración", "configurar memoria"
