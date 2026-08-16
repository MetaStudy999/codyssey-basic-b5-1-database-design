# B5-1 R01 — Evaluation Q&A Reference

## 1. DB와 Excel의 핵심 차이는 무엇인가?

행 수 자체보다 **관계와 무결성 규칙**을 구조적으로 표현하고 강제할 수 있다는 점이 중요합니다. PK/FK/UNIQUE/NOT NULL 같은 제약과 JOIN을 통해 여러 테이블의 데이터를 일관되게 연결할 수 있습니다.

## 2. 왜 테이블을 나누었는가?

회원 이름/이메일, 도서 정보, 카테고리 이름을 대여 기록마다 반복 저장하면 중복과 수정 불일치가 생깁니다. 역할별 테이블로 분리하고 `rentals`가 FK로 회원/도서를 참조하게 해 중복을 줄였습니다.

## 3. PK와 FK의 차이는?

PK는 한 테이블의 각 행을 유일하게 식별합니다. FK는 다른 테이블의 PK/UNIQUE 값을 참조해 관계를 연결하며 존재하지 않는 부모를 참조하지 못하게 합니다.

## 4. 1:N 관계를 코드에서 어떻게 확인할 수 있는가?

`categories.id` 하나를 여러 `books.category_id`가 참조할 수 있어 category→books가 1:N입니다. 같은 방식으로 한 member가 여러 rentals를 가질 수 있습니다.

## 5. 왜 `PRAGMA foreign_keys = ON`이 필요한가?

SQLite는 연결별로 FK enforcement를 활성화해야 합니다. schema에 FOREIGN KEY만 작성하고 PRAGMA를 켜지 않으면 기대한 참조 무결성 검증이 실제로 동작하지 않을 수 있습니다.

## 6. INNER JOIN과 LEFT JOIN은 언제 다른가?

INNER JOIN은 양쪽에 연결 행이 있는 경우만 반환합니다. LEFT JOIN은 왼쪽 행을 모두 유지하므로 대여 기록이 0건인 회원도 포함해 보고 싶을 때 적합합니다.

## 7. GROUP BY와 HAVING의 차이는?

`WHERE`는 grouping 전에 개별 행을 필터링하고, `HAVING`은 GROUP BY로 만든 그룹/집계 결과를 필터링합니다. 예를 들어 `COUNT(r.id) >= 2`인 회원만 선택할 때 HAVING을 사용합니다.

## 8. subquery는 왜 필요한가?

한 Query의 결과를 다른 Query의 조건으로 사용할 때 유용합니다. `Database` 카테고리의 id를 먼저 찾고 그 id에 속한 books를 조회하는 식으로 요구사항을 단계적으로 표현할 수 있습니다.

## 9. correlated subquery는 무엇인가?

바깥 Query의 현재 행 값을 안쪽 Query가 참조하는 subquery입니다. Reference Q13은 각 book 행마다 `r.book_id = b.id` 조건으로 누적 대여 횟수를 계산합니다.

## 10. UPDATE/DELETE를 왜 SAVEPOINT 안에서 실습하는가?

실제 변경 결과는 확인하면서 Reference sample dataset은 다음 Query/재실행에도 동일하게 유지하기 위해서입니다. 변경 후 SELECT로 결과를 확인하고 rollback하여 seed 상태로 복구합니다.

## 11. index는 왜 필요한가?

행이 많아질수록 조건 검색/JOIN에서 전체 table scan 비용이 커질 수 있습니다. FK/JOIN 조건에 자주 사용하는 컬럼에 index를 두면 DB가 후보 행을 더 빠르게 찾을 수 있습니다. 단, index는 저장공간과 INSERT/UPDATE 비용을 추가하므로 무조건 많이 만들면 좋은 것은 아닙니다.

## 12. 왜 FK 컬럼에 index를 두었는가?

`rentals.member_id`, `rentals.book_id`, `books.category_id`는 JOIN과 필터에 반복 사용됩니다. 부모 row 삭제/조회나 관계 Query에서도 자주 탐색되므로 index 후보가 됩니다.

## 13. `EXPLAIN QUERY PLAN`은 무엇을 보는가?

SQLite가 Query를 어떤 방식으로 실행하려는지 보여 줍니다. TABLE SCAN인지 INDEX SEARCH인지 확인해 index가 실제 계획에 사용되는지 판단할 수 있습니다.

## 14. 데이터가 커지면 지금 설계에서 무엇을 개선할 수 있는가?

업무 요구에 따라 복합 index, 날짜/상태 컬럼 타입/제약 강화, transaction 범위, pagination, query plan 분석, archive 정책 등을 검토할 수 있습니다. 하지만 B5-1에서는 PK/FK/관계/JOIN/집계의 기초 원리를 우선합니다.
