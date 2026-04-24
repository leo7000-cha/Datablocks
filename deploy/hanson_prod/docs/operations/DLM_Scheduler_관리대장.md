# DLM Scheduler 관리대장

> 최종 업데이트: 2026-04-11  
> DLM 시스템에서 Spring `@Scheduled`로 등록된 모든 스케줄러 목록

---

## 스케줄 요약

| # | 스케줄러 이름 | 클래스 | 메서드 | 주기 | Cron / 설정 | 활성화 조건 | 설명 |
|---|---|---|---|---|---|---|---|
| 1 | 접속기록 수집 + 이상행위 탐지 | `AccessLogScheduler` | `scheduledCollect()` | 매분 (실제 간격은 설정값) | `0 * * * * *` | `SCHEDULER_ENABLED = Y` | Agent 접속기록을 수집하고 이상행위 탐지 엔진 실행. `COLLECT_INTERVAL_MIN` 설정으로 실제 수집 간격 제어 (기본 5분) |
| 2 | 접속기록 아카이빙/퍼지 | `AccessLogArchiveScheduler` | `executeMonthlyArchive()` | 매월 1일 02:00 | `0 0 2 1 * *` | `ARCHIVE_ENABLED = Y` | 향후 3개월분 파티션 자동 생성 + 보관기간 초과 파티션 삭제 |
| 3 | 접속기록 해시 무결성 검증 | `AccessLogHashVerifyScheduler` | `executeMonthlyHashVerify()` | 매월 1일 03:00 | `0 0 3 1 * *` | `HASH_VERIFY_ENABLED = Y` | 전월 접속기록 해시 체인 전수 검증 (안전성확보조치 기준 제8조 2항) |
| 4 | 테스트 데이터 자동 파기 | `TestDataDisposalScheduler` | `orderTestDataDisposalJob()` | 매일 01:01:01 | `01 01 01 * * *` | 항상 활성 | 파기 예정일 도래한 테스트 데이터의 파기 Order 자동 생성 |
| 5 | PII 메타데이터 캐시 갱신 | `PiiMetadataCache` | `refresh()` | 5분마다 | `fixedDelay=300000` | 항상 활성 | 접속기록 이상행위 탐지에 사용되는 PII 컬럼 정보(DB.OWNER.TABLE.COLUMN → PII등급) 인메모리 캐시 갱신. `TBL_METATABLE`에서 PII 지정된 컬럼 조회 → `ConcurrentHashMap`에 원자적 교체. SELECT * 쿼리 확장, 최고 PII 등급 판단 등에 활용 |
| 6 | Job 오더 자동 생성 | `JobScheduler` | `order()` | 매일 15:00:01 | `01 00 15 * * *` | `DLM_ORDER_FLAG = Y` | Job 캘린더 기반 오더 자동 생성 |
| 7 | 아카이브 테이블 자동 관리 | `JobScheduler` | `sysArcTabWithSource()` | 매일 19:01:01 | `01 01 19 * * *` | `DLM_ARC_TAB_AUTO_MGMT_FLAG = Y` | 아카이브 테이블/컬럼 Source와 동기화 자동 등록 |
| 8 | 대시보드 통계 갱신 | `JobScheduler` | `refreshDashboard()` | 하루 3회 (06, 12, 18시) | `0 0 6,12,18 * * *` | 항상 활성 | PII 현황(`TBL_METAPIISTATUS`), 계약 통계(`TBL_PIICONTRACTSTAT`), 고객 일별/월별 통계(`TBL_PIICUSTSTAT`), 연간 통계(`TBL_PIICUSTSTATYEAR`) 전체 DELETE 후 재생성. 통계 단위가 일/월/연이므로 하루 3회로 충분 (기존 매 정시에서 변경) |
| 9 | Extract 레코드 주간 퍼지 | `JobScheduler` | `purgeCompletedExtractRecords()` | 매주 일요일 16:00 | `0 0 16 ? * SUN` | 항상 활성 | 영구파기/복원 완료 후 보존기간 경과 레코드 삭제. 삭제 전 통계를 `TBL_PIIEXTRACT_PURGE_STAT`에 적재하여 보고서 카운트 보존 |
| 10 | 오더 실행 (Job Runner) | `JobScheduler` | `runOrder()` | 10초마다 | `fixedRate=10000, initialDelay=2000` | 항상 활성 (`@Async`) | 대기 중인 오더를 폴링하여 실행. 중복 실행 방지 플래그 적용 |
| 11 | 열람기한 경과 처리 | `JobScheduler` | `runTaskEveyHour()` | 매일 05:45 | `0 45 5 * * *` | 항상 활성 | 열람기한 경과 고객 상태를 분리보관으로 변경 |
| 12 | 분리보관 데이터 영구파기 오더 | `JobScheduler` | `orderArcDelJob()` | 매일 14:55:01 | `01 55 14 * * *` | `DLM_ORDER_FLAG = Y` + `DLM_ORDER_ARCDELJOB_FLAG = Y` | 아카이브 DB에서 `pii_destruct_date`(파기 예정일) 도래한 개인정보 DELETE 오더를 자동 생성. 대상 테이블별 DELETE SQL 생성 후 다음날 `DLM_ARCDELJOB_TIME`(기본 12:01)에 `runOrder()`가 실행. 개인정보보호법상 보유기간 만료 데이터 지체없는 파기 자동화 |
| 13 | 고아 TMP 테이블 정리 | `JobScheduler` | `cleanupOrphanTmpTables()` | 매일 04:00 | `0 0 4 * * *` | 항상 활성 | innerstep 10(TMP 생성)만 있고 40(DROP)이 없는 고아 TMP 테이블 자동 DROP |

---

## 비활성 스케줄러 (주석 처리)

| # | 클래스 | 메서드 | Cron | 비고 |
|---|---|---|---|---|
| 1 | `JobScheduler` | `runEveryMinute()` | `0 * * * * *` (Asia/Seoul) | 현재 사용 안 함 — 주석 처리 상태 |

---

## 시간대별 실행 타임라인

```
00:00 ─────────────────────────────────────────────────────
01:01:01  [4] 테스트 데이터 자동 파기
02:00     [2] 접속기록 아카이빙/퍼지 (매월 1일)
03:00     [3] 접속기록 해시 검증 (매월 1일)
          [9] Extract 레코드 주간 퍼지 → 18:00 이동 (매주 일요일)
04:00     [13] 고아 TMP 테이블 정리
05:45     [11] 열람기한 경과 처리
06:00     [8] 대시보드 통계 갱신
──────── (매분)   [1] 접속기록 수집 (실제 간격: COLLECT_INTERVAL_MIN)
──────── (10초)   [10] 오더 실행 (Job Runner)
──────── (5분)    [5] PII 메타데이터 캐시 갱신
12:00     [8] 대시보드 통계 갱신
14:55:01  [12] 분리보관 데이터 영구파기 오더 → 다음날 실행
15:00:01  [6] Job 오더 자동 생성
18:00     [8] 대시보드 통계 갱신
16:00     [9] Extract 레코드 주간 퍼지 (매주 일요일)
19:01:01  [7] 아카이브 테이블 자동 관리
24:00 ─────────────────────────────────────────────────────
```

---

## 스케줄러 간 의존 관계

```
[12] orderArcDelJob (14:55) ─── 오더 생성 ──→ [10] runOrder (10초 폴링) ─── 다음날 실행
[6]  order          (15:00) ─── 오더 생성 ──→ [10] runOrder (10초 폴링) ─── 예약 시간에 실행
[4]  testDataDisposal(01:01)── 오더 생성 ──→ [10] runOrder (10초 폴링) ─── 실행
[5]  PiiMetadataCache(5분) ── 캐시 제공 ──→ [1]  AccessLogScheduler (매분) ── PII 등급 판단
```

---

## 활성화 설정 참조

| 설정 키 | 위치 | 관련 스케줄러 | 기본값 |
|---|---|---|---|
| `SCHEDULER_ENABLED` | `TBL_ACCESSLOG_CONFIG` | #1 접속기록 수집 | Y |
| `COLLECT_INTERVAL_MIN` | `TBL_ACCESSLOG_CONFIG` | #1 수집 간격 | 5 (분) |
| `ARCHIVE_ENABLED` | `TBL_ACCESSLOG_CONFIG` | #2 접속기록 아카이빙 | Y |
| `HASH_VERIFY_ENABLED` | `TBL_ACCESSLOG_CONFIG` | #3 해시 무결성 검증 | Y |
| `DLM_ORDER_FLAG` | `EnvConfig` | #6 Job 오더, #12 영구파기 오더 | - |
| `DLM_ARC_TAB_AUTO_MGMT_FLAG` | `EnvConfig` | #7 아카이브 테이블 자동 관리 | - |
| `DLM_ORDER_ARCDELJOB_FLAG` | `EnvConfig` | #12 영구파기 오더 | - |
| `DLM_ARCDELJOB_TIME` | `EnvConfig` | #12 영구파기 실행 시각 | 12:01 |
| `DLM_ARCDELJOB_THREADCNT` | `EnvConfig` | #12 영구파기 병렬 스레드 수 | 4 |

---

## 변경 이력

| 날짜 | 항목 | 변경 내용 |
|---|---|---|
| 2026-04-11 | #8 대시보드 통계 갱신 | `0 0 * * * *` (매 정시 24회) → `0 0 6,12,18 * * *` (하루 3회). 통계 단위가 일/월/연이므로 매 정시 불필요 |
| 2026-04-11 | #9 Extract 주간 퍼지 | `0 0 3 ? * SUN` → `0 0 16 ? * SUN`. #3 해시 검증(매월 1일 03:00)과 시간 충돌 해소 |

---

## 소스 파일 위치

| 파일 | 경로 |
|---|---|
| `AccessLogScheduler.java` | `DLM/src/main/java/datablocks/dlm/schedule/AccessLogScheduler.java` |
| `AccessLogArchiveScheduler.java` | `DLM/src/main/java/datablocks/dlm/schedule/AccessLogArchiveScheduler.java` |
| `AccessLogHashVerifyScheduler.java` | `DLM/src/main/java/datablocks/dlm/schedule/AccessLogHashVerifyScheduler.java` |
| `TestDataDisposalScheduler.java` | `DLM/src/main/java/datablocks/dlm/schedule/TestDataDisposalScheduler.java` |
| `JobScheduler.java` | `DLM/src/main/java/datablocks/dlm/schedule/JobScheduler.java` |
| `PiiMetadataCache.java` | `DLM/src/main/java/datablocks/dlm/engine/PiiMetadataCache.java` |
