# B5-1 R01 — Reference Build

## 목적

공식 Mission/Evaluation을 기준으로 **백엔드 프레임워크 없이 SQLite + SQL만 사용해 관계형 데이터베이스를 설계·입력·조회·수정·삭제하는 Reference Complete Version**을 준비합니다.

Reference Build가 완료되어도 Phase C에서 실제 SQLite 실행 결과, 15개 Query 결과, FK/제약조건 동작, Evidence를 확인하기 전에는 `✅ CLEAR`로 판정하지 않습니다.

## Source of Truth

1. `b5-1-mission.pdf`
2. `b5-1-mission.md`
3. `b5-1-evaluation.md`

## Reference 도메인

**도서 대여 관리 (Library Rental)**

4개 테이블:

- `members`
- `categories`
- `books`
- `rentals`

관계:

- `categories 1:N books`
- `members 1:N rentals`
- `books 1:N rentals`

## Reference 설계 결정

- DB: SQLite
- `PRAGMA foreign_keys = ON`
- 모든 테이블 PK
- FK 3개
- NOT NULL / UNIQUE / CHECK 적용
- 각 테이블 10행 이상 sample data
- Query 15개를 번호/목적과 함께 고정
- JOIN / GROUP BY / HAVING / aggregate / subquery / correlated subquery / UPDATE / DELETE 포함
- UPDATE/DELETE 학습 Query는 SAVEPOINT 후 rollback하여 seed 상태를 보존
- FK/index 컬럼에 index 추가
- `EXPLAIN QUERY PLAN` 예시 제공

## Reference Complete Path

1. Domain/ERD 이해
2. `schema.sql`
3. `seed.sql`
4. row/FK/constraint 검증
5. `queries.sql` 15개
6. `indexes.sql`
7. 자동 verify
8. Evaluation Q&A
9. 실제 Query 결과 Evidence
10. CLEAR

## 상태

**Reference Build 진행 중 / Mission 상태 ⬜ NOT STARTED / Runtime 미시작**
