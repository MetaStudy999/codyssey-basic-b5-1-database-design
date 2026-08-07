# B5-1 Self Review

검토 범위: Mission/Evaluation 대비 `mission/b5-1` 구현 diff와 실제 SQLite 검증 결과.

## 결과

- BLOCKER: **0**
- MAJOR: **0**
- MINOR: **0**

## 요구사항 재대조

| 항목 | 확인 결과 |
|---|---|
| Table / PK | 4 tables, PK 4개 |
| FK / 1:N | FK 3개, 1:N 3개 |
| NOT NULL / UNIQUE | 다수 적용, 실제 실패 검증 포함 |
| Seed | categories 10 / members 12 / books 15 / rentals 18 |
| Basic SELECT | Q01-Q04 = 4 |
| JOIN | Q05-Q08 = 4, INNER 2+ / LEFT 1+ |
| Aggregate | Q09-Q11 = 3, COUNT/SUM/AVG + GROUP BY |
| Subquery | Q12 = 1 |
| UPDATE / DELETE | Q13-Q14 = 2 |
| Index | Q15 = 1, 적용 이유 + EXPLAIN QUERY PLAN |
| Query evidence | Q01-Q15 모두 `evidence/query-results.txt`에 실제 결과 기록 |
| SQL-only constraint | backend framework/API/UI 없음 |

## 실제 검증

`python3 scripts/verify.py`를 clean DB에서 재실행했고 exit code 0을 확인했다.

```text
PASS | schema rebuild
PASS | tables=4
PASS | foreign_keys=3
PASS | each seeded table has >=10 rows
PASS | FK/UNIQUE/NOT NULL/CHECK violations blocked
PASS | query_groups=15
PASS | UPDATE result verified
PASS | DELETE result verified
PASS | index created
PASS | final rentals rows=17
```

## 남은 Human-only 항목

Evaluation의 "설명할 수 있는가" 항목은 저장소가 사용자의 실제 구두 설명 능력을 대신 증명할 수 없다. `docs/learning-notes.md`에 구현 기준 설명과 연습 순서를 준비했으며 실제 평가 시 사용자 확인이 필요하다.
