# TBL_PIIORDER 비-파기 Job 실행 이력 PURGE 설계서

> 작성일: 2026-03-26

---

## 실행 요약

tbl_piiextract 퍼지와 **하나의 Purge 버튼**으로 함께 실행됩니다.

```
Purge 버튼 클릭 (보고서 > 신용정보 처리내역)
  → purgeCompletedExtractRecords()
    → 1) tbl_piiextract 퍼지 (통계 적재 → 증적 적재 → 삭제)
    → 2) tbl_piiorder 비-PII 퍼지 (하위 6개 + 본 테이블 삭제)
```

- **초기 적용**: 배포 후 관리자 로그인 → 보고서 > 신용정보 처리내역 → **Purge 버튼 클릭** → 즉시 실행
- **이후 자동**: 매주 일요일 03:00 자동 실행
- 별도 버튼이나 API 없이 기존 Purge 버튼 한 번이면 extract + 오더 퍼지 **둘 다 처리**

---

## 1. 배경

| 항목 | 내용 |
|------|------|
| 대상 테이블 | `TBL_PIIORDER` 및 하위 8개 테이블 |
| 문제 | Job 실행 이력 누적으로 테이블 비대화 |
| 목표 | 파기(PII) job을 제외한 완료 오더 중 6개월 경과 건 삭제 |
| 통계 보정 | 불필요 |

---

## 2. PURGE 대상 조건

```sql
WHERE jobtype != 'PII'
  AND jobid NOT LIKE 'ARC_DATA_DELETE%'
  AND jobid NOT LIKE 'RESTORE_CUSTID%'
  AND status IN ('Ended OK', 'Recovered')
  AND realendtime <= DATE_ADD(NOW(), INTERVAL -6 MONTH)
```

### 절대 제외 대상 (삭제 불가)

| 조건 | 사유 |
|------|------|
| `jobtype = 'PII'` | 파기 job — 고객 복원 시 `piiordersteptable`을 참조하여 역순 복원 수행 |
| `jobid LIKE 'ARC_DATA_DELETE%'` | 영구파기 job |
| `jobid LIKE 'RESTORE_CUSTID%'` | 복원 job |
| `status`가 Running, Wait condition, Hold, Ended not OK | 미완료/에러 오더 |

### 삭제 가능 jobtype

| jobtype | 설명 |
|---------|------|
| TDM | 테스트 데이터 |
| MIGRATE | 마이그레이션 |
| ILM | 정보수명주기 |
| SYNC | 데이터 동기화 |
| BATCH | 배치 |
| ETC | 기타 |

---

## 3. 삭제 대상 테이블 (9개)

하위 테이블부터 순차 삭제 (FK 위반 방지):

| 순서 | 테이블 | 설명 |
|------|--------|------|
| 1 | `TBL_PIIORDERSTEPTABLEUPDATE` | UPDATE 상세 |
| 2 | `TBL_PIIORDERSTEPTABLEWAIT` | 테이블 의존성 |
| 3 | `TBL_PIIORDERTHREAD` | 스레드 실행 |
| 4 | `TBL_INNERSTEP` | 내부 스텝 진행 |
| 5 | `TBL_ORDERDDL` | DDL 실행 이력 |
| 6 | `TBL_PIIORDERSTEPTABLE` | 스텝별 테이블 실행 |
| 7 | `TBL_PIIORDERSTEP` | 스텝 실행 |
| 8 | `TBL_PIIORDERJOBWAIT` | Job 의존성 |
| 9 | `TBL_PIIORDER` | 본 테이블 |

모든 하위 테이블은 `TBL_PIIORDER`의 `ORDERID`를 기준으로 삭제 대상을 서브쿼리로 조회하여 삭제.

---

## 4. 실행 스케줄

| 항목 | 설정 |
|------|------|
| 실행 주기 | **매주 일요일 새벽 03:00** (tbl_piiextract 퍼지 직후) |
| Cron 표현식 | `0 0 3 ? * SUN` |
| 실행 위치 | `JobScheduler.purgeCompletedExtractRecords()` 내부 |
| 보존 기간 | **6개월** |

---

## 5. 수동 실행

tbl_piiextract 퍼지와 동일한 방식:

1. 관리자 계정으로 로그인
2. **보고서 > 신용정보 처리내역** 화면 진입
3. **Purge** 버튼 클릭 → extract 퍼지 + 오더 퍼지 함께 실행

또는 API 직접 호출: `POST /piiextract/purge` (ROLE_ADMIN 전용)

---

## 6. 수정 파일 목록

| 파일 | 변경 내용 |
|------|-----------|
| `src/main/resources/datablocks/dlm/mapper/PiiOrderMapper.xml` | `deleteCompletedNonPiiOrders` 쿼리 추가 (하위 6개 + 본 테이블 순차 DELETE) |
| `src/main/java/datablocks/dlm/mapper/PiiOrderMapper.java` | `deleteCompletedNonPiiOrders` 메서드 시그니처 추가 |
| `src/main/java/datablocks/dlm/schedule/JobScheduler.java` | `purgeCompletedExtractRecords()` 내에 오더 퍼지 호출 추가 |

---

## 7. 고객사 배포 절차

### 7-1. DDL
신규 테이블 없음. 추가 DDL 불필요.

### 7-2. 애플리케이션 배포
변경된 class/xml 파일 배포 후 톰캣 재시작.

### 7-3. 초기 퍼지 실행
1. 관리자 계정으로 로그인
2. **보고서 > 신용정보 처리내역** 화면 > **Purge** 버튼 클릭

### 7-4. 검증
1. 퍼지 전:
   ```sql
   SELECT COUNT(*) FROM tbl_piiorder WHERE jobtype = 'PII';    -- 파기 job 건수
   SELECT COUNT(*) FROM tbl_piiorder WHERE jobtype != 'PII';   -- 비-파기 job 건수
   ```
2. 퍼지 실행
3. 퍼지 후:
   - `jobtype = 'PII'` 건수가 **변화 없는지** 확인 (절대 삭제 안 됨)
   - `jobtype != 'PII'` 건수 감소 확인
   - 하위 테이블도 동일하게 감소 확인:
     ```sql
     SELECT COUNT(*) FROM tbl_piiordersteptable;
     SELECT COUNT(*) FROM tbl_piiorderstep;
     SELECT COUNT(*) FROM tbl_piiorderthread;
     ```
4. 이후 매주 일요일 03:00 자동 실행 확인
