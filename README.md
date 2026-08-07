# Codyssey Basic B5-1 — SQL Database

**정보를 깔끔하게 정리하는 디지털 서랍장 만들기**

백엔드 프레임워크 없이 SQLite로 관계형 데이터 모델을 설계하고, schema → seed → query → evidence 흐름을 재현 가능하게 구현한 B5-1 결과물입니다.

## 구현 주제

학습 도서 대여 데이터베이스

- `categories`: 도서 분류
- `members`: 회원
- `books`: 도서
- `rentals`: 대여 이력

관계:

```text
categories 1 ─── N books
members    1 ─── N rentals
books      1 ─── N rentals
```

총 4개 table, 3개 FK 관계를 사용합니다.

## 요구사항 대응 요약

| 요구 | 구현 |
|---|---|
| 4개 이상 table + 각 PK | 4 tables, 모두 `id INTEGER PRIMARY KEY` |
| FK 2+ / 1:N 2+ | 3 FK / 3개의 1:N |
| NOT NULL / UNIQUE / FK 실효성 | schema constraint + 실제 실패 테스트 |
| table별 10행+ | categories 10, members 12, books 15, rentals 18 |
| 기본 조회 4 | Q01-Q04 |
| JOIN 4 | Q05-Q08, INNER 2+ / LEFT 1+ 포함 |
| 집계 3 | Q09-Q11 (`COUNT`, `SUM`, `AVG`) |
| subquery 1 | Q12 |
| UPDATE / DELETE 2 | Q13-Q14 |
| index 1 | Q15, `(status, due_at)` + query plan 확인 |
| query별 결과 | `evidence/query-results.txt` |

## Repository 구조

```text
.
├── AGENTS.md
├── MISSION-WORK-PACKET.md
├── README.md
├── b5-1-evaluation.md
├── b5-1-mission.md
├── b5-1-mission.pdf
├── docs/
│   └── learning-notes.md
├── evidence/
│   ├── constraints.txt
│   ├── query-results.txt
│   ├── row-counts.txt
│   └── verification-summary.txt
├── scripts/
│   └── verify.py
└── sql/
    ├── 01_schema.sql
    ├── 02_seed.sql
    └── 03_queries.sql
```

## 가장 빠른 실행 방법

필요 환경: Python 3 표준 라이브러리의 `sqlite3` 모듈. 별도 Python package 설치는 필요하지 않습니다.

```bash
python3 scripts/verify.py
```

스크립트는 다음을 순서대로 수행합니다.

1. `build/b5-1.sqlite3`를 새로 생성
2. schema 전체 적용
3. seed data 입력
4. table/FK/row count 확인
5. FK/UNIQUE/NOT NULL/CHECK 위반이 실제로 차단되는지 확인
6. Q01~Q15 실행
7. UPDATE/DELETE postcondition 확인
8. index 생성 확인
9. 실제 결과를 `evidence/`에 기록

정상 종료 예:

```text
PASS | schema rebuild
PASS | tables=4
PASS | foreign_keys=3
PASS | each seeded table has >=10 rows
PASS | query_groups=15
PASS | index created
```

## SQL 파일 직접 실행 순서

SQLite CLI가 설치되어 있다면 다음 순서로도 확인할 수 있습니다.

```bash
mkdir -p build
sqlite3 build/manual.sqlite3 < sql/01_schema.sql
sqlite3 build/manual.sqlite3 < sql/02_seed.sql
sqlite3 -header -column build/manual.sqlite3 < sql/03_queries.sql
```

SQLite에서는 연결마다 FK enforcement가 필요하므로 SQL 파일과 verifier에서 `PRAGMA foreign_keys = ON;`을 명시합니다.

## Query Coverage

- Q01-Q04: Basic SELECT
- Q05-Q08: JOIN
- Q09-Q11: Aggregate / GROUP BY
- Q12: Subquery
- Q13: UPDATE
- Q14: DELETE
- Q15: CREATE INDEX + index 확인 + `EXPLAIN QUERY PLAN`

각 Q 설명과 실제 실행 결과는 `sql/03_queries.sql`과 `evidence/query-results.txt`가 1:1로 대응합니다.

## 평가 설명 준비

`docs/learning-notes.md`에서 다음을 현재 구현 기준으로 설명합니다.

- DB와 Excel의 차이
- table 분리 이유
- PK/FK/1:N
- column type 선택
- INNER JOIN vs LEFT JOIN
- GROUP BY / COUNT / SUM / AVG
- subquery
- index 선택 이유
- 가장 복잡한 query(Q10) 풀이
- 미션 중 어려웠던 부분과 해결 방법

## Source

- [원본 Mission PDF](./b5-1-mission.pdf)
- [Mission Markdown](./b5-1-mission.md)
- [Evaluation](./b5-1-evaluation.md)
- [Mission Work Packet](./MISSION-WORK-PACKET.md)

## Scope

이 미션은 SQL-only 범위입니다. Spring/Django/Express 같은 backend framework, API/UI, View/Procedure/Trigger는 구현하지 않습니다.
