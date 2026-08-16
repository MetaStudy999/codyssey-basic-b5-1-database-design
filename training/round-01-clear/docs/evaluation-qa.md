# B5-1 R01 — Evaluation Q&A Reference

이 문서는 정답을 외우기 위한 문서가 아니라, Phase C에서 **본인이 만든 스키마와 실제 실행 결과를 근거로 자기 말로 설명하기 위한 기준**입니다.

## 1. DB와 Excel의 핵심 차이는 무엇인가?

행 수 자체보다 **관계와 무결성 규칙**을 구조적으로 표현하고 강제할 수 있다는 점이 중요합니다. PK/FK/UNIQUE/NOT NULL 같은 제약과 JOIN을 통해 여러 테이블의 데이터를 일관되게 연결할 수 있습니다.

## 2. 왜 테이블을 나누었는가?

회원 이름/이메일, 도서 정보, 카테고리 이름을 대여 기록마다 반복 저장하면 중복과 수정 불일치가 생깁니다. 역할별 테이블로 분리하고 `rentals`가 FK로 회원/도서를 참조하게 해 중복을 줄였습니다.

## 3. 각 테이블의 역할은 무엇인가?

- `members`: 회원의 식별 정보
- `categories`: 도서 분류
- `books`: 도서 자체의 속성
- `rentals`: 누가 어떤 책을 언제 빌리고 반납했는지 기록하는 사건 데이터

특히 `rentals`는 회원과 도서를 FK로 연결하여 실제 서비스의 대여 행위를 표현합니다.

## 4. PK와 FK의 차이는?

PK는 한 테이블의 각 행을 유일하게 식별합니다. FK는 다른 테이블의 PK/UNIQUE 값을 참조해 관계를 연결하며 존재하지 않는 부모를 참조하지 못하게 합니다.

## 5. 1:N 관계를 코드에서 어떻게 확인할 수 있는가?

`categories.id` 하나를 여러 `books.category_id`가 참조할 수 있어 category→books가 1:N입니다. 같은 방식으로 member→rentals, book→rentals도 1:N입니다.

## 6. 왜 이런 컬럼 타입을 선택했는가?

식별자는 비교와 JOIN이 쉬운 `INTEGER`, 이름·이메일·제목은 가변 문자열인 `TEXT`, 출판연도는 계산/비교 가능한 `INTEGER`를 사용했습니다. SQLite Reference에서는 날짜를 ISO 형식의 `TEXT`로 저장합니다. `YYYY-MM-DD`처럼 형식을 일관되게 유지하면 기본적인 날짜 정렬과 문자열 정렬이 같은 순서를 가집니다. MySQL/PostgreSQL을 사용한다면 `DATE`, `TIMESTAMP` 같은 전용 타입을 선택할 수 있습니다.

## 7. 왜 `PRAGMA foreign_keys = ON`이 필요한가?

SQLite는 연결별로 FK enforcement를 활성화해야 합니다. schema에 FOREIGN KEY만 작성하고 PRAGMA를 켜지 않으면 기대한 참조 무결성 검증이 실제로 동작하지 않을 수 있습니다.

## 8. INNER JOIN과 LEFT JOIN은 언제 다른가?

INNER JOIN은 양쪽에 연결 행이 있는 경우만 반환합니다. LEFT JOIN은 왼쪽 행을 모두 유지하므로 대여 기록이 0건인 회원도 포함해 보고 싶을 때 적합합니다. Reference Q05/Q06은 INNER JOIN, Q07/Q08은 LEFT JOIN의 차이를 실제 결과로 확인할 수 있습니다.

## 9. GROUP BY와 집계 함수는 어떻게 동작하는가?

`GROUP BY`는 같은 기준값을 가진 행을 그룹으로 묶고, `COUNT`, `AVG` 같은 집계 함수가 각 그룹을 하나의 요약값으로 만듭니다. Q09~Q11에서 회원 또는 카테고리 단위 집계를 확인할 수 있습니다.

`WHERE`는 grouping 전에 개별 행을 필터링하고, `HAVING`은 grouping 후 집계 결과를 필터링합니다. Q09는 `HAVING COUNT(r.id) >= 2`로 대여 2회 이상인 회원만 선택합니다.

## 10. subquery는 왜 필요한가?

한 Query의 결과를 다른 Query의 조건으로 사용할 때 유용합니다. Q12는 `Database` 카테고리의 id를 안쪽 Query에서 찾고 그 id에 속한 books를 바깥 Query에서 조회합니다.

## 11. correlated subquery는 무엇인가?

바깥 Query의 현재 행 값을 안쪽 Query가 참조하는 subquery입니다. Reference Q13은 각 book 행마다 `r.book_id = b.id` 조건으로 누적 대여 횟수를 계산합니다.

## 12. UPDATE/DELETE를 왜 SAVEPOINT 안에서 실습하는가?

실제 변경 결과는 확인하면서 Reference sample dataset은 다음 Query/재실행에도 동일하게 유지하기 위해서입니다. 변경 후 SELECT로 결과를 확인하고 rollback하여 seed 상태로 복구합니다.

## 13. index는 왜 필요한가?

행이 많아질수록 조건 검색/JOIN에서 전체 table scan 비용이 커질 수 있습니다. FK/JOIN 조건에 자주 사용하는 컬럼에 index를 두면 DB가 후보 행을 더 빠르게 찾을 수 있습니다. 단, index는 저장공간과 INSERT/UPDATE 비용을 추가하므로 무조건 많이 만들면 좋은 것은 아닙니다.

## 14. 왜 `books.category_id`에 index를 두었는가?

도서와 카테고리를 연결하는 JOIN과 카테고리 조건 검색에서 반복적으로 사용됩니다. Q16은 이 컬럼에 `CREATE INDEX`를 수행하고 SQLite의 `EXPLAIN QUERY PLAN`으로 실행 계획을 확인합니다. 보조 `indexes.sql`에서는 `rentals.member_id`, `rentals.book_id`도 추가 index 후보로 보여 줍니다.

## 15. 가장 복잡했던 Query를 어떻게 설명할 것인가?

예를 들어 Q09를 선택할 수 있습니다.

1. `members`와 `rentals`를 `member_id`로 연결합니다.
2. 회원별로 `GROUP BY` 합니다.
3. 각 그룹의 대여 건수를 `COUNT(r.id)`로 계산합니다.
4. `HAVING COUNT(r.id) >= 2`로 집계 결과를 필터링합니다.
5. 마지막으로 대여 횟수와 회원 id 기준으로 정렬합니다.

핵심은 SQL을 한 번에 외우는 것이 아니라 **원하는 결과 → 필요한 테이블 → 관계 → 그룹 → 조건 → 정렬** 순서로 분해하는 것입니다.

## 16. 수행 중 가장 어려울 수 있는 부분과 해결 방법은?

대표적인 난점은 FK 입력 순서입니다. 자식인 `rentals`를 먼저 넣으면 참조할 `members`/`books`가 없어서 FK 오류가 납니다. 해결은 부모 테이블을 먼저 입력하고 자식을 나중에 입력하는 것입니다. `schema.sql → seed.sql` 실행 순서를 고정하고, `verify.sh`에서 없는 부모를 참조하는 INSERT가 실제로 실패하는지 확인하면 선언만 한 FK인지 실제 동작하는 FK인지 구분할 수 있습니다.

## 17. 데이터가 커지면 무엇을 개선할 수 있는가?

업무 요구에 따라 복합 index, 날짜/상태 컬럼 타입과 제약 강화, transaction 범위, pagination, query plan 분석, archive 정책 등을 검토할 수 있습니다. 하지만 B5-1에서는 PK/FK/관계/JOIN/집계의 기초 원리를 우선합니다.

## Phase C 답변 원칙

평가에서는 위 문장을 그대로 암기하지 않습니다. `schema.sql`, Q01~Q16 실제 출력, FK 실패 결과를 보면서 **왜 그렇게 설계했고 결과가 무엇을 의미하는지** 자기 말로 설명합니다.
