# Codyssey Basic B5-1 — Database Design

## 현재 훈련 상태

- 구분: **필수 미션 (REQUIRED)**
- Round: **R01 — CLEAR**
- Runtime Mission 상태: **⬜ NOT STARTED**
- Reference Build: **CORE READY**

공식 Mission/Evaluation을 기준으로 SQLite + SQL Reference 기준본을 준비했습니다. 실제 SQLite 실행·Evidence 전에는 `✅ CLEAR`가 아닙니다.

## 공식 원본

- `b5-1-mission.pdf`
- `b5-1-mission.md`
- `b5-1-evaluation.md`

공식 원본은 수정하지 않습니다.

## 시작 위치

- `training/round-01-clear/BEGINNER-GUIDE.md`
- `training/round-01-clear/REFERENCE-STATUS.md`
- `training/round-01-clear/CHECKLIST.md`

## Reference 핵심

- 도메인: 도서 대여 관리
- 4 tables: members / categories / books / rentals
- PK / FK / NOT NULL / UNIQUE / CHECK
- 각 table 10행 이상 sample data
- `queries.sql` Q01~Q16
- SELECT / JOIN / GROUP BY / Subquery / UPDATE / DELETE / INDEX
- fresh DB `verify.sh`
- Phase C `run-reference.sh`
- ERD / Requirements Mapping / Evaluation Q&A / Evidence plan

## CLEAR 원칙

Reference 파일이 존재하는 것만으로 CLEAR하지 않습니다. Phase C에서 실제 fresh SQLite DB, Q01~Q16 결과, constraint 실패 경로, index plan, Evaluation 설명과 Evidence를 확인한 뒤 `✅ CLEAR`로 변경합니다.
