# B5-1 Database Design Reference

## 도메인

도서 대여 관리.

```text
categories 1 ── N books 1 ── N rentals N ── 1 members
```

상세 관계는 `../docs/erd.md`를 참고합니다.

## 파일

- `sql/schema.sql` — PK/FK/NOT NULL/UNIQUE/CHECK
- `sql/seed.sql` — 각 테이블 10행 이상
- `sql/queries.sql` — 공식 범위를 포함한 Q01~Q16
- `sql/indexes.sql` — 추가 FK/JOIN index + `EXPLAIN QUERY PLAN`

## 안전한 실행

기존 개인 DB가 아니라 임시 DB를 사용합니다.

```bash
export B5_DB=/tmp/codyssey-b5-1.sqlite3
rm -f "$B5_DB"
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/schema.sql
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/seed.sql
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/queries.sql
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/indexes.sql
```

또는 Phase C에서 Evidence를 함께 만들려면:

```bash
bash training/round-01-clear/environment/run-reference.sh
```

## Q01~Q16 범위

```text
Q01~Q04  BASIC
Q05~Q08  JOIN
Q09~Q11  AGGREGATE
Q12~Q13  SUBQUERY
Q14~Q15  UPDATE / DELETE
Q16      INDEX
```

공식 요구의 “총 15개 이상”을 만족시키면서 index도 같은 Query 파일 안에서 명확히 증명하도록 16개로 구성했습니다.

## UPDATE / DELETE

Q14/Q15는 `SAVEPOINT` 안에서 실제 변경/삭제 결과를 확인한 뒤 rollback합니다. 따라서 다음 Query나 재실행에서 seed dataset이 변하지 않습니다.

## Index

Q16은 `books.category_id`에 index를 생성하고 적용 이유를 주석으로 기록합니다. `indexes.sql`은 추가로 `rentals.member_id`, `rentals.book_id` index를 제공하며 SQLite Query Plan 확인 예시를 포함합니다.

## 검증

```bash
bash training/round-01-clear/environment/verify.sh
```

Runtime Evidence까지 확인할 때만:

```bash
bash training/round-01-clear/environment/verify.sh --runtime
```
