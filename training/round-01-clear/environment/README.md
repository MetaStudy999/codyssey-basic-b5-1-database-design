# B5-1 R01 Environment

## Golden Path

- SQLite 3 CLI
- 백엔드 프레임워크 없음
- SQL만으로 schema / sample data / queries / indexes 수행

## Reference 파일

```text
reference/sql/
├── schema.sql
├── seed.sql
├── queries.sql
└── indexes.sql
```

## 새 실습 DB 생성

```bash
export B5_DB=/tmp/codyssey-b5-1.sqlite3
rm -f "$B5_DB"
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/schema.sql
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/seed.sql
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/indexes.sql
```

15개 Query:

```bash
sqlite3 "$B5_DB" < training/round-01-clear/reference/sql/queries.sql
```

## 자동 검증

```bash
bash training/round-01-clear/environment/verify.sh
```

`verify.sh`는 `/tmp`의 임시 SQLite DB만 생성/삭제합니다. 기존 개인 DB를 수정하지 않습니다.
