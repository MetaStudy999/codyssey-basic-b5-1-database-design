# B5-1 Round 01 — Mission Clear Checklist

Reference 상태와 Runtime 상태를 분리해서 기록합니다.

## A. Source / Scope
- [x] `b5-1-mission.pdf` 존재 확인
- [x] `b5-1-mission.md` 요구사항 반영
- [x] `b5-1-evaluation.md` 평가 항목 반영
- [x] 필수와 선택(ERD/bonus) 분리
- [x] 백엔드 프레임워크 사용 안 함

## B. Schema
- [x] 최소 4개 테이블
- [x] 각 테이블 PK
- [x] FK 3개
- [x] 1:N 관계 2개 이상
- [x] NOT NULL
- [x] UNIQUE
- [x] CHECK
- [x] SQLite FK enforcement 활성화
- [x] 의미 있는 컬럼명/타입

## C. Sample Data
- [x] members 10행 이상
- [x] categories 10행 이상
- [x] books 10행 이상
- [x] rentals 10행 이상
- [x] 부모 → 자식 INSERT 순서
- [x] FK 관계가 있는 sample data

## D. Query Coverage
- [x] 총 15개 이상 — Q01~Q16
- [x] BASIC 4개 이상
- [x] JOIN 4개 이상
- [x] INNER JOIN 2개 이상
- [x] LEFT JOIN 1개 이상
- [x] AGGREGATE 3개 이상
- [x] COUNT/SUM/AVG 중 2종 이상
- [x] GROUP BY
- [x] SUBQUERY 1개 이상
- [x] UPDATE
- [x] DELETE
- [x] CREATE INDEX + 적용 이유
- [x] Query마다 목적 설명

## E. Reference Verification Design
- [x] fresh temporary SQLite DB 사용
- [x] schema + seed 실행 검사
- [x] 4 tables / PK 검사
- [x] FK 실제 invalid reference 차단 검사
- [x] NOT NULL 실제 차단 검사
- [x] UNIQUE 실제 차단 검사
- [x] 각 table row count 검사
- [x] Q01~Q16 전체 실행 검사
- [x] Query category count 검사
- [x] UPDATE/DELETE rollback 후 seed 상태 확인
- [x] index 생성 확인
- [x] Runtime Evidence Gate 설계

## F. Learning / Documentation
- [x] 상세 Beginner Guide
- [x] 용어 설명
- [x] 관계 개념도
- [x] ERD Reference
- [x] Requirement → Implementation → Verification → Evidence mapping
- [x] Evaluation Q&A
- [x] Excel vs DB / PK-FK / JOIN / GROUP BY / Index 설명
- [x] 가장 복잡한 Query 설명 기준
- [x] 난점/해결 설명 기준

## G. Phase C Runtime — 아직 PASS 아님
- [ ] `sqlite3 --version` 실제 확인
- [ ] `verify.sh` 실제 `0 FAIL`
- [ ] `run-reference.sh` 실제 실행
- [ ] 4 tables/PK/FK/constraints 실제 결과 확인
- [ ] 각 table 10+ rows 실제 결과 확인
- [ ] FK invalid INSERT 실제 실패 확인
- [ ] Q01~Q16 실제 결과 확인
- [ ] INNER JOIN vs LEFT JOIN 결과 비교
- [ ] GROUP BY/COUNT/AVG 결과 설명
- [ ] Q14 UPDATE 결과 확인
- [ ] Q15 DELETE 결과 확인
- [ ] Q16 index/query plan 확인
- [ ] `evaluation.md`를 본인 표현으로 작성

## H. Runtime Evidence — 아직 생성하지 않음
- [ ] `evidence/runtime/constraints.txt`
- [ ] `evidence/runtime/query-results.txt`
- [ ] `evidence/runtime/index-plan.txt`
- [ ] `evidence/runtime/evaluation.md`
- [ ] `verify.sh --runtime` 실제 `0 FAIL`

## I. Final CLEAR Gate
- [x] Phase A Reference 기준본 핵심 준비
- [x] Reference/Runtime 구분
- [x] 허위 Runtime PASS 없음
- [ ] 실제 Runtime 완료
- [ ] 실제 Evidence 완료
- [ ] 평가 설명 완료
- [ ] **✅ MISSION CLEAR**

현재 판정: **Reference CORE READY / Runtime ⬜ NOT STARTED**
