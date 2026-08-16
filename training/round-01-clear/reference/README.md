# B5-1 Database Design Reference

## 도메인

도서 대여 관리.

```text
categories 1 ── N books 1 ── N rentals N ── 1 members
```

## 파일

- `sql/schema.sql` — PK/FK/NOT NULL/UNIQUE/CHECK
- `sql/seed.sql` — 각 테이블 10행 이상
- `sql/queries.sql` — 번호가 붙은 핵심 Query 15개
- `sql/indexes.sql` — FK/JOIN index + `EXPLAIN QUERY PLAN`

## 실행

```bash
export B5_DB=/tmp/codyssey-b5-1.sqlite3
rm -f "$B5_DB"
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/schema.sql
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/seed.sql
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/indexes.sql
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/queries.sql
```

## 설계 이유

회원/카테고리/도서/대여를 한 표에 반복 저장하지 않고 역할별 테이블로 나누어 중복을 줄이고 FK로 관계를 표현합니다. `rentals`는 회원과 도서 사이의 실제 대여 사건을 기록합니다.

## Query 15개 범위

- 기본 SELECT / WHERE / LIKE / ORDER BY
- INNER JOIN / LEFT JOIN
- GROUP BY / HAVING / MIN/MAX/AVG
- subquery / correlated subquery
- UPDATE / DELETE

UPDATE/DELETE는 `SAVEPOINT`에서 실행 결과를 확인한 뒤 rollback하여 seed 상태를 유지합니다.

## Index

FK/JOIN에 자주 쓰는 `books.category_id`, `rentals.member_id`, `rentals.book_id`에 index를 둡니다. 작은 sample DB에서는 속도 차이가 눈에 띄지 않을 수 있으므로 `EXPLAIN QUERY PLAN`으로 사용 계획을 함께 확인합니다.
