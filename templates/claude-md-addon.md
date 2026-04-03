

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
