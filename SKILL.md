---
name: work-backend-feat
description: 백엔드 기능 구현/버그 수정의 전체 워크플로우를 자동화하는 스킬. 요구사항 수집 → 스펙 → 실행 계획 → Jira → TDD → 구현 → 코드 리뷰 → 프로젝트 문서화 → 커밋 정리 → rebase → PR → 머지 → 옵시디언까지 11단계를 AI 리뷰와 사용자 승인으로 진행한다. 서브에이전트 모델 최적화(opus/sonnet/haiku)로 토큰을 절약한다. 사용자가 새 코드 작성이나 기존 코드 동작 변경을 요청할 때 반드시 이 스킬을 사용한다. 트리거: "기능 추가해줘", "버그 수정해줘", "API 만들어줘", "엔드포인트 추가", "도메인 추가", "서비스 추가", "스케줄러 만들어줘", "외부 API 연동", "필드 추가", "~하도록 변경해줘", "구현해줘", "만들어줘" 등. 비트리거: 코드 설명/질문, PR 리뷰, 설정 확인, 성능 분석, 라이브러리 업데이트, CI/CD, git 작업, 아키텍처 설명.
---

# work-backend-feat — 백엔드 기능 구현 워크플로우

**핵심 철학**: 구조화된 워크플로우로 품질과 효율을 동시에 달성한다. 각 단계마다 AI 리뷰가 사용자 리뷰에 선행한다.

**사용자 승인 규칙**: 모든 승인은 `(Y/n)`. 빈 응답 = Yes.

**서브에이전트 모델**: `references/subagent-model-map.md` 참조. opus(설계/리뷰), sonnet(구현/테스트), haiku(탐색/복사).

**문체 규칙**: PR body, 핸드오프 문서 등 모든 산출물은 **개조식 + 명사형 종결**로 작성. 불필요한 수사구 없이 핵심 기능만 요약. "~하였다", "~합니다", "~되었습니다" 등 서술형 종결 금지. 예: "주문 생성 API 추가", "반올림 모드 HALF_UP으로 변경", "프론트 영향 없음".

---

## 연동 스킬 (선택적 — 없으면 자체 references로 동작)

| 스킬 | Phase | 역할 |
|------|-------|------|
| `spec` (Phase 4: Review) | 2 | 스펙 리뷰 |
| `writing-plans` | 4 | 실행 계획 수립 |
| `test-driven-development` | 6 | TDD 프로세스 |
| `requesting-code-review` | 6 | 코드 리뷰 |
| `project-docs-manager` | 7 | 지식 문서 관리 |
| `git-commit-rebase` | 8 | 커밋 정리 & rebase |

---

## 진행 상황 표시

모든 단계의 시작 시와 사용자 승인 직전에 표시한다:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Phase {N}/11: {Phase 이름}  |  Step {M}: {Step 이름}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[■■■■■□□□□] 45% (Phase 5/11)
Phase 1 ✅ → Phase 2 ✅ → 【Phase 3】→ ... → Phase 11
```

---

## 워크플로우 재개

사용자가 기존 작업을 이어가려는 경우 (예: "PS-85 이어서 진행해줘"):
1. `docs/workflow/work/backend/` 에서 해당 티켓 문서 검색
2. git 브랜치 상태로 진행 단계 판단
3. 해당 단계부터 재개

---

## Phase 1: 요구사항 수집

**목적**: 요구사항의 모호성을 제거하고 작업 범위를 확정한다.

작업 유형 식별 (기능 구현/버그 수정) → 비즈니스 로직, 설계 판단, 잠재적 문제, 영향 범위 관점에서 질문. 정보가 충분하면 질문 없이 진행

---

## Phase 2: 스펙 문서 작성

**목적**: 설계 문서를 작성하고 AI + 사용자 리뷰로 확정한다.

1. **Jira 키 확인**: CLAUDE.md → 메모리 → 사용자 질문 순으로 확인. 확정 후 CLAUDE.md에 저장
2. **스펙 생성**: `references/spec-template.md` 참조
3. **AI 리뷰**: `spec` 스킬(Phase 4: Review) 또는 독립 리뷰 (요구사항 누락, 도메인 설계, API 일관성, 영향 범위, 설계 결정 충분성). `references/ai-review-format.md` 형식을 따른다. **설계 결정 리뷰**: DD 섹션이 있는 경우 — 주요 설계 지점에서 대안이 탐색되었는가, 기각 이유가 기술적으로 타당한가, 제약 조건이 명시되어 향후 재검토 시점을 판단할 수 있는가를 검토한다. DD가 없는 경우 — 작업 규모(중규모 이상) 대비 설계 결정이 불필요한지 확인하고, 비자명한 설계 선택이 있었다면 DD 추가를 권고한다. AI 리뷰 후 중단 없이 사용자 리뷰로 연속 진행
4. **사용자 리뷰**: 각 이슈 상세 분석 → 리뷰 요약 테이블 → `P1: A, P2: B` 선택 요청. 요약만 보여주고 상세를 생략하면 안 된다

저장 경로: `docs/workflow/work/backend/spec/{SPACE}-XX_{YYMMDD}_spec_{타이틀}.md`

---

## Phase 3: AI 리뷰 형식 (참조)

모든 AI 리뷰는 `references/ai-review-format.md`를 따른다. 이 Phase는 실행 단계가 아니라 형식 정의다.

---

## Phase 4: 실행 계획 작성

**목적**: TDD 기반 구현 로드맵을 작성한다.

1. **계획 생성**: `references/plan-template.md` 참조. TDD 순서 (테스트→구현→커밋), API 변경 시 `.http` 파일 업데이트 포함. 스펙의 설계 결정(DD) 섹션이 있으면 — 선택된 방안을 구현 순서에 반영하고, 기각된 대안의 패턴이 계획에 혼입되지 않는지 확인
2. **라이브러리 의존성 체크**: 빌드 파일 분석 → Flyway/Liquibase/QueryDSL/MapStruct/Security/Cache 등 코드 변경에 연동되는 설정 파일 체크. 누락 시 런타임 실패 방지
3. **AI 리뷰 + 사용자 리뷰**: 단계 순서 논리성, 누락 항목, 테스트 커버리지, 커밋 단위 적절성 검토. 스펙에 DD가 있으면 — 계획이 DD의 제약 조건을 위반하지 않는지, 기각된 대안의 접근법이 계획에 혼입되지 않았는지 추가 검토

저장 경로: `docs/workflow/work/backend/plans/{SPACE}-XX_{YYMMDD}_plan_{타이틀}.md`

---

## Phase 5: Jira 티켓 & 브랜치 생성

1. `atlassianUserInfo`로 활성 유저 조회 → Jira 이슈 생성 (담당자 설정, "진행 중" 전환)
2. 문서 파일명의 `{SPACE}-XX_{YYMMDD}` → 실제 티켓 키로 변경
3. `git checkout -b {Jira 키}` 브랜치 생성
4. `.gitignore`에 `docs/workflow/` 포함 여부 확인 (메모리 기록 있으면 자동, 없으면 질문)

---

## Phase 6: TDD & 구현

**목적**: 테스트 먼저 작성 → 구현 → 검증 → AI 리뷰의 순서로 코드를 작성한다.

### 6.1 TDD 테스트 작성

실행 계획의 각 단계에 대해 테스트를 먼저 작성한다. 프로젝트 테스트 컨벤션(BaseUseCaseTest, BaseRestDocsApiTest 등)을 따른다. 추가 테스트가 필요하면 비용-이점 분석과 함께 사용자에게 확인한다.

### 6.2 구현 & 검증

테스트를 통과시키는 코드를 작성한다. 구현 후:
- **실제 요청 검증**: 프로젝트 빌드 & 실행 → 정상/경계/에러 케이스 시나리오 → `.http` 또는 curl로 실제 API 호출 → DB 반영 확인. API 변경 없는 내부 로직만이면 사용자 확인 후 스킵 가능
- **`.http` 파일 업데이트**: API 변경 시 `http/` 디렉토리의 JetBrains HTTP Client 파일 업데이트. 기존 스타일 따름

### 6.3 AI 코드 리뷰

`references/code-review-checklist.md`의 7개 관점 (스펙 정합성, 아키텍처, JPA/DB, 동시성, 성능, 일반 실수, 테스트 커버리지)을 빠짐없이 검토한다. `references/ai-review-format.md` 형식으로 결과 정리.

### 6.4 스태그네이션 탈출

같은 에러 3회 반복, 같은 파일 5회 수정, 같은 테스트 3회 실패 감지 시:
- 사용자에게 대안 제시 (다른 접근/스코프 축소/사용자 개입)

### 6.5 사용자 코드 리뷰

AI 리뷰 결과와 구현 내용을 사용자에게 제시한다. 피드백 없으면 "✅ AI 코드 리뷰 완료 — 피드백할 문제를 발견하지 못했습니다." 명시.

---

## Phase 7: 프로젝트 문서화

**목적**: 작업에서 얻은 지식을 프로젝트 내부 문서로 관리한다. 커밋 전에 수행하여 문서가 커밋에 포함되도록 한다.

### 7.1 프로젝트 문서

`project-docs-manager` 스킬이 있으면 활용, 없으면 `references/documentation-guide.md`를 따른다.

1. `docs/product/` 하위 탐색 → 업데이트 대상 식별
2. 문서 작업 계획 제시 (생성/업데이트/리팩토링) → 사용자 확인
3. 실행 (새 문서/소규모 업데이트는 자동, 삭제/통합/분리는 승인 필요)
4. 결과 안내

문서화가 필요 없으면 이유를 설명하고 7.2로 진행한다.

### 7.2 프론트엔드 핸드오프 문서

`references/frontend-handoff-template.md`의 판단 기준에 따라 프론트엔드 영향 여부를 분석한다.

1. **영향 분석**: 이번 변경에서 API 추가/변경, Enum 변경, 에러 코드 추가, 스키마 변경 등이 있는지 코드 diff 기반으로 판단
2. **영향 있음** → `references/frontend-handoff-template.md` 형식으로 문서 생성. 저장 경로: `docs/product/frontend-handoff/{SPACE}-{번호}_{YYMMDD}_frontend_{타이틀}.md`
3. **영향 없음** → "프론트엔드 영향 없음 — 핸드오프 문서 생략" 안내 후 Phase 8로 진행
4. 생성된 문서는 Phase 9에서 PR body에 GitHub 파일 링크로 포함된다

---

## Phase 8: 커밋 & 푸시

**목적**: 커밋을 프로젝트 컨벤션에 맞게 정리하고, base 브랜치와 동기화한 후 푸시한다.

`git-commit-rebase` 스킬이 있으면 활용, 없으면 `references/commit-rebase-guide.md`를 따른다.

1. **커밋**: 모듈/유즈케이스 단위, 각 커밋 전 사용자 승인
2. **커밋 정리**: 컨벤션 감지 (CLAUDE.md → 설정파일 → git log) → squash/reword/reorder 제안 → 승인 후 실행
3. **Rebase**: 백업 브랜치 생성 → `git fetch origin develop` → 최신이면 스킵, 아니면 rebase → 충돌 시 해결 가이드 + 사용자 개입 요청
4. **푸시**: `git push -u origin {브랜치}`. rebase 후 force push 필요 시 `--force-with-lease` 안내 + (Y/n)

---

## Phase 9: PR 생성

### 9.1 PR 시각화 생성

`references/pr-visualization-guide.md`의 판단 기준에 따라 시각화 포함 여부를 결정한다.

1. **판단**: 이번 변경이 리뷰어에게 시각화가 도움이 되는 규모/복잡도인지 평가
2. **포함 결정 시**: Mermaid 다이어그램 생성 (GitHub 네이티브 렌더링)
   - **큰 그림** (Architecture Context): 전체 아키텍처에서 변경 위치. `<details>` 접기로 감싼다
   - **작은 그림** (Detail Flow): 세부 흐름 (시퀀스/플로차트/상태 전이). 바로 보이도록 열어둔다
3. **생략 결정 시**: 시각화 없이 PR 생성으로 진행
4. 판단이 애매하면 사용자에게 묻는다

### 9.2 PR 생성

```
gh pr create --base develop --assignee @me --title "{SPACE-번호 제목}" --body "$(cat <<'EOF'
## Summary
{스펙 기반 요약 2~3줄. 개조식 명사형 종결}

## Diagrams
{9.1에서 생성한 Mermaid 다이어그램. 시각화 생략 시 이 섹션 제거}

## Changes
{주요 변경사항. 개조식 bullet point}

## Frontend Handoff
{Phase 7.2에서 핸드오프 문서를 생성한 경우:}
> **프론트엔드 영향 사항 있음.** 아래 문서 확인 필요.
> 📄 [Frontend Handoff: {기능명}](https://github.com/{owner}/{repo}/blob/{commit-sha}/{파일경로})
>
> **핵심 변경 요약:**
> - {프론트에서 가장 먼저 대응해야 할 변경 1~3줄 요약}
{핸드오프 문서가 없는 경우 이 섹션 제거}

## Spec
{스펙 핵심 요약}

## Test plan
{테스트 계획 및 결과}

## TODO
- [ ] {향후 개선/확장 사항 — 없으면 섹션 생략}
EOF
)"
```

base 브랜치: `develop`. PR URL을 사용자에게 전달한다.

**Frontend Handoff 링크 생성**: PR 생성 직전에 아래 명령으로 commit SHA와 repo 정보를 자동 추출하여 permalink를 구성한다. 플레이스홀더 수동 치환 금지.
```bash
COMMIT_SHA=$(git rev-parse HEAD)
REPO_URL=$(gh repo view --json url -q '.url')
# permalink: ${REPO_URL}/blob/${COMMIT_SHA}/{파일경로}
```
핸드오프 문서의 `PR: #번호` 필드는 PR 생성 전이므로 **생략**한다. PR URL은 PR body 자체가 제공.

---

## Phase 10: 머지 & 완료

1. 사용자 승인 후 PR 머지
2. **워크트리 문서 동기화**: 워크트리인 경우 `references/worktree-sync.md` 참조. 아니면 스킵
3. **브랜치 정리**: `git checkout develop` → `git pull` → 로컬/원격 브랜치 삭제
4. **Jira 완료**: 이슈 상태를 "완료"로 전환

---

## Phase 11: 옵시디언 문서화 (선택)

1. `이번 작업을 옵시디언에 남길까요? (Y/n)` — No면 종료
2. Vault 경로 확인: CLAUDE.md → 메모리 → 질문. 메모리에 저장
3. 기존 스키마 탐지 → 없으면 구조 제안 (도메인/API/트러블슈팅/작업 이력)
4. `obsidian-dedup` 스킬로 중복 방지. 프로젝트 문서와 중복되지 않는 **개인 인사이트** 위주 작성

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Phase 11/11: 옵시디언 문서화  |  ✅ 완료
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[■■■■■■■■■] 100%
전체 워크플로우 완료.
```

---

## 참조 파일

| 파일 | 용도 | 읽는 시점 |
|------|------|----------|
| `references/spec-template.md` | 스펙 문서 템플릿 | Phase 2 |
| `references/plan-template.md` | 실행 계획 템플릿 | Phase 4 |
| `references/ai-review-format.md` | AI 리뷰 형식 (P번호, 심각도, 요약) | Phase 2, 4, 6 리뷰 시 |
| `references/code-review-checklist.md` | 코드 리뷰 7개 관점 체크리스트 | Phase 6.3 |
| `references/documentation-guide.md` | 프로젝트 문서 관리 | Phase 7.1 |
| `references/frontend-handoff-template.md` | 프론트엔드 핸드오프 문서 템플릿 | Phase 7.2 |
| `references/pr-visualization-guide.md` | PR Mermaid 시각화 가이드 | Phase 9.1 |
| `references/commit-rebase-guide.md` | 커밋 정리 & rebase 전략 | Phase 8 |
| `references/subagent-model-map.md` | Phase/Step별 모델 배정표 | 각 Phase 시작 시 |
| `references/worktree-sync.md` | 워크트리 문서 동기화 | Phase 10 |
