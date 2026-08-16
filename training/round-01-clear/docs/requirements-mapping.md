# B5-1 R01 — Requirement / Implementation / Verification / Evidence

| ID | Requirement | Reference Implementation | Verification | Evidence |
|---|---|---|---|---|
| R01 | 로컬 실행 가능한 DB | SQLite 3 CLI | `verify.sh` | sqlite version |
| R02 | 최소 4개 테이블 | `members/categories/books/rentals` | sqlite schema/table count | `constraints.txt` |
| R03 | 각 테이블 PK | `schema.sql` | `pragma_table_info` | schema |
| R04 | 1:N 관계 2개 이상 | category→books, member→rentals, book→rentals | FK/schema review | ERD/schema |
| R05 | FK 2개 이상 + 실제 enforcement | FK 3개 + `PRAGMA foreign_keys=ON` | invalid parent INSERT | `constraints.txt` |
| R06 | NOT NULL | 주요 필수 컬럼 | invalid NULL INSERT / schema | verify |
| R07 | UNIQUE | member email/category name | duplicate INSERT / pragma | verify |
| R08 | 의미 있는 컬럼 타입 | INTEGER/TEXT + ISO date text | schema/Q&A | schema/evaluation |
| R09 | 각 테이블 10행 이상 | `seed.sql` | `COUNT(*)` | `constraints.txt` |
| R10 | 관계 있는 sample data | rentals가 member/book FK 참조 | JOIN/FK checks | query output |
| R11 | 총 Query 15개 이상 | `queries.sql` Q01~Q16 | marker count/execute | `query-results.txt` |
| R12 | 기본 조회 4개 이상 | Q01~Q04 | category marker + execute | Q01~Q04 output |
| R13 | JOIN 4개 이상 | Q05~Q08 | category marker | Q05~Q08 output |
| R14 | INNER JOIN 2개 이상 | Q05/Q06 외 추가 사용 | explicit keyword count | output/code |
| R15 | LEFT JOIN 1개 이상 | Q07/Q08 | explicit keyword count | output/code |
| R16 | 집계 3개 이상 | Q09~Q11 | category marker | Q09~Q11 output |
| R17 | COUNT/SUM/AVG 중 2종 이상 | COUNT + AVG | static coverage | Q09~Q11 output |
| R18 | GROUP BY | Q09~Q11 | static/execute | output |
| R19 | 서브쿼리 1개 이상 | Q12/Q13 | category marker | output |
| R20 | UPDATE | Q14 | SAVEPOINT + before/after | output |
| R21 | DELETE | Q15 | SAVEPOINT + before/after | output |
| R22 | CREATE INDEX + 이유 | Q16 `idx_books_category_id` | sqlite_master | `index-plan.txt` |
| R23 | Query별 한 줄 설명 | Q01~Q16 comment/print header | document review | SQL/result headings |
| R24 | 실행 결과 텍스트/캡처 | runtime runner | `verify.sh --runtime` | `evidence/runtime/*` |
| R25 | 재현 가능한 실행 순서 | schema→seed→queries→indexes | fresh temp DB | verify output |
| R26 | 평가 설명 | `evaluation-qa.md` | user explanation | `evaluation.md` |

## 제출물 대응

공식 제출물은 다음과 연결합니다.

- 스키마 생성 SQL 1개: `reference/sql/schema.sql`
- 샘플 데이터 SQL 1개: `reference/sql/seed.sql`
- Query 15개 이상 SQL 1개: `reference/sql/queries.sql` (Q01~Q16)
- 결과 캡처/텍스트: Phase C의 `evidence/runtime/query-results.txt`, `constraints.txt`, `index-plan.txt`
- 선택 ERD: `docs/erd.md`

`indexes.sql`은 Q16 외에 FK/JOIN용 추가 index와 Query Plan 실습을 위한 보조 파일입니다. 공식 index 요구 자체는 `queries.sql` Q16에서 충족하도록 했습니다.

## Runtime Evidence 원칙

Reference 코드/SQL 존재만으로 PASS 처리하지 않습니다. Phase C에서 fresh DB를 만들고 실제 Q01~Q16 출력, FK/NOT NULL/UNIQUE 동작, index plan, 평가 설명을 확인한 뒤 CLEAR합니다.
