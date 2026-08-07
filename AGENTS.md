# AGENTS.md — B5-1

## Role

이 저장소는 Codyssey Basic B5-1 SQL Database Mission 전용 Workcell이다.

## Source of Truth

1. `b5-1-mission.pdf`
2. `b5-1-mission.md`
3. `b5-1-evaluation.md`
4. `MISSION-WORK-PACKET.md`
5. SQL / tests / evidence

## Scope

허용:
- SQLite schema/seed/query
- 재현 가능한 검증 script
- 실제 실행 evidence
- 평가 설명용 학습 문서

금지:
- 백엔드 framework/API/UI 추가
- View/Procedure/Trigger 도입
- 미션 요구를 일반 Best Practice로 확장
- Control Tower 또는 다른 Mission Repository 수정
- secret/credential commit

## Required Deliverables

- `sql/01_schema.sql`
- `sql/02_seed.sql`
- `sql/03_queries.sql`
- `evidence/`
- `scripts/verify.py`
- `docs/learning-notes.md`
- `HANDOFF.md`
- `mission-result.yaml`

## Test

```bash
python3 scripts/verify.py
```

PASS 기준:
- schema rebuild
- 4 tables / PK
- 3 FK relationships
- all seed tables >=10 rows
- FK/UNIQUE/NOT NULL/CHECK violations blocked
- Q01-Q15 execute successfully
- UPDATE/DELETE postconditions verified
- index exists

## Review Budget

- self review 1회
- 별도 reviewer는 BLOCKER/MAJOR 의심이 있을 때만
- 수정 후 관련 항목만 1회 재검증

## State Rule

실제 실행 전에는 PASS 금지. 예상 출력과 실제 `evidence/`를 구분한다.

## STOP

필수 요구와 평가 artifact가 충족되고 자동/실제 SQLite 검증이 통과하며 BLOCKER=0, MAJOR=0이면 추가 고도화를 중단한다.
