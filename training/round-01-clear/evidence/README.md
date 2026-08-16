# B5-1 R01 — Evidence Guide

## 1. 환경 / Schema

```bash
sqlite3 --version
sqlite3 "$B5_DB" '.schema'
```

Evidence:

- 4개 table
- PK/FK
- NOT NULL / UNIQUE / CHECK

## 2. Row Count

```sql
SELECT 'members', COUNT(*) FROM members;
SELECT 'categories', COUNT(*) FROM categories;
SELECT 'books', COUNT(*) FROM books;
SELECT 'rentals', COUNT(*) FROM rentals;
```

각 table 10행 이상을 실제 확인합니다.

## 3. FK 검증

존재하지 않는 category를 참조하는 book INSERT가 실패하는지 확인합니다. 실제 운영 데이터가 아닌 별도 실습 DB에서 수행합니다.

## 4. Query 15개

`queries.sql`의 Q01~Q15 결과를 번호와 함께 저장합니다.

권장:

```bash
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/queries.sql \
  | tee training/round-01-clear/evidence/query-results.txt
```

## 5. Index / Query Plan

```bash
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/indexes.sql
```

index 목록과 `EXPLAIN QUERY PLAN` 결과를 저장합니다.

## 6. 자동 Verify

```bash
bash training/round-01-clear/environment/verify.sh
```

실제 `Result: N PASS / 0 FAIL`을 Evidence로 사용합니다.

## CLEAR

SQL 파일 존재만으로 CLEAR하지 않습니다. fresh DB에서 schema→seed→indexes→queries 순서가 실제 재현되고 15개 결과와 FK/제약조건이 확인되어야 합니다.
