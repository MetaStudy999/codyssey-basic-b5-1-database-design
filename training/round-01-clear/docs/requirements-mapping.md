# B5-1 R01 — Requirement / Implementation / Verification / Evidence

| ID | Requirement | Reference Implementation | Verification | Evidence |
|---|---|---|---|---|
| R01 | 실행 가능한 DB 환경 | SQLite | `verify.sh` | sqlite version/result |
| R02 | 최소 4개 테이블 | members/categories/books/rentals | sqlite schema | `.schema` |
| R03 | 각 테이블 PK | `schema.sql` | pragma | schema |
| R04 | 1:N 관계 2개 이상 | category-books, member-rentals, book-rentals | FK pragma | ERD/schema |
| R05 | FK 2개 이상 | 3 FKs | invalid FK insert | verify result |
| R06 | NOT NULL | 주요 필드 | schema review | schema |
| R07 | UNIQUE | member email/category name | index/schema | verify result |
| R08 | meaningful data types | TEXT/INTEGER/date text | schema | schema/Q&A |
| R09 | 각 테이블 10행 이상 | `seed.sql` | COUNT(*) | row counts |
| R10 | 관계 있는 sample data | rentals FK references | JOIN/query | output |
| R11 | Query 15개 | `queries.sql` | marker count/execute | outputs |
| R12 | SELECT/filter/search/sort | Q01-Q04 | execute | outputs |
| R13 | JOIN | Q05-Q07 | execute | outputs |
| R14 | GROUP BY/HAVING/aggregate | Q07-Q10 | execute | outputs |
| R15 | subquery | Q11-Q13 | execute | outputs |
| R16 | UPDATE | Q14 | savepoint/runtime | before/after |
| R17 | DELETE | Q15 | savepoint/runtime | before/after |
| R18 | index concept/application | `indexes.sql` | sqlite_master/EXPLAIN | query plan |
| R19 | schema/seed/query 재현 가능 | SQL files | fresh DB verify | verify result |
| R20 | 설계/SQL 설명 | `evaluation-qa.md` | user explanation | evaluator check |

## Runtime Evidence 원칙

15개 Query는 실제 결과 텍스트 또는 screenshot으로 남깁니다. UPDATE/DELETE는 Before/After를 확인하되 Reference seed 상태를 보존하도록 rollback을 사용합니다.
