# tbl_piiextract PURGE 설계서

> 작성일: 2026-03-26

---

## 1. 배경

| 항목 | 내용 |
|------|------|
| 대상 테이블 | `tbl_piiextract` |
| 현재 건수 | 600만건 이상 |
| 문제 | 비대면 고객 파기 건수 누적으로 테이블 비대화, 보고서/대시보드 쿼리 성능 저하 |
| 목표 | 영구파기/복원 완료 레코드를 보존 기간 경과 후 삭제하되, **보고서 통계 숫자는 유지** |

---

## 2. PURGE 대상 조건 및 보존 정책

| 구분 | 대상 | SQL 조건 | 보존 기간 |
|------|------|----------|-----------|
| 3단계 영구파기 | PII_POLICY3 | `EXCLUDE_REASON='DELARC' AND SUBSTR(jobid,1,11)='PII_POLICY3' AND arc_del_date <= (현재 - 12개월)` | **1년** |
| 1단계 영구파기 | PII_POLICY1 | `EXCLUDE_REASON='DELARC' AND SUBSTR(jobid,1,11)='PII_POLICY1' AND arc_del_date <= (현재 - 3개월)` | **3개월** |
| 2단계 영구파기 | PII_POLICY2 | `EXCLUDE_REASON='DELARC' AND SUBSTR(jobid,1,11)='PII_POLICY2' AND arc_del_date <= (현재 - 3개월)` | **3개월** |
| 복원 완료 | 전체 Policy | `EXCLUDE_REASON='RESTORE' AND restore_date <= (현재 - 12개월)` | **1년** |

- **3단계(PII_POLICY3)**: 상거래종료고객으로 법적 보존 의무 기간이 길어 1년 보존
- **1,2단계(PII_POLICY1,2)**: 단순가입/상담거절 고객으로 상대적으로 짧은 3개월 보존
- **복원 완료(RESTORE)**: 복원 처리가 끝난 레코드로, 1년 경과 후 삭제

---

## 3. 실행 스케줄

| 항목 | 설정 |
|------|------|
| 실행 주기 | **매주 일요일 새벽 03:00** |
| Cron 표현식 | `0 0 3 ? * SUN` |
| 실행 클래스 | `JobScheduler.purgeCompletedExtractRecords()` |

---

## 4. PURGE 실행 순서

각 정책(policy + excludeReason)별로 아래 3단계를 순차 실행:

```
Step A: insertPurgeStats()    -- 보고서 통계 집계 보존
Step B: insertPurgeLog()      -- 고객별 파기 증적 보존
Step C: deletePurgedRecords() -- tbl_piiextract에서 삭제
```

실행 순서:
1. PII_POLICY3 + DELARC (cutoff: 12개월)
2. PII_POLICY1 + DELARC (cutoff: 3개월)
3. PII_POLICY2 + DELARC (cutoff: 3개월)
4. PII_POLICY1 + RESTORE (cutoff: 12개월)
5. PII_POLICY2 + RESTORE (cutoff: 12개월)
6. PII_POLICY3 + RESTORE (cutoff: 12개월)

---

## 5. 신규 테이블

### 5-1. TBL_PIIEXTRACT_PURGE_STAT (보고서 통계 보존)

퍼지로 삭제되는 레코드의 **집계 카운트**를 보존하여, 매시간 재생성되는 보고서 통계(TBL_PIICUSTSTAT, TBL_PIICUSTSTATYEAR)에 누락이 없도록 보정.

```sql
CREATE TABLE TBL_PIIEXTRACT_PURGE_STAT (
  STAT_DATE      VARCHAR(10)  NOT NULL,  -- 'YYYY/MM/DD' 또는 'YYYYMM'
  STAT_TYPE      VARCHAR(20)  NOT NULL,  -- 집계 유형
  JOBID_PREFIX   VARCHAR(11)  NOT NULL,  -- 'PII_POLICY1','PII_POLICY2','PII_POLICY3','ALL'
  CNT            INT          NOT NULL DEFAULT 0,
  PURGE_DATE     DATETIME     NOT NULL,  -- 최종 퍼지 실행일
  PRIMARY KEY (STAT_DATE, STAT_TYPE, JOBID_PREFIX)
);
```

**STAT_TYPE 값:**

| STAT_TYPE | 보정 대상 쿼리 | 설명 |
|-----------|---------------|------|
| `ARC_DEL` | insertCustStatListAllDays 서브쿼리1 | arc_del_date별 전체 영구파기 카운트 |
| `ARCHIVE` | insertCustStatListAllDays 서브쿼리2 | archive_date별 Policy별 분리보관 카운트 |
| `RESTORE_ALL` | insertCustStatListAllDays 서브쿼리3 | restore_date별 전체 복원 카운트 |
| `RESTORE` | insertCustStatListAllDays 서브쿼리4 | restore_date별 Policy별 복원 카운트 |
| `ARC_DEL_DELARC` | insertCustStatListAllDays 서브쿼리5 | arc_del_date별 DELARC 전체 카운트 |
| `ARC_DEL_DELARC_P` | insertCustStatListAllDays 서브쿼리6 | arc_del_date별 Policy별 DELARC 카운트 |
| `BASEDATE` | yearstat / sumstat | basedate(YYYYMM)별 카운트 |

### 5-2. TBL_PIIEXTRACT_PURGE_LOG (고객별 파기 증적)

퍼지 전 **고객별 파기 이력**을 보존. 감사/민원 시 "특정 고객이 언제 파기되었는지" 개별 추적 가능.
개인정보(이름, 주민번호, 주소 등)는 **포함하지 않음**.

```sql
CREATE TABLE TBL_PIIEXTRACT_PURGE_LOG (
  CUSTID         VARCHAR(50)  NOT NULL,  -- 고객ID
  JOBID          VARCHAR(200) NOT NULL,  -- 파기 Job ID
  BASEDATE       DATETIME     NOT NULL,  -- 기준일
  ORDERID        INT          NOT NULL,  -- 오더ID
  ARC_DEL_DATE   DATETIME,               -- 영구파기일
  RESTORE_DATE   DATETIME,               -- 복원일
  EXCLUDE_REASON VARCHAR(30),             -- DELARC 또는 RESTORE
  PURGE_DATE     DATETIME     NOT NULL,  -- 실제 삭제(퍼지) 실행일
  PRIMARY KEY (CUSTID, JOBID, BASEDATE, ORDERID)
);
```

---

## 6. 보고서 쿼리 수정 내역

퍼지 후에도 보고서 카운트가 동일하도록 기존 stat 쿼리에 PURGE_STAT UNION ALL 보정 추가.

| 쿼리 | 변경 내용 |
|------|-----------|
| `insertCustStatListAllDays` | 기존 6개 UNION ALL 서브쿼리 각각에 PURGE_STAT SELECT UNION ALL 추가 (총 12개 서브쿼리) |
| `insertCustStatListAllMonths` | 변경 없음 (ALLDAYS에서 파생, 자동 보정) |
| `insertextractrunresultyearstat` | 중복 UNION ALL 버그 수정 + BASEDATE 타입 PURGE_STAT UNION ALL 추가 |
| `insertextractrunresultsumstat` | 중복 UNION ALL 버그 수정 + BASEDATE 타입 PURGE_STAT UNION ALL 추가 |

> **참고**: yearstat/sumstat에 동일 쿼리가 2번 UNION ALL되어 카운트 2배가 되는 기존 버그도 함께 수정.

---

## 7. 수정 파일 목록

| 파일 | 변경 내용 |
|------|-----------|
| `src/main/resources/sql-workbook/XONE_TABLE_DDL_MYSQL.sql` | TBL_PIIEXTRACT_PURGE_STAT, TBL_PIIEXTRACT_PURGE_LOG DDL 추가, 변경이력 기록 |
| `src/main/resources/datablocks/dlm/mapper/PiiExtractMapper.xml` | insertPurgeStats, insertPurgeLog, deletePurgedRecords 신규 + stat 쿼리 8개 보정 |
| `src/main/java/datablocks/dlm/mapper/PiiExtractMapper.java` | insertPurgeStats, insertPurgeLog, deletePurgedRecords 메서드 시그니처 추가 |
| `src/main/java/datablocks/dlm/schedule/JobScheduler.java` | purgeCompletedExtractRecords (주간 스케줄), purgeExtractByPolicy (실행 로직) 추가 |
| `src/main/java/datablocks/dlm/controller/PiiExtractController.java` | `POST /piiextract/purge` 수동 퍼지 API 추가 (ROLE_ADMIN 전용) |
| `src/main/webapp/WEB-INF/views/piiextract/custstatlist.jsp` | 신용정보 처리내역 화면에 Purge 버튼 추가 |
| `src/main/webapp/resources/css/piipolicy-refactor.css` | btn-filter-purge 스타일 추가 |

---

## 8. 수동 퍼지 실행 (API / UI)

### 8-1. 수동 실행 API

| 항목 | 내용 |
|------|------|
| URL | `POST /piiextract/purge` |
| 권한 | `ROLE_ADMIN` (관리자 전용) |
| 응답 | `{"status":"OK","message":"퍼지 완료"}` 또는 `{"status":"FAIL","message":"..."}` |

### 8-2. UI 실행 방법

**보고서 > 신용정보 처리내역** 화면 상단 필터 영역에 **Purge** 버튼이 추가되어 있음.

1. 관리자 계정으로 로그인
2. 보고서 > 신용정보 처리내역 메뉴 진입
3. **Purge** 버튼 클릭
4. 확인 팝업에서 "확인" 클릭 → 퍼지 실행
5. 완료 알림 후 화면 자동 새로고침

### 8-3. 자동 실행 스케줄

| 항목 | 설정 |
|------|------|
| 주기 | 매주 일요일 새벽 03:00 |
| Cron | `0 0 3 ? * SUN` |
| 클래스 | `JobScheduler.purgeCompletedExtractRecords()` |

배포 후 일요일까지 기다리지 않고 **UI에서 즉시 실행 가능**.

---

## 9. 고객사 배포 절차

### 9-1. DDL 실행 (1회)
```sql
-- 1) 보고서 통계 보존 테이블
CREATE TABLE TBL_PIIEXTRACT_PURGE_STAT (
  STAT_DATE      VARCHAR(10)  NOT NULL,
  STAT_TYPE      VARCHAR(20)  NOT NULL,
  JOBID_PREFIX   VARCHAR(11)  NOT NULL,
  CNT            INT          NOT NULL DEFAULT 0,
  PURGE_DATE     DATETIME     NOT NULL,
  PRIMARY KEY (STAT_DATE, STAT_TYPE, JOBID_PREFIX)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 2) 고객별 파기 증적 테이블
CREATE TABLE TBL_PIIEXTRACT_PURGE_LOG (
  CUSTID         VARCHAR(50)  NOT NULL,
  JOBID          VARCHAR(200) NOT NULL,
  BASEDATE       DATETIME     NOT NULL,
  ORDERID        INT          NOT NULL,
  ARC_DEL_DATE   DATETIME,
  RESTORE_DATE   DATETIME,
  EXCLUDE_REASON VARCHAR(30),
  PURGE_DATE     DATETIME     NOT NULL,
  PRIMARY KEY (CUSTID, JOBID, BASEDATE, ORDERID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

### 9-2. 애플리케이션 배포
변경된 class/xml/css/jsp 파일 배포 후 톰캣 재시작.

### 9-3. 초기 퍼지 실행
1. 관리자 계정으로 로그인
2. **보고서 > 신용정보 처리내역** 화면 진입
3. **Purge** 버튼 클릭 → 즉시 실행

### 9-4. 검증
1. 퍼지 전: `SELECT COUNT(*) FROM tbl_piiextract` 건수 확인
2. 퍼지 전: 보고서 화면에서 통계 카운트 스냅샷 캡처
3. 퍼지 실행 후:
   - `SELECT COUNT(*) FROM tbl_piiextract` 건수 감소 확인
   - `SELECT COUNT(*) FROM TBL_PIIEXTRACT_PURGE_STAT` 통계 적재 확인
   - `SELECT COUNT(*) FROM TBL_PIIEXTRACT_PURGE_LOG` 증적 적재 확인
   - 보고서 화면에서 통계 카운트가 퍼지 전과 **동일**한지 비교
4. 이후 매주 일요일 03:00 자동 실행 확인

> **참고**: TBL_PIIORDER 비-파기 Job 퍼지는 별도 설계서 참조 → `docs/PURGE_tbl_piiorder_설계서.md`
