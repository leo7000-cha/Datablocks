# JB우리캐피탈 PoC 4주 계획서

- **시작일**: 2026-04-28 (화) — 익일 현장 투입
- **PoC 범위**: ① 개인정보 파기 솔루션  ② 접속기록 저장 솔루션 (Java Agent 기반)
- **전제조건**: 테스트 데이터는 2025년 도입분 기존 환경 사용
- **사전 리스크**: 기간계 = LG CNS DevOn 프레임워크 — Spring Boot/web.xml 여부에 따라 SDK 적용 방식 변동

---

## 전체 일정 개요

| 주차 | 기간 | 핵심 마일스톤 |
|---|---|---|
| Week 1 | 04/28 (화) ~ 05/02 (토) | 환경 사전조사 + 메타데이터 네이밍룰 분석 + Discovery 1차 실행 |
| Week 2 | 05/04 (월) ~ 05/08 (금) | PII 후보 검증 + 칼럼 1건씩 확정 + 파기 대상 테이블 확정 |
| Week 3 | 05/11 (월) ~ 05/15 (금) | 파기 Job 구성(UPDATE 기본/DELETE 분류) + Java Agent 개발계 적용 |
| Week 4 | 05/18 (월) ~ 05/22 (금) | 접속기록 DB 권한·DDL·수집 검증 + 통합 시연 + PoC 결과 보고 |

---

## Week 1 — 환경 사전조사 & PII Discovery 1차 (04/28 ~ 05/02)

### Day 1 (04/28 화) — 현장 투입 / 환경 점검
- [ ] 개발계 접속환경 확보 (VPN, DB 계정, 서버 SSH)
- [ ] 작년 도입된 테스트 데이터 현황 파악 (테이블 수, 행 수, 스키마 목록)
- [ ] **DevOn 프레임워크 사전조사 3종** (SDK 적용 결정 전 필수)
  - Spring Boot 사용 여부 확인 (`application.yml/properties` vs `web.xml`)
  - DevOn 자체 인증 객체 구조 (`LoginUser`, `SessionUser` 등 세션 attribute 키명)
  - MyBatis SqlSessionFactory 빈 등록 방식

### Day 2 (04/29 수) — 메타데이터 수집
- [ ] 대상 스키마/테이블 메타데이터 추출 (DBMS 카탈로그 → CSV)
- [ ] 칼럼명·코멘트 기준 개인정보 후보 키워드 1차 추출
- [ ] 고객사 표준 네이밍 가이드(있다면) 입수

### Day 3 (04/30 목) — 네이밍룰 정리 + Discovery 컨피그
- [ ] 네이밍 패턴 정리 (예: `*_NM`, `*_NAME`, `*RRN*`, `*JUMIN*`, `*TEL*`, `*MOBILE*`, `*ADDR*`, `*EMAIL*`, `*ACCT_NO*`, `*CARD_NO*`)
- [ ] `LKPIISCRTYPE` / `DISCOVERY_PII_TYPE` 에 고객 룰 반영 (status/visible 동기화 주의)
- [ ] 패턴 정규식 / Meta 가중치 / AI 사용 여부 결정

### Day 4 (05/01 금) — Discovery 1차 실행
- [ ] Discovery 엔진 1차 스캔 (Meta 40 + Pattern 35 + AI 25)
- [ ] 결과 후보 칼럼 리스트 추출 (테이블·칼럼·점수·근거)
- [ ] False Positive 다발 영역 식별 (코드/넘버성 칼럼 등)

### Day 5 (05/02 토) — 1주차 정리
- [ ] 1차 후보 리스트 → Excel/CSV 산출물화
- [ ] 2주차 검증 미팅 어젠다 작성

---

## Week 2 — PII 칼럼 확정 & 파기 대상 테이블 확정 (05/04 ~ 05/08)

### Day 6 (05/04 월) — 후보 샘플링 검증
- [ ] 후보 칼럼별 실데이터 샘플 추출 (개인정보 노출 최소화 / 마스킹 후 검토)
- [ ] 패턴/포맷 적합성 1차 판정 (RRN 체크섬, 휴대폰 자릿수 등)

### Day 7 (05/05 화) — 공휴일 (어린이날) 보정
- [ ] 휴일 일정 — 5/4·5/6 양일 작업으로 보강 (필요 시 5/9 토 보강)

### Day 8 (05/06 수) — 고객 1차 확정 미팅
- [ ] 고객사 담당자와 후보 칼럼 1건씩 검토 → "확정/제외/보류" 판정
- [ ] 보류 항목은 업무 정의 추가 확인 (정의서/메타 문서)

### Day 9 (05/07 목) — 룰 보정 후 재실행
- [ ] FP/FN 보정을 위한 패턴/가중치 재조정
- [ ] Discovery 2차 실행 → 보류 항목 위주 재판정

### Day 10 (05/08 금) — 파기 대상 테이블 확정
- [ ] **확정된 PII 칼럼 → 보유 테이블 목록 산출** (파기 대상 마스터)
- [ ] 테이블별 행 수 / 외래키 / 참조관계 조사
- [ ] UPDATE 마스킹 vs DELETE 행삭제 1차 분류 (참조무결성 영향 기준)

---

## Week 3 — 파기 Job 구성 & Java Agent 개발계 적용 (05/11 ~ 05/15)

### Day 11 (05/11 월) — 파기 정책 정의
- [ ] **기본 정책 = UPDATE (마스킹)**, 참조무결성 영향 없는 보조 테이블만 DELETE
- [ ] 칼럼별 마스킹 규칙 정의 (성명: `홍**`, RRN: `XXXXXX-*******`, 휴대폰: `***-****-****` 등)
- [ ] 파기 트리거 조건(보유기한 경과, 거래종료 후 N년 등) 고객 확인

### Day 12 (05/12 화) — 파기 Job 등록
- [ ] `DLM_JOB_BATCH_METADATA_UPDATE` 기준 파기 Job 메타 등록
- [ ] 테이블 × (UPDATE 컬럼 마스킹 / DELETE 행삭제) 매핑표 작성
- [ ] Job 스케줄/배치 단위 설계 (배치 주기, 1회 처리 건수 limit)

### Day 13 (05/13 수) — 파기 Dry-Run
- [ ] 개발계 소량 테이블 대상 파기 dry-run (rollback 트랜잭션)
- [ ] 결과 로그 / 변경 행 수 / 오류 처리 검증

### Day 14 (05/14 목) — Java Agent 개발계 적용 (1)
- [ ] DevOn 환경에서 Agent 호환성 사전 점검 (TransmittableThreadLocal 충돌 등)
- [ ] `dlm-agent-1.0.0.jar` 적용 (`-javaagent:` JVM 옵션 추가)
- [ ] Agent → DLM 서버 heartbeat 수신 확인 (`POST /api/agent/heartbeat`)

### Day 15 (05/15 금) — Java Agent 개발계 적용 (2)
- [ ] PreparedStatement 인터셉터 → AccessLogEntry 생성 검증
- [ ] DLM 서버에 `POST /api/agent/logs` 적재 확인
- [ ] DevOn 세션 사용자 식별 키 매핑 (필요 시 SDK config 확장)

---

## Week 4 — 접속기록 검증 & 통합 시연 & 보고 (05/18 ~ 05/22)

### Day 16 (05/18 월) — access_log DB 권한 확보
- [ ] 고객 DBA와 access_log 적재 DB 계정/권한 협의 (CREATE/INSERT)
- [ ] 네트워크 방화벽 / 포트 확인 (Agent → DLM, DLM → access_log DB)

### Day 17 (05/19 화) — XAUDIT 스키마 DDL 적용
- [ ] `database/xaudit/XAUDIT_SCHEMA_*.sql` 적용 (Oracle/MariaDB/PG 중 환경 확인)
- [ ] **⚠️ DROP/TRUNCATE 사전 검사 필수** — 적용 전 `grep -iE 'DROP|TRUNCATE'` 후 고객 승인
- [ ] 테이블/시퀀스/인덱스 적용 검증

### Day 18 (05/20 수) — 접속기록 수집 통합 검증
- [ ] Agent 수집 → DLM 적재 → access_log 조회까지 end-to-end 검증
- [ ] sources.jsp (접속기록 수집소스 화면) 표시 확인
- [ ] 4가지 수집 방식 라벨 정합성 점검 (SDK AOP/Filter, JDBC Agent 등)

### Day 19 (05/21 목) — 파기 실행 + 통합 시연 리허설
- [ ] 파기 Job 실제 실행 (소규모) → 결과 리포트 생성
- [ ] PoC 시연 시나리오 리허설 (Discovery → 확정 → 파기 → 접속기록 조회)

### Day 20 (05/22 금) — PoC 결과 보고
- [ ] 산출물 정리: 후보→확정 PII 리스트 / 파기 Job 매핑표 / 접속기록 샘플 / 시연 영상
- [ ] PoC 결과 보고서 작성 (성과·한계·본사업 제안)
- [ ] 고객 보고 미팅 + 차주 본사업 협의 안건 도출

---

## 산출물 체크리스트
- [ ] DevOn 환경 사전조사 결과서
- [ ] PII 후보 → 확정 칼럼 리스트 (테이블·칼럼·근거)
- [ ] 파기 대상 테이블 매핑표 (UPDATE/DELETE 분류 + 마스킹 규칙)
- [ ] 파기 Job 등록 명세 + 실행 로그
- [ ] Java Agent 적용 가이드 (DevOn 호환성 메모 포함)
- [ ] XAUDIT 스키마 적용 스크립트 + 적용 결과
- [ ] 접속기록 수집 검증 리포트
- [ ] PoC 최종 결과 보고서

## 리스크 & 의존성
- **DevOn 호환성** — Spring Boot 미사용 시 `@Import(XauditAutoConfiguration.class)` 또는 XML Bean 수동 등록 가이드 필요
- **DBA 권한 지연** — Week 4 access_log DB 권한이 늦어지면 Week 3 후반부터 병렬 요청 필요
- **공휴일 (5/5 어린이날)** — Week 2 일정 압박 가능, 5/4 또는 5/9 보강 작업 검토
- **DDL DROP 검사** — MASTER/통합 DDL 적용 전 반드시 `grep -iE 'DROP|TRUNCATE'` (2026-04-25 COTDL 사고 재발 방지)
