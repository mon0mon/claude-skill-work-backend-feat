# work-backend-feat

요구사항 수집부터 머지까지, 백엔드 기능 구현의 전체 워크플로우를 자동화하는 [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 스킬입니다.

## 개요

이 스킬은 백엔드 기능 개발 및 버그 수정을 위한 구조화된 AI 지원 워크플로우를 제공합니다. 각 단계마다 AI 리뷰가 사용자 리뷰 전에 선행되어, 핵심 판단에만 집중할 수 있습니다.

### 워크플로우 단계

```
Phase 1: 요구사항 수집          → 요구사항 및 범위 명확화
Phase 2: 스펙 문서 작성         → 스펙 문서 생성 및 리뷰
Phase 3: AI 리뷰 형식           → 심각도별 구조화된 리뷰
Phase 4: 실행 계획 작성         → TDD 기반 구현 계획
Phase 5: Jira 티켓 & 브랜치     → Jira 이슈 생성 및 git 브랜치 생성
Phase 6: TDD & 구현             → 테스트 우선 개발 및 코드 리뷰
Phase 7: 커밋 & 푸시            → 사용자 승인 기반 구조화된 커밋
Phase 8: PR 생성                → PR 설명 자동 생성
Phase 9: 머지 & 정리            → 머지, 브랜치 정리, Jira 완료 처리
```

### 주요 기능

- **매 단계 AI 리뷰** — 스펙 리뷰, 계획 리뷰, 코드 리뷰를 구조화된 심각도(CRITICAL / HIGH / MEDIUM / LOW)로 제공
- **사용자 승인 게이트** — 모든 주요 단계에서 `(Y/n)` 확인 후 진행
- **TDD 워크플로우** — 구현 코드 전에 테스트를 먼저 작성
- **진행 상황 추적** — 현재 단계와 완료율을 시각적 프로그레스 바로 표시
- **워크플로우 재개** — 중단된 워크플로우를 마지막 체크포인트에서 재개 가능
- **Jira 연동** — 티켓 자동 생성, 상태 전환, PR 연결
- **스펙 & 실행 계획 템플릿** — 포함된 템플릿으로 일관된 문서 작성

### AI 리뷰 형식

리뷰에서 발견된 문제는 아래와 같은 구조화된 형식으로 제시됩니다:

```
### [P1] 문제 제목  [CRITICAL]

**도메인/상황**: 도메인에 대한 상세 설명
**문제 설명**: 문제의 구체적 내용
**발생 시나리오**: 문제가 발생하는 상황과 결과

**해결 방안**:
  A) 해결 방법 설명
     - 근거, 장점, 단점
     - 적합도 테이블 (아키텍처, 일관성, 복잡도, 유지보수성, 성능, 테스트 용이성)
     - 추천 여부: 추천 / 비추천

  B) 대안 방법...

  👉 추천: A — 추천 이유 한 줄
```

## 요구사항

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- [Atlassian MCP Server](https://github.com/anthropics/claude-code/tree/main/packages/mcp) (Jira 연동용)

### 선택적 의존성

아래 스킬/플러그인이 설치되어 있으면 워크플로우 품질이 향상되지만, 없어도 독립적으로 동작합니다.

#### 플러그인 스킬

[superpowers](https://github.com/anthropics/superpower-skills) 플러그인의 스킬들입니다. 플러그인 설치 시 자동으로 사용 가능합니다.

| 스킬 | 단계 | 역할 |
|------|------|------|
| `superpowers:writing-plans` | Phase 4 (실행 계획) | 체계적 실행 계획 수립 |
| `superpowers:test-driven-development` | Phase 6 (TDD) | TDD 프로세스 가이드 |
| `superpowers:requesting-code-review` | Phase 6 (코드 리뷰) | 구조화된 코드 리뷰 |

#### 커스텀 스킬

별도 설치가 필요한 독립 스킬입니다.

| 스킬 | 단계 | 역할 |
|------|------|------|
| `spec-reviewer` | Phase 2 (스펙 리뷰) | 다관점 전문가 리뷰 |

## 설치

### 빠른 설치

```bash
git clone https://github.com/mon0mon/claude-skill-work-backend-feat.git
cd claude-skill-work-backend-feat
./install.sh
```

### 수동 설치

```bash
# 1. 레포지토리 클론
git clone https://github.com/mon0mon/claude-skill-work-backend-feat.git

# 2. 스킬 파일을 Claude Code 스킬 디렉토리에 복사
mkdir -p ~/.claude/skills/work-backend-feat/references
cp claude-skill-work-backend-feat/SKILL.md ~/.claude/skills/work-backend-feat/
cp claude-skill-work-backend-feat/references/*.md ~/.claude/skills/work-backend-feat/references/
```

### 설치 확인

설치 후 Claude Code를 시작하고 아래와 같이 입력해보세요:

```
"새로운 API 엔드포인트 추가해줘"
```

다음과 같은 표현에서 스킬이 트리거됩니다:
- "기능 추가해줘", "버그 수정해줘", "API 만들어줘"
- "엔드포인트 추가", "새로운 도메인 추가"
- "구현해줘", "추가해줘", "만들어줘"

## 프로젝트 구조

```
work-backend-feat/
├── SKILL.md                          # 스킬 정의 (메인 파일)
├── README.md                         # 이 파일
├── install.sh                        # 설치 스크립트
└── references/
    ├── spec-template.md              # 스펙 문서 템플릿
    └── plan-template.md              # 실행 계획 템플릿
```

## 커스터마이즈

이 스킬은 **Spring Boot + 헥사고날 아키텍처** (Kotlin) 프로젝트를 기준으로 설계되었지만, 다른 기술 스택에 맞게 수정할 수 있습니다:

1. **아키텍처 컨벤션** (Phase 6.3.2) — 헥사고날 아키텍처 체크를 프로젝트 구조에 맞게 변경
2. **테스트 컨벤션** (Phase 6.1) — 테스트 베이스 클래스 및 디렉토리 패턴 수정
3. **JPA/DB 체크** (Phase 6.3.3-4) — 사용하는 ORM에 맞는 체크로 교체
4. **커밋 메시지 형식** (Phase 7) — `PS-{번호}` 형식을 프로젝트 컨벤션에 맞게 변경
5. **PR base 브랜치** (Phase 8) — `develop`을 기본 브랜치에 맞게 변경
6. **스펙/실행 계획 템플릿** (references/) — 팀 형식에 맞게 커스터마이즈

## 동작 방식

### 1. 트리거

Claude Code에 기능 구현이나 버그 수정을 요청하면, 이 스킬이 자동으로 활성화되어 전체 워크플로우를 안내합니다.

### 2. 구조화된 단계

각 단계에서 산출물(스펙 문서, 실행 계획, 테스트 코드, 구현 코드)을 생성하고, 사용자 승인 전에 AI 리뷰를 수행합니다.

### 3. 문서 생성

스킬은 아래 경로에 구조화된 문서를 생성합니다:
- **스펙 문서** → `docs/workflow/work/backend/spec/`
- **실행 계획** → `docs/workflow/work/backend/plans/`

### 4. Jira 연동

Atlassian MCP 서버가 설정되어 있으면, 스킬이 자동으로:
- 스펙 기반으로 Jira 이슈 생성
- 현재 사용자에게 담당자 할당
- 워크플로우에 따라 상태 전환
- 머지 완료 시 티켓 종료

## 라이선스

MIT
