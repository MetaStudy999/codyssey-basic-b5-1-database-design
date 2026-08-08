# B5-1 평가 대비 질문·모범답안

> 기준: `b5-1-mission.pdf`, `b5-1-mission.md`, `b5-1-evaluation.md`, 현재 구현(`sql/01_schema.sql`, `sql/02_seed.sql`, `sql/03_queries.sql`)과 실제 Evidence.
>
> 이 문서는 **공식 평가항목을 실제 구현 기준으로 설명할 수 있도록 정리한 학습 자료**다. 아래 `Q01~Q16`은 공식 평가항목을 직접 커버하고, `Q17~Q21`은 이해도를 높이기 위한 보충 질문이다. 보충 질문은 새로운 공식 요구사항이 아니다.

## 0. 평가 답변 원칙

가장 좋은 답변 구조는 다음 순서다.

```text
개념
→ 현재 B5-1 DB의 실제 예
→ 실제 검증/Evidence
→ 왜 그렇게 설계했는가
```

예를 들어 FK 질문에서는 정의만 말하지 않고 `rentals.member_id → members.id`를 예로 들고, 존재하지 않는 `member_id=999` 입력이 실제로 차단되었다는 Evidence까지 연결한다.

---

## Q01. 왜 하나의 큰 테이블이 아니라 4개 테이블로 나누었습니까?

### 모범답안

데이터의 역할과 생명주기가 서로 다르기 때문에 테이블을 분리했습니다.

- `categories`: 도서 분류 기준
- `members`: 회원 기준 정보
- `books`: 도서 기준 정보
- `rentals`: 실제 대여 사건과 이력

예를 들어 한 회원이 책을 여러 번 빌린다고 해서 이름과 이메일을 대여 기록마다 반복 저장할 필요는 없습니다. 회원 정보는 `members`에 한 번 저장하고 `rentals.member_id`가 이를 참조하도록 했습니다.

이 구조는 데이터 중복을 줄이고, 한 곳의 기준 정보만 수정하면 되도록 하며, PK/FK와 제약조건으로 관계와 무결성을 DB가 직접 보장하게 합니다. 필요할 때는 JOIN으로 다시 조합합니다.

### 핵심 키워드

`역할 분리 → 중복 감소 → PK/FK → 무결성 → JOIN`

---

## Q02. 각 테이블의 역할은 무엇입니까?

### 모범답안

| 테이블 | 역할 | 분리 이유 |
|---|---|---|
| `categories` | 도서 분류 기준 | 같은 카테고리명을 책마다 반복하지 않기 위해 |
| `members` | 회원 기준 정보 | 회원 정보와 반복되는 대여 이력을 분리하기 위해 |
| `books` | 도서 기준 정보 | 제목·저자·ISBN 등 도서 자체 정보를 대여 사건과 분리하기 위해 |
| `rentals` | 누가 어떤 책을 언제 빌렸는지 기록 | 반복 발생하는 사건/이력을 독립적으로 저장하기 위해 |

특히 `rentals`는 기준정보가 아니라 시간에 따라 반복 발생하는 거래·이력 성격의 데이터입니다.

---

## Q03. PK와 FK의 차이는 무엇입니까?

### 모범답안

**PK(Primary Key, 기본키)**는 한 테이블에서 각각의 행을 유일하게 식별합니다. 현재 DB에서는 `categories.id`, `members.id`, `books.id`, `rentals.id`가 PK입니다.

**FK(Foreign Key, 외래키)**는 다른 테이블의 PK를 참조해 관계를 만듭니다.

```text
books.category_id  → categories.id
rentals.member_id  → members.id
rentals.book_id    → books.id
```

PK가 “이 행은 누구인가?”를 식별한다면, FK는 “이 행은 다른 어떤 행과 연결되는가?”를 표현합니다. FK는 존재하지 않는 부모 행을 참조하지 못하도록 막아 참조 무결성도 보장합니다.

---

## Q04. 1:N 관계를 현재 DB 기준으로 설명해 보세요.

### 모범답안

1:N은 부모 한 행이 여러 자식 행과 연결될 수 있는 관계입니다.

```text
categories 1 ───── N books
members    1 ───── N rentals
books      1 ───── N rentals
```

예를 들어 회원 한 명은 여러 번 책을 빌릴 수 있으므로 `members 1 : N rentals` 관계입니다. 반대로 하나의 rental 행은 한 명의 member만 참조합니다.

---

## Q05. FK가 실제로 동작한다는 것을 어떻게 증명했습니까?

### 모범답안

스키마에 `FOREIGN KEY` 문장이 존재하는 것만으로 PASS하지 않았습니다. SQLite 연결에서 다음을 활성화했습니다.

```sql
PRAGMA foreign_keys = ON;
```

그 후 존재하지 않는 `member_id=999`를 참조하는 rental INSERT를 실제로 실행했습니다. 결과가 `FOREIGN KEY constraint failed`로 차단되어야 테스트가 PASS하도록 `scripts/verify.py`에 검증을 넣었습니다.

따라서 이 프로젝트에서는 FK가 선언되어 있는지뿐 아니라 **잘못된 참조를 실제로 차단하는지**까지 검증했습니다. 결과는 `evidence/constraints.txt`에 남아 있습니다.

---

## Q06. 컬럼 타입은 왜 그렇게 선택했습니까?

### 모범답안

값의 의미와 앞으로 수행할 비교·계산을 기준으로 선택했습니다.

- `INTEGER`: ID, 발행연도, 요금처럼 정수 비교나 계산이 필요한 값
- `TEXT`: 이름, 제목, 이메일, ISBN, 상태 같은 문자열
- `DATE`: `joined_at`, `rented_at`, `due_at`, `returned_at`처럼 날짜 의미를 명시할 값

SQLite에는 별도의 강제 DATE storage class가 없지만 이 미션에서는 `YYYY-MM-DD` 형식으로 저장하여 날짜 의미와 정렬·범위 비교가 명확하도록 했습니다.

`returned_at`은 아직 반납하지 않은 대여의 경우 실제 값이 없기 때문에 NULL을 허용했습니다.

---

## Q07. NOT NULL, UNIQUE, CHECK 같은 제약조건은 왜 사용했습니까?

### 모범답안

잘못된 데이터가 저장되지 않도록 DB 자체에 무결성 규칙을 둔 것입니다.

- `NOT NULL`: 반드시 있어야 하는 값 보장
- `UNIQUE`: 중복되면 안 되는 값 보장
- `FOREIGN KEY`: 존재하지 않는 부모 참조 차단
- `CHECK`: 허용 범위와 상태 제한

현재 스키마에서는 이메일·ISBN·카테고리명 등에 UNIQUE를 적용하고, rental 상태는 `rented`, `returned`, `overdue`만 허용하며, 음수 fee나 비정상 발행연도도 CHECK로 차단합니다.

`verify.py`에서 FK뿐 아니라 UNIQUE, NOT NULL, CHECK 위반 입력도 실제로 실패해야 PASS하도록 검증했습니다.

---

## Q08. INNER JOIN과 LEFT JOIN의 차이는 무엇입니까?

### 모범답안

**INNER JOIN**은 양쪽 테이블에 연결되는 데이터가 모두 존재할 때만 결과에 남깁니다. Q05/Q06에서 대여 이력과 회원·도서·카테고리를 연결하는 데 사용했습니다.

**LEFT JOIN**은 왼쪽 테이블의 행을 모두 유지합니다. Q07은 `members LEFT JOIN rentals` 구조이므로 대여 이력이 없는 회원도 결과에 남습니다. 실제 seed에서 `Oh Nari`, `Seo Jun`은 `rental_count = 0`으로 확인할 수 있습니다.

한 문장으로 정리하면:

> INNER JOIN은 연결된 행만 보여주고, LEFT JOIN은 왼쪽 행을 보존하면서 연결이 없는 경우도 확인할 수 있게 합니다.

---

## Q09. GROUP BY는 어떻게 동작합니까?

### 모범답안

`GROUP BY`는 여러 행을 지정한 기준으로 묶고, 각 그룹에 `COUNT`, `SUM`, `AVG` 같은 집계 함수를 적용하기 위해 사용합니다.

현재 구현에서는:

- Q09: 회원별 대여 횟수 `COUNT`
- Q10: 카테고리별 총 fee `SUM`
- Q11: 대여 상태별 평균 fee `AVG`

를 계산합니다.

즉, **행을 그룹으로 묶은 뒤 각 그룹을 하나의 요약값으로 축약하는 과정**입니다.

---

## Q10. COUNT, SUM, AVG의 차이는 무엇입니까?

### 모범답안

```text
COUNT = 몇 개인가?
SUM   = 총 얼마인가?
AVG   = 평균 얼마인가?
```

- Q09 `COUNT(r.id)`: 회원별 대여 횟수
- Q10 `SUM(r.fee)`: 카테고리별 누적 대여 금액
- Q11 `AVG(fee)`: 대여 상태별 평균 금액

SQL 집계함수는 실제 비즈니스 질문을 숫자로 요약하는 데 사용합니다.

---

## Q11. Q12에서 서브쿼리를 왜 사용했습니까?

### 모범답안

목표는 **한 번도 대여하지 않은 회원**을 찾는 것입니다.

```sql
WHERE NOT EXISTS (
    SELECT 1
    FROM rentals AS r
    WHERE r.member_id = m.id
)
```

각 member에 대해 연결된 rental이 하나라도 있는지 내부 쿼리에서 확인하고, 존재하지 않을 때만 외부 결과에 남깁니다. 현재 데이터에서는 member 11과 12가 조회됩니다.

서브쿼리는 현재 행을 기준으로 다른 데이터 집합의 존재 여부나 계산 결과를 조건으로 사용할 때 유용합니다.

---

## Q12. UPDATE와 DELETE는 어떻게 검증했습니까?

### 모범답안

오류 없이 SQL이 실행된 것만으로 성공 처리하지 않고 **변경 후 상태(Post-condition)**까지 확인했습니다.

- Q13: rental 8을 `rented → returned`로 변경하고 `returned_at='2026-07-12'`가 되었는지 다시 SELECT
- Q14: rental 18을 DELETE한 후 `COUNT(*) = 0`인지 다시 확인

즉, 쓰기 쿼리는 실행 성공뿐 아니라 최종 데이터 상태가 의도대로 바뀌었는지를 검증해야 합니다.

---

## Q13. 인덱스를 어디에 만들었고 왜 그 컬럼을 선택했습니까?

### 모범답안

```sql
CREATE INDEX idx_rentals_status_due_at
ON rentals(status, due_at);
```

Q03/Q08에서 active rental을 `status`로 찾고 만기일 `due_at`을 확인하는 조회 패턴이 있으므로 `(status, due_at)` 복합 인덱스를 선택했습니다.

또한 Q15에서 `EXPLAIN QUERY PLAN`으로 다음과 같은 인덱스 사용을 실제로 확인했습니다.

```text
SEARCH rentals USING COVERING INDEX idx_rentals_status_due_at (status=?)
```

따라서 “평가를 위해 아무 컬럼에 인덱스를 만든 것”이 아니라 **실제 조회 패턴 → 인덱스 설계 → 실행계획 확인** 순으로 검증했습니다.

---

## Q14. 데이터베이스와 Excel의 차이는 무엇입니까?

### 모범답안

Excel은 사람이 직접 표를 작성·편집·분석하기에 편리합니다. 이 미션에서 관계형 DB의 핵심 차이는 **테이블 사이의 관계와 데이터 무결성 규칙을 스키마 수준에서 강제할 수 있다는 점**입니다.

예를 들어 `rentals.member_id`가 존재하지 않는 회원을 참조하면 FK가 저장을 차단합니다. 또한 회원 이름·이메일을 대여 기록마다 반복하지 않고 `members`에 한 번 저장한 뒤 FK로 연결하고, 필요할 때 JOIN으로 조합합니다.

---

## Q15. 작성한 쿼리 중 가장 복잡했던 쿼리는 무엇이고 어떻게 풀었습니까?

### 모범답안

Q10의 **카테고리별 총 대여 fee 계산**을 선택할 수 있습니다.

해결 순서는 다음과 같습니다.

1. `categories`에서 카테고리를 시작점으로 잡는다.
2. `books.category_id`로 category와 book을 연결한다.
3. `rentals.book_id`로 book과 rental을 연결한다.
4. `GROUP BY c.id, c.name`으로 카테고리 단위 그룹을 만든다.
5. `SUM(r.fee)`로 그룹별 총 금액을 계산한다.
6. `ORDER BY total_fee DESC`로 큰 값부터 정렬한다.

핵심 학습은 복잡한 SQL을 한 번에 쓰는 것이 아니라 **필요한 데이터 위치 → 연결 키 → 그룹 기준 → 집계 함수 → 정렬** 순서로 문제를 분해하는 것입니다.

---

## Q16. 미션 수행 중 가장 어려웠던 점과 해결 방법은 무엇입니까?

### 모범답안

가장 주의가 필요했던 부분은 SQLite의 Foreign Key enforcement였습니다. 스키마에 FK를 선언해도 연결에서 `PRAGMA foreign_keys = ON`을 켜지 않으면 기대한 제약이 적용되지 않을 수 있습니다.

그래서 다음 순서로 해결했습니다.

1. schema와 verifier 연결에서 `PRAGMA foreign_keys = ON` 적용
2. 존재하지 않는 member를 참조하는 rental INSERT 실행
3. `FOREIGN KEY constraint failed`가 발생해야 PASS하도록 자동화
4. 같은 방식으로 UNIQUE / NOT NULL / CHECK도 실패 경로 검증

이를 통해 “제약조건이 작성되어 있는가”보다 **실제로 잘못된 데이터를 차단하는가를 검증해야 한다**는 점을 확인했습니다.

---

# 보충 심화 질문

> 아래 Q17~Q21은 공식 평가문항을 새로운 요구사항으로 확장하는 것이 아니라, 앞선 평가 답변을 더 깊이 이해하기 위한 보충 질문이다.

## Q17. 왜 부모 데이터를 먼저 INSERT해야 합니까?

### 모범답안

FK를 가진 자식 행은 참조할 부모 행이 먼저 존재해야 합니다. `rentals`를 넣기 전에 해당 `member`와 `book`이 존재해야 하고, `books`를 넣기 전에 해당 `category`가 존재해야 합니다.

따라서 seed 데이터도 부모 → 자식 순서를 고려해야 하며, 이것은 참조 무결성 때문입니다.

---

## Q18. 왜 `rentals`를 별도 테이블로 만들었습니까?

### 모범답안

회원과 책은 기준 엔티티이고, 대여는 특정 시점에 반복 발생하는 사건입니다. 대여 자체에 `rented_at`, `due_at`, `returned_at`, `status`, `fee` 같은 고유 속성이 있으므로 별도의 이력 테이블이 자연스럽습니다.

한 회원은 여러 rental을 갖고, 한 책도 시간에 따라 여러 rental 기록에 등장할 수 있습니다.

---

## Q19. 왜 `returned_at`은 NULL을 허용했습니까?

### 모범답안

아직 반납되지 않은 대여는 실제 반납일이 존재하지 않습니다. 빈 문자열이나 가짜 날짜를 저장하기보다 SQL의 NULL로 “현재 값이 없음”을 표현하는 것이 의미적으로 정확합니다.

---

## Q20. 왜 모든 컬럼에 인덱스를 만들지 않습니까?

### 모범답안

인덱스는 조회 성능을 높일 수 있지만 저장공간을 사용하고 INSERT/UPDATE/DELETE 시 함께 갱신해야 합니다. 따라서 실제 검색·정렬·JOIN 패턴을 보고 필요한 컬럼에 선택적으로 적용해야 합니다.

이번 프로젝트에서는 Q03/Q08의 실제 접근 패턴 때문에 `(status, due_at)`을 선택했습니다.

---

## Q21. 이 데이터베이스 설계를 한 문장으로 설명해 보세요.

### 모범답안

> 회원·도서·카테고리 같은 기준 데이터와 반복 발생하는 대여 이력을 별도 테이블로 분리하고, PK/FK와 제약조건으로 관계와 무결성을 보장한 뒤 JOIN·GROUP BY·서브쿼리·인덱스를 이용해 필요한 업무 정보를 조회하도록 설계한 관계형 데이터베이스입니다.

---

# 공식 평가항목과 질문 매핑

| 공식 평가 영역 | 관련 질문 |
|---|---|
| 테이블 분리와 각 역할 설명 | Q01, Q02 |
| FK 기반 1:N 설명 | Q03, Q04, Q05 |
| 컬럼 타입 선택 이유 | Q06 |
| 인덱스 위치와 이유 | Q13 |
| DB와 Excel 차이 | Q14 |
| PK/FK 및 1:N | Q03, Q04 |
| INNER JOIN / LEFT JOIN | Q08 |
| GROUP BY / COUNT / SUM / AVG | Q09, Q10 |
| 가장 복잡한 쿼리 설명 | Q15 |
| 어려웠던 부분과 해결 | Q16 |

# 평가 직전 5단계 답변 공식

```text
1. 정의를 한 문장으로 말한다.
2. 현재 B5-1의 실제 table/column/query를 예로 든다.
3. 왜 그렇게 설계했는지 말한다.
4. 실제 test/evidence가 있으면 연결한다.
5. 장점과 필요한 경우 비용/제약까지 한 문장으로 정리한다.
```

# 실제 Evidence 연결

- 전체 검증: `evidence/verification-summary.txt`
- 테이블별 행 수: `evidence/row-counts.txt`
- FK/UNIQUE/NOT NULL/CHECK 실패 검증: `evidence/constraints.txt`
- Q01~Q15 실제 결과: `evidence/query-results.txt`
- 기존 개념 학습자료: `docs/learning-notes.md`
- 자동 재현: `python3 scripts/verify.py`

이 문서를 읽는 것만으로 학습 완료로 간주하지 않는다. 실제 평가에서는 위 답안을 그대로 암기하기보다 **현재 스키마와 Evidence를 보면서 자기 말로 다시 설명할 수 있어야 한다.**
