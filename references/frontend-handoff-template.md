# 프론트엔드 핸드오프 문서 템플릿

백엔드 변경사항 중 프론트엔드에 영향을 주는 내용을 정리하는 문서. 프론트 개발자가 이 문서만 읽으면 연동에 필요한 모든 정보를 얻을 수 있어야 한다.

**문체: 개조식 + 명사형 종결** — 불필요한 수사구 없이 핵심만 기술. "~하였다", "~합니다" 등 서술형 종결 금지. 예: "주문 생성 API 추가", "cancelReason 필드 신규 — 취소 시에만 값 존재".

## 생성 판단 기준

아래 중 하나라도 해당 시 문서 생성:

- API 엔드포인트 추가/변경/삭제
- 요청(Request) 또는 응답(Response) 스키마 변경
- Enum 값 추가/변경/삭제
- 에러 코드 추가/변경
- 인증/인가 방식 변경
- 프론트에서 사용하는 WebSocket/SSE 이벤트 변경
- 기타 프론트엔드 연동에 영향을 주는 변경

해당 없으면 "프론트엔드 영향 없음" 안내 후 생략.

## 저장 경로

```
docs/product/frontend-handoff/{SPACE}-{번호}_{YYMMDD}_frontend_{타이틀}.md
```

예: `docs/product/frontend-handoff/PS-85_260329_frontend_order_create.md`

## 문서 구조

```markdown
# Frontend Handoff: {기능 제목}

> Jira: {SPACE-번호} | Date: {YYYY-MM-DD}

## TL;DR — 프론트 핵심 체크리스트

> 프론트에서 가장 먼저 확인하고 대응해야 할 항목만 추림.

- [ ] {핵심 변경 1 — 예: `OrderStatus`에 `SHIPPING` 추가됨 → UI 상태 뱃지 추가 필요}
- [ ] {핵심 변경 2 — 예: `POST /api/v1/orders` 신규 → 주문 생성 연동}
- [ ] {핵심 변경 3 — 예: `INSUFFICIENT_STOCK(409)` 에러 핸들링 추가 필요}

---

## Breaking Changes

{호환성이 깨지는 변경. 없으면 "없음" 명시}

| 항목 | Before | After | 마이그레이션 |
|------|--------|-------|-------------|
| ... | ... | ... | ... |

---

## API Changes

### 새 엔드포인트

#### `POST /api/v1/orders`

- **설명**: 주문 생성
- **인증**: Bearer Token 필수
- **Request Body**:
```json
{
  "productId": "string (UUID)",
  "quantity": "number (1 이상)"
}
```
- **Response** (`201 Created`):
```json
{
  "id": "string (UUID)",
  "status": "PENDING",
  "createdAt": "ISO 8601"
}
```

### 변경된 엔드포인트

#### `GET /api/v1/orders/{id}` — 응답 필드 추가

| 필드 | 타입 | 변경 내용 |
|------|------|----------|
| `cancelReason` | `string?` | 신규 추가. 취소 시에만 값 존재 |

### 삭제된 엔드포인트

{없으면 섹션 생략}

---

## Enum Changes

| Enum | 변경 | 값 | 설명 |
|------|------|----|------|
| `OrderStatus` | 추가 | `SHIPPING` | 배송 중 상태 |
| `ErrorCode` | 추가 | `ORDER_LIMIT_EXCEEDED` | 주문 한도 초과 |

---

## Error Handling

프론트에서 처리해야 하는 에러 응답:

| HTTP Status | Error Code | 발생 조건 | 프론트 권장 처리 |
|-------------|------------|----------|-----------------|
| 400 | `INVALID_QUANTITY` | quantity ≤ 0 | 입력값 검증 메시지 표시 |
| 409 | `ORDER_LIMIT_EXCEEDED` | 일일 주문 한도 초과 | 한도 안내 팝업 |
| 404 | `PRODUCT_NOT_FOUND` | 존재하지 않는 상품 | 상품 목록으로 리다이렉트 |

---

## Additional Notes

{위 카테고리에 속하지 않지만 프론트에 전달이 필요한 사항. 예: 페이지네이션 방식 변경, 캐싱 정책, Rate Limit 등}
```

## TL;DR 작성 규칙

TL;DR 섹션은 프론트 개발자가 **30초 안에 "무엇을 해야 하는지"** 파악할 수 있는 체크리스트임. 아래 규칙을 따름:

- 체크박스(`- [ ]`) 형식으로 3~5개 이내
- 각 항목은 **"무엇이 바뀌었는지" + "프론트에서 뭘 해야 하는지"** 한 줄로
- Breaking Changes가 있으면 체크리스트 맨 위에 배치
- 새 에러 코드가 있으면 "에러 핸들링 추가 필요" 한 줄로 묶음
- 상세 내용은 아래 섹션에서 확인하도록 유도

## 사용 참고

- 해당 내용 있는 섹션만 포함 (빈 섹션 생략)
- Breaking Changes 존재 시 최상단 배치
- JSON 예시에 실제 필드명/타입 사용 (placeholder 금지)
- Enum 값은 백엔드 코드의 실제 값 그대로 기재
- 에러 코드는 실제 응답 포맷과 일치
