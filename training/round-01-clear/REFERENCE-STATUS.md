# B5-1 R01 — Reference Status

## 판정

**Reference Build: CORE READY**  
**Runtime Mission 상태: ⬜ NOT STARTED**

실제 SQLite 실행 결과와 Evidence가 아직 없으므로 Runtime CLEAR는 아닙니다.

## 공식 Source

- `b5-1-mission.pdf`
- `b5-1-mission.md`
- `b5-1-evaluation.md`

## CORE READY 근거

- SQLite 기반 4-table Library Rental schema
- 모든 table PK, FK 3개, 1:N 관계 3개
- NOT NULL / UNIQUE / CHECK / FK enforcement
- 각 table 10행 이상 sample data
- `queries.sql` Q01~Q16
- BASIC 4+, JOIN 4+, INNER 2+, LEFT 1+
- AGGREGATE 3+, COUNT/AVG, GROUP BY
- SUBQUERY, UPDATE, DELETE, INDEX
- Q14/Q15 SAVEPOINT rollback으로 seed 재현성 유지
- Q16 index + SQLite Query Plan
- fresh DB 기반 `verify.sh`
- `run-reference.sh` Runtime Evidence runner
- detailed Beginner Guide / Checklist / Mapping / ERD / Evaluation Q&A

## 자체감사에서 보강한 항목

- 공식 “15개 이상” 범위를 Q01~Q16으로 명시
- index를 별도 보조 파일에만 두지 않고 Q16 필수 Query로 포함
- INNER JOIN을 명시적 문법으로 사용
- Query 범주 marker를 verifier가 개수로 검사
- PK/FK/NOT NULL/UNIQUE를 선언뿐 아니라 실제 DB 동작으로 검증하도록 강화
- SQLite 날짜 `TEXT` 선택 이유 문서화
- 가장 복잡한 Query 및 난점/해결 Evaluation 설명 추가
- 실제 결과를 자동 생성하는 Runtime runner 추가

## Phase C에서만 PASS할 항목

- 실제 SQLite 버전
- fresh DB `verify.sh` 0 FAIL
- Q01~Q16 실제 결과
- FK/NOT NULL/UNIQUE 실제 실패 결과
- index/query plan 실제 출력
- 사용자의 Evaluation 설명
- Runtime Evidence

## Gate

- [x] Source/Evaluation 매핑
- [x] 최소 충분 SQL Reference
- [x] Query 범위 정합성
- [x] constraint verification 설계
- [x] Runtime Evidence 계획
- [x] 허위 Runtime PASS 없음
- [x] BLOCKER/MAJOR 설계 결함 없음

따라서 Phase A 기준 **CORE READY**입니다.
