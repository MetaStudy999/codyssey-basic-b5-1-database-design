# B5-1 Mission Work Packet

> 하나의 B5-1 Workcell 실행 계약이다. Control Tower는 READ ONLY이고 이 저장소만 수정한다.

## 1. Identity

- Mission ID: `B5-1`
- Mission Title: 정보를 깔끔하게 정리하는 디지털 서랍장 만들기
- Mission Repository: `MetaStudy999/codyssey-basic-b5-1-database-design`
- Workcell: `Chat 09 / B5-1`
- Started At: `2026-08-08T04:37:00+09:00`

## 2. Control Tower Baseline

- Control Tower Repository: `MetaStudy999/codyssey-basic`
- Frozen Baseline SHA: `0d1581b3e82366988f57e1d76da311c028b8e15e`
- Active Wave: `config/waves/20260808-01.yaml`
- Starter Packet: `docs/00-governance/work-packets/b5-1.md`
- Baseline Rule: 이 Workcell 동안 임의 변경하지 않는다.

적용 Governance:
- `AGENTS.md`
- `docs/00-governance/multi-agent-mission-engineering.md`
- `docs/00-governance/source-discovery-fallback-protocol.md`
- `docs/00-governance/parallel-mission-execution.md`
- `docs/00-governance/work-packets/b5-1.md`

## 3. Read / Write Boundary

### READ
- frozen Control Tower baseline
- 현재 Mission Repository
- B5-1 공식 Source

### WRITE
- `MetaStudy999/codyssey-basic-b5-1-database-design`만

### DO NOT WRITE
- `MetaStudy999/codyssey-basic`
- 다른 Mission Repository

## 4. G1 Source Inventory

| Source Candidate | Type | State | Location | Notes |
|---|---|---|---|---|
| Mission 원본 | PDF | `VALID` | `b5-1-mission.pdf` | 6쪽, 실질 요구사항 확인 |
| Mission Markdown | MD | `DUPLICATE` | `b5-1-mission.md` | PDF 내용을 구조화한 사본 |
| Evaluation | MD | `VALID` | `b5-1-evaluation.md` | 실질 평가 체크리스트 확인 |
| 공식 과정 분류 | MD | `VALID` | Control Tower mission index | B5-1 필수, DB & Back-end, 40h |

- Source Mode: `FULL SOURCE`
- Source Confidence: `MEDIUM`
- Source Gaps:
  - 별도 Evaluation PDF/raw artifact는 발견되지 않았다. 현재 저장소의 `b5-1-evaluation.md`를 평가 기준으로 사용한다.
- Conflict: `NONE`

## 5. Mission Contract

### Goal

백엔드 프레임워크 없이 관계형 데이터베이스를 직접 설계하고, `schema → seed → query → result evidence` 흐름을 재현 가능하게 완성한다.

### Required Deliverables

- [x] schema 생성 SQL 1개
- [x] sample INSERT SQL 1개
- [x] 핵심 query 15개 SQL 1개
- [x] query별 실행 결과 text evidence
- [x] 최소 4개 table, 각 table PK
- [x] 최소 2개 이상의 FK 기반 1:N
- [x] 각 table 10행 이상의 의미 있는 sample data

### Required Functions / Behaviors

- [x] `NOT NULL` 최소 1개
- [x] `UNIQUE` 최소 1개
- [x] 실제 FK 위반 입력 차단
- [x] 기본 조회 4개 이상 (`WHERE`, `ORDER BY`, `LIMIT` 포함)
- [x] JOIN 4개 이상 (`INNER JOIN` 2+, `LEFT JOIN` 1+)
- [x] 집계 3개 이상 (`COUNT`, `SUM`, `AVG` 중 2+ 및 `GROUP BY`)
- [x] subquery 1개 이상
- [x] `UPDATE` / `DELETE` 2개 이상
- [x] `CREATE INDEX` 1개 이상 + 적용 이유
- [x] 각 query 목적 1줄 + 실제 결과
- [x] DB 전용 문법 사용 시 주석으로 명시

### Constraints

- 로컬 실행 가능한 DB 사용
- 백엔드 프레임워크/API/UI 사용 금지
- View/Procedure/Trigger 같은 고급 기능은 범위 밖
- 과도한 정규화 이론/Enterprise 구조를 도입하지 않음

### Selected Domain / DB

- Domain: `학습 도서 대여`
- DB: `SQLite`
- Tables: `categories`, `members`, `books`, `rentals`
- 1:N:
  - `categories.id → books.category_id`
  - `members.id → rentals.member_id`
  - `books.id → rentals.book_id`

## 6. Requirement Traceability

| ID | Requirement | Source | Location | Implementation | Test / Evidence | Status |
|---|---|---|---|---|---|---|
| REQ-001 | 4개 이상 table + 각 PK | Mission PDF/MD | 기능 요구 2 | `sql/01_schema.sql` | `evidence/verification-summary.txt` | PASS |
| REQ-002 | FK 2+로 1:N 2+ | Mission PDF/MD | 기능 요구 2 | `sql/01_schema.sql` | FK inventory/constraint test | PASS |
| REQ-003 | NOT NULL/UNIQUE/FK 실효성 | Mission PDF/MD | 기능 요구 3 | `sql/01_schema.sql` | `evidence/constraints.txt` | PASS |
| REQ-004 | table별 10행+ seed | Mission PDF/MD | 기능 요구 4 | `sql/02_seed.sql` | `evidence/row-counts.txt` | PASS |
| REQ-005 | 기본 조회 4+ | Mission/Eval | SQL query 15 | Q01-Q04 | query evidence | PASS |
| REQ-006 | JOIN 4+, INNER 2+, LEFT 1+ | Mission/Eval | SQL query 15 | Q05-Q08 | query evidence | PASS |
| REQ-007 | 집계 3+ | Mission/Eval | SQL query 15 | Q09-Q11 | query evidence | PASS |
| REQ-008 | subquery 1+ | Mission/Eval | SQL query 15 | Q12 | query evidence | PASS |
| REQ-009 | UPDATE/DELETE 2+ | Mission/Eval | SQL query 15 | Q13-Q14 | query evidence | PASS |
| REQ-010 | index 1+ + 이유 | Mission/Eval | SQL query 15 | Q15 | index + query plan evidence | PASS |
| REQ-011 | query별 목적/실행 결과 | Mission/Eval | 결과 확인 자료 | `sql/03_queries.sql` | `evidence/query-results.txt` | PASS |
| REQ-012 | SQL-only / framework 금지 | Mission PDF/MD | 제약 사항 | SQL + stdlib 검증 script | repo inventory | PASS |
| REQ-013 | DB 전용 문법 주석 | Mission PDF/MD | DB 환경 준비 | SQLite PRAGMA/index note | source review | PASS |
| REQ-014 | 학습 설명 준비 | Mission/Eval | 과제 목표/평가 2~4 | `docs/learning-notes.md` | human oral check optional | NEEDS-RUNTIME |

## 7. Evaluation Mapping

| Evaluation ID | Criterion | Validation | Evidence | Status |
|---|---|---|---|---|
| EVA-01 | 4 tables + PK | schema introspection | verification summary | PASS |
| EVA-02 | FK 1:N 2+ + invalid ref blocked | FK inventory + failing insert | constraints | PASS |
| EVA-03 | each table 10+ rows | row count | row-counts | PASS |
| EVA-04 | required 15-query category mix | marker/category audit + execution | query-results | PASS |
| EVA-05 | all query results attached | captured execution output | query-results | PASS |
| EVA-06 | explain table split/roles | learning notes | docs | NEEDS-RUNTIME |
| EVA-07 | explain 1:N domain meaning | learning notes/ER diagram | docs | NEEDS-RUNTIME |
| EVA-08 | explain column types | learning notes | docs | NEEDS-RUNTIME |
| EVA-09 | explain index column/reason | Q15 + learning notes | query-results/docs | NEEDS-RUNTIME |
| EVA-10 | DB vs Excel explanation | learning notes | docs | NEEDS-RUNTIME |
| EVA-11 | PK/FK and 1:N explanation | learning notes | docs | NEEDS-RUNTIME |
| EVA-12 | INNER vs LEFT JOIN | Q05-Q08 + learning notes | evidence/docs | NEEDS-RUNTIME |
| EVA-13 | GROUP BY/COUNT/SUM/AVG | Q09-Q11 + learning notes | evidence/docs | NEEDS-RUNTIME |
| EVA-14 | explain most complex query | Q10 walkthrough | docs | NEEDS-RUNTIME |
| EVA-15 | difficulty and resolution | learning notes | docs | NEEDS-RUNTIME |

## 8. Repository Baseline

- Default Branch: `main`
- Baseline Commit: `9daf13c4bd10507ca6cbbc9d3e0373fc7ea4588e`
- Work Branch: `mission/b5-1`
- Runtime / Language: `SQLite + Python 3 stdlib sqlite3`
- Dependency Manager: `NONE`
- Existing Tests: `NO`

Baseline inventory:

```text
.
├── README.md
├── b5-1-evaluation.md
├── b5-1-mission.md
└── b5-1-mission.pdf
```

Existing implementation:
- 이미 충족: Mission/Evaluation source files
- 부분 충족: README source links
- 누락: schema, seed, 15 queries, evidence, reproducible verification, learning notes, handoff

## 9. Mission-specific TOC

```text
B5-1
├── Source / Evaluation Discovery
├── Domain: 학습 도서 대여
├── Schema
│   ├── categories
│   ├── members
│   ├── books
│   └── rentals
├── Seed Data
├── Query Set Q01-Q15
├── Data Integrity Verification
├── Query Result Evidence
├── Learning Notes / ER Flow
└── Handoff
```

## 10. Engineering Plan

- ROLE: ChatGPT Orchestrator + Builder
- GOAL: 최소 충분 SQL 산출물과 재현 가능한 검증 완성
- Git boundary: `mission/b5-1`
- Test command: `python3 scripts/verify.py`
- Secret boundary: secret/credential 없음, DB artifact는 build에서 생성
- Evidence boundary: 실제 실행 결과만 `evidence/`에 기록
- Review budget: self review 1회, 필요한 경우만 추가 검토 1회
- STOP: 필수 요구 + 평가 산출물 + tests/evidence + BLOCKER 0/MAJOR 0

## 11. Agent Routing

- Orchestrator / Integrator: `ChatGPT`
- Primary Builder: `ChatGPT` (current toolset)
- Independent Reviewer: `OFF unless a separate reviewer tool becomes available/necessary`
- Specialist Agents: `OFF`
- Runtime Authority: local SQLite execution + Human for oral mastery only

## 12. Dependency / Drift Check

- Upstream Dependency: `NONE`
- Related Mission: `NONE`
- Control Tower Drift: `NONE` (frozen baseline intentionally retained)
- Source Drift: `NONE`
- Action: `CONTINUE`

## 13. Test Plan

| Test | Method | Expected | Status |
|---|---|---|---|
| clean schema rebuild | `python3 scripts/verify.py` | no SQL error | PASS |
| table/PK inventory | sqlite metadata | 4 tables, PK each | PASS |
| FK inventory | `PRAGMA foreign_key_list` | 3 FK definitions | PASS |
| constraints | intentional invalid INSERT | FK/UNIQUE/NOT NULL/CHECK blocked | PASS |
| seed row counts | `COUNT(*)` | all >=10 | PASS |
| query set | Q01-Q15 execution | all succeed | PASS |
| update/delete | postconditions | changed/deleted as intended | PASS |
| index | sqlite_master/query plan | index exists and is used | PASS |

## 14. Runtime Plan

| Runtime Check | AI 가능 | Human 필요 | Evidence | Status |
|---|---|---|---|---|
| SQLite schema/seed/query execution | YES | NO | `evidence/*.txt` | PASS |
| oral explanation/mastery | NO | YES at evaluation time | `docs/learning-notes.md` prep | NEEDS-RUNTIME |

## 15. Evidence Plan

| Evidence | Requirement / Evaluation | Location | Status |
|---|---|---|---|
| verification summary | REQ-001~013 | `evidence/verification-summary.txt` | PASS |
| row counts | REQ-004/EVA-03 | `evidence/row-counts.txt` | PASS |
| constraint violations | REQ-003/EVA-02 | `evidence/constraints.txt` | PASS |
| Q01-Q15 outputs | REQ-005~011/EVA-04~05 | `evidence/query-results.txt` | PASS |
| learning explanations | EVA-06~15 | `docs/learning-notes.md` | PASS |

## 16. Completion Gates

| Gate | Exit Condition | Status |
|---|---|---|
| G1 SOURCE | Source 상태/Mode/Gap/requirements 확정 | PASS |
| G2 BUILD | 필수 SQL/docs/verifier 구현 | PASS |
| G3 TEST | clean SQLite verification 통과 | PASS |
| G4 REVIEW | BLOCKER=0, MAJOR=0 | PASS |
| G5 RUNTIME | SQLite 실제 실행 완료; oral mastery는 정확히 분리 | NEEDS-RUNTIME |
| G6 EVIDENCE | 필수 evidence 저장 | PASS |
| G7 LEARN | 평가 설명용 학습자료 완료 | PASS |
| G8 MERGE | PR/merge 완료 | TODO |

### G4 Review Result

- Self review: 1회 완료 (`evidence/self-review.md`)
- Independent reviewer: current toolset에서 별도 reviewer 미사용
- BLOCKER: 0
- MAJOR: 0
- Actual SQLite verification: exit code 0
- Human-only gap: oral explanation/mastery

## 17. STOP Rule

공식 필수 Requirement 충족, 평가 artifact 준비, BLOCKER=0, MAJOR=0, SQL 실행 테스트와 Evidence 완료, PR merge 완료 시 종료한다. Oral mastery 자체는 Repository가 대신 증명할 수 없으므로 학습 자료까지만 준비하고 실제 평가는 사람에게 남긴다.

## 18. Handoff Contract

종료 시 `HANDOFF.md`, `mission-result.yaml`을 작성한다. Control Tower는 수정하지 않는다.
