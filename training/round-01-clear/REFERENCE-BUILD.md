# B5-1 R01 — Reference Build

## 목적

공식 Mission/Evaluation을 기준으로 **백엔드 프레임워크 없이 SQLite + SQL만 사용해 관계형 데이터베이스를 설계·입력·조회·수정·삭제하는 Reference Complete Version**을 준비합니다.

Reference Build가 완료되어도 Phase C에서 실제 SQLite 실행 결과, Q01~Q16 결과, 제약조건 동작, Evidence를 확인하기 전에는 `✅ CLEAR`로 판정하지 않습니다.

## Source of Truth

1. `b5-1-mission.pdf`
2. `b5-1-mission.md`
3. `b5-1-evaluation.md`

## Reference 도메인

**도서 대여 관리 (Library Rental)**

관계:

```text
categories 1 ── N books 1 ── N rentals N ── 1 members
```

4개 테이블:

- `members`
- `categories`
- `books`
- `rentals`

## 설계 결정

- DB: SQLite
- `PRAGMA foreign_keys = ON`
- 모든 테이블 PK
- FK 3개 / 1:N 3개
- NOT NULL / UNIQUE / CHECK
- 각 테이블 10행 이상 sample data
- Query 총 16개(Q01~Q16)
- 기본 조회 4+, JOIN 4+, INNER 2+, LEFT 1+
- 집계 3+, COUNT/AVG + GROUP BY
- Subquery / correlated subquery
- UPDATE / DELETE
- CREATE INDEX + 적용 이유 + Query Plan
- UPDATE/DELETE는 SAVEPOINT 후 rollback하여 seed 상태 보존
- SQLite 날짜는 ISO-format TEXT 사용

## Reference Complete Path

1. Domain/ERD 이해
2. `schema.sql`
3. `seed.sql`
4. row/FK/NOT NULL/UNIQUE 검증
5. `queries.sql` Q01~Q16
6. 보조 `indexes.sql`
7. fresh DB 자동 `verify.sh`
8. Evaluation Q&A
9. Phase C `run-reference.sh`
10. 실제 Runtime Evidence
11. CLEAR

## 주요 파일

```text
training/round-01-clear/
├── REFERENCE-BUILD.md
├── REFERENCE-STATUS.md
├── BEGINNER-GUIDE.md
├── CHECKLIST.md
├── reference/sql/
│   ├── schema.sql
│   ├── seed.sql
│   ├── queries.sql
│   └── indexes.sql
├── environment/
│   ├── verify.sh
│   └── run-reference.sh
├── docs/
│   ├── erd.md
│   ├── requirements-mapping.md
│   └── evaluation-qa.md
└── evidence/README.md
```

## 상태

**Reference Build: CORE READY**  
**Runtime Mission: ⬜ NOT STARTED**

실제 실행 결과가 없는 항목은 PASS로 표시하지 않습니다.
