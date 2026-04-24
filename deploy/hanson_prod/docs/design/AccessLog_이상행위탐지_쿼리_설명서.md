# 접속기록 이상행위 탐지 쿼리 설명서

> 작성일: 2026-04-10
> 버전: v1.0
> 관련 파일: `DLM/src/main/resources/datablocks/dlm/mapper/AccessLogMapper.xml`

> **용어 안내**: 본 문서에서 "DLM"은 X-One 플랫폼의 기술 내부 명칭(Data Lifecycle Management)이며, 코드·인프라·DB에서 사용되는 기술명이다. 대외적으로는 "X-One 통합 데이터 관리 플랫폼"으로 표기한다.

---

## 개요

접속기록(TBL_ACCESS_LOG)에서 이상행위를 탐지하는 8개 규칙의 SQL과 동작 원리를 설명한다.
탐지 엔진(`AccessLogDetectionEngineImpl`)이 스케줄러에 의해 주기적으로 실행되며,
각 규칙의 조건에 해당하는 사용자를 추출하여 `TBL_ACCESS_LOG_ALERT`에 알림을 생성한다.

### 공통 구조

```
모든 탐지 쿼리의 반환 구조:
  userAccount  — 탐지된 사용자 계정
  userName     — 사용자 이름
  xxxCount     — 탐지 건수 (규칙별 상이)
  logIds       — 관련 로그 ID (최대 10건, 알림 상세 링크용)
```

---

## R01. 대량 접속 탐지 (VOLUME)

| 항목 | 설정값 |
|------|--------|
| 심각도 | HIGH |
| 시간 윈도우 | 60분 (설정 가능) |
| 임계값 | 100건 (설정 가능) |
| 탐지 의미 | 단시간에 비정상적으로 많은 쿼리를 실행하는 사용자 |

### SQL

```sql
SELECT user_account AS userAccount,
       user_name AS userName,
       COUNT(*) AS accessCount,
       GROUP_CONCAT(DISTINCT log_id ORDER BY log_id LIMIT 10) AS logIds
FROM COTDL.TBL_ACCESS_LOG
WHERE access_time >= DATE_SUB(NOW(), INTERVAL #{timeWindowMin} MINUTE)
GROUP BY user_account, user_name
HAVING COUNT(*) > #{threshold}
```

### 동작 원리

```
현재 시각: 14:30
시간 윈도우: 60분 → 13:30~14:30 범위

사용자별 접속 건수 집계:
  hong: 152건 → 100 초과 → ★ 탐지
  kim:   45건 → 미달 → 정상
  park:  98건 → 미달 → 정상
```

### 탐지 시나리오

- 데이터 유출을 위한 대량 조회 (화면 반복 조회, 크롤링)
- 배치성 작업을 수동으로 반복 실행
- 시스템 오류로 무한 루프 쿼리 발생

---

## R02. 야간 시간대 접속 (TIME_RANGE)

| 항목 | 설정값 |
|------|--------|
| 심각도 | MEDIUM |
| 시간대 | 20:00~06:00 (설정 가능) |
| 임계값 | 없음 (1건이라도 탐지) |
| 탐지 의미 | 업무시간 외 접속 자체가 이상행위 |

### SQL

```sql
SELECT user_account AS userAccount,
       user_name AS userName,
       COUNT(*) AS accessCount,
       GROUP_CONCAT(DISTINCT log_id ORDER BY log_id LIMIT 10) AS logIds
FROM COTDL.TBL_ACCESS_LOG
WHERE DATE(access_time) = CURDATE()
  AND TIME(access_time) BETWEEN #{timeStart} AND #{timeEnd}
GROUP BY user_account, user_name
HAVING COUNT(*) > 0
```

### 동작 원리

```
오늘 날짜의 접속기록 중 20:00~06:00 사이 접속 필터:

  hong: 22:15 접속 → 20:00~06:00 범위 → ★ 탐지
  kim:  14:30 접속 → 범위 밖 → 정상
  park: 05:45 접속 → 20:00~06:00 범위 → ★ 탐지
```

### 탐지 시나리오

- 퇴근 후 개인정보 무단 열람
- 계정 도용자의 야간 접근
- 당직자/긴급 대응 → 소명으로 해소

### 참고

- R08(휴일 탐지)과 독립적으로 동작
- 주말 야간 접속 시 R02 + R08 **둘 다** 탐지됨 (정상 동작)

---

## R03. 접속 거부 반복 (ACCESS_DENIED)

| 항목 | 설정값 |
|------|--------|
| 심각도 | HIGH |
| 시간 윈도우 | 30분 (설정 가능) |
| 임계값 | 5회 (설정 가능) |
| 탐지 의미 | 권한 없는 DB에 반복 접근 시도 |

### SQL

```sql
SELECT user_account AS userAccount,
       user_name AS userName,
       COUNT(*) AS deniedCount,
       GROUP_CONCAT(DISTINCT log_id ORDER BY log_id LIMIT 10) AS logIds
FROM COTDL.TBL_ACCESS_LOG
WHERE access_time >= DATE_SUB(NOW(), INTERVAL #{timeWindowMin} MINUTE)
  AND result_code = 'DENIED'
GROUP BY user_account, user_name
HAVING COUNT(*) > #{threshold}
```

### 동작 원리

```
최근 30분간 result_code = 'DENIED' 건만 집계:

  hong: DENIED 2건 → 5회 미달 → 정상
  kim:  DENIED 8건 → 5회 초과 → ★ 탐지
```

### 탐지 시나리오

- 비인가 DB/테이블에 대한 무차별 접근 시도
- 권한 변경 후 기존 권한으로 반복 접근
- SQL Injection 시도 (실패 반복)

---

## R04. 고등급 PII 대량 접근 (PII_GRADE)

| 항목 | 설정값 |
|------|--------|
| 심각도 | HIGH |
| 시간 윈도우 | 60분 (설정 가능) |
| 임계값 | 50건 (설정 가능) |
| 대상 PII 등급 | 1급 (설정 가능) |
| 탐지 의미 | 최고위험 개인정보에 대한 비정상 대량 접근 |

### SQL

```sql
SELECT user_account AS userAccount,
       user_name AS userName,
       COUNT(*) AS piiAccessCount,
       GROUP_CONCAT(DISTINCT log_id ORDER BY log_id LIMIT 10) AS logIds
FROM COTDL.TBL_ACCESS_LOG
WHERE access_time >= DATE_SUB(NOW(), INTERVAL #{timeWindowMin} MINUTE)
  AND pii_grade = #{piiGrade}
GROUP BY user_account, user_name
HAVING COUNT(*) > #{threshold}
```

### 동작 원리

```
최근 60분간 pii_grade = '1' (1급 PII) 접근만 집계:

PII 등급:
  1급: 주민번호, 계좌번호, 카드번호 등 (최고위험)
  2급: 주소, 이메일 등 (중위험)
  3급: 이름, 전화번호 등 (저위험)
  NULL: PII 아님

  hong: 1급 PII 접근 63건 → 50 초과 → ★ 탐지
  kim:  1급 PII 접근 12건 → 미달 → 정상
  park: 2급 PII 접근 80건 → 1급 아니므로 → 미해당
```

### 탐지 시나리오

- 주민번호/계좌번호 테이블 대량 조회 (유출 시도)
- 고객 정보 전수 조회
- R01(대량 접속)과 함께 탐지될 경우 위험도 상승

---

## R05. 동일 테이블 반복 접근 (REPEAT)

| 항목 | 설정값 |
|------|--------|
| 심각도 | MEDIUM |
| 시간 윈도우 | 30분 (설정 가능) |
| 임계값 | 30회 (설정 가능) |
| 탐지 의미 | 특정 테이블을 집중적으로 반복 조회 |

### SQL

```sql
SELECT user_account AS userAccount,
       user_name AS userName,
       target_table AS targetTable,
       COUNT(*) AS repeatCount,
       GROUP_CONCAT(DISTINCT log_id ORDER BY log_id LIMIT 10) AS logIds
FROM COTDL.TBL_ACCESS_LOG
WHERE access_time >= DATE_SUB(NOW(), INTERVAL #{timeWindowMin} MINUTE)
GROUP BY user_account, user_name, target_table
HAVING COUNT(*) > #{threshold}
```

### 동작 원리

```
최근 30분간 사용자 + 테이블 조합별 집계:

  hong + CUSTOMER:        42회 → 30 초과 → ★ 탐지
  hong + ORDER:           15회 → 미달 → 정상
  kim  + CUSTOMER:         8회 → 미달 → 정상
  kim  + CUSTOMER_DETAIL: 35회 → 30 초과 → ★ 탐지
```

### 탐지 시나리오

- 고객 정보를 1건씩 순차 조회 (화면 캡처, 수기 메모로 유출)
- WHERE 조건을 바꿔가며 전수 조회
- R01과 차이: R01은 전체 건수, R05는 **특정 테이블 집중 여부**

---

## R06. 미등록 IP 접근 (NEW_IP)

| 항목 | 설정값 |
|------|--------|
| 심각도 | MEDIUM |
| 비교 기간 | 과거 90일 |
| 탐지 의미 | 사용자가 처음 사용하는 IP에서의 접속 |

### SQL

```sql
SELECT a.user_account AS userAccount,
       a.user_name AS userName,
       a.client_ip AS clientIp,
       a.log_id AS logId
FROM COTDL.TBL_ACCESS_LOG a
WHERE a.access_time >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
  AND a.client_ip NOT IN (
      -- 이 사용자가 과거 90일간 사용한 적 있는 IP 목록
      SELECT DISTINCT client_ip
      FROM COTDL.TBL_ACCESS_LOG
      WHERE access_time >= DATE_SUB(NOW(), INTERVAL 90 DAY)
        AND access_time < DATE_SUB(NOW(), INTERVAL 1 HOUR)
        AND user_account = a.user_account
  )
GROUP BY a.user_account, a.user_name, a.client_ip
```

### 동작 원리

```
hong의 과거 90일 접속 IP 이력: [10.0.1.55, 10.0.1.56, 10.0.2.10]

최근 1시간 접속:
  hong → 10.0.1.55 → 이력에 있음 → 정상
  hong → 192.168.5.99 → 이력에 없음 → ★ 탐지 (clientIp: 192.168.5.99)
```

### 탐지 시나리오

- 계정 도용: 공격자가 다른 네트워크에서 탈취한 계정으로 접속
- VPN/프록시 우회 접근
- 자리 이동/재택근무 → 소명으로 해소
- 신규 입사자는 최초 접속 시 탐지될 수 있음 → 소명 처리

---

## R07. 장기미사용 계정 접근 (INACTIVE)

| 항목 | 설정값 |
|------|--------|
| 심각도 | HIGH |
| 비활성 기간 | 90일 (설정 가능) |
| 탐지 의미 | 오랫동안 사용하지 않던 계정이 갑자기 활성화 |

### SQL

```sql
SELECT a.user_account AS userAccount,
       a.user_name AS userName,
       a.log_id AS logId,
       a.access_time AS accessTime
FROM COTDL.TBL_ACCESS_LOG a
WHERE a.access_time >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
  AND a.user_account NOT IN (
      -- 과거 90일간 접속 이력이 있는 계정 목록
      SELECT DISTINCT user_account
      FROM COTDL.TBL_ACCESS_LOG
      WHERE access_time >= DATE_SUB(NOW(), INTERVAL #{inactiveDays} DAY)
        AND access_time < DATE_SUB(NOW(), INTERVAL 1 HOUR)
  )
GROUP BY a.user_account, a.user_name
```

### 동작 원리

```
과거 90일간 접속 이력이 있는 계정: [hong, kim, park, lee, ...]

최근 1시간 접속:
  hong → 이력 있음 → 정상
  choi → 이력 없음 (91일 전 마지막 접속) → ★ 탐지
```

### 탐지 시나리오

- 퇴직자 계정 도용 (퇴직 후 계정 미삭제)
- 휴직자 계정 무단 사용
- 부서 이동 후 이전 시스템 접근
- 신규 입사자 최초 접속 → 소명 처리

---

## R08. 휴일 접근 탐지 (HOLIDAY)

| 항목 | 설정값 |
|------|--------|
| 심각도 | MEDIUM |
| 연계 테이블 | TBL_PIIBIZDAY (영업일 달력) |
| 탐지 의미 | 주말/공휴일에 접속하는 사용자 |

### SQL

```sql
SELECT a.user_account AS userAccount,
       a.user_name AS userName,
       COUNT(*) AS accessCount,
       GROUP_CONCAT(DISTINCT a.log_id ORDER BY a.log_id LIMIT 10) AS logIds
FROM COTDL.TBL_ACCESS_LOG a
JOIN COTDL.TBL_PIIBIZDAY b
  ON DATE_FORMAT(a.access_time, '%Y%m%d') = b.BASE_DT
WHERE b.HLDY_YN = 'Y'
  AND a.access_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
GROUP BY a.user_account, a.user_name
HAVING COUNT(*) > 0
```

### 동작 원리

```
TBL_PIIBIZDAY 데이터:
  20260411 (토) → HLDY_YN = 'Y'
  20260412 (일) → HLDY_YN = 'Y'
  20260413 (월) → HLDY_YN = 'N'
  20260505 (월, 어린이날) → HLDY_YN = 'Y'  ← 공휴일도 포함

2026-04-11 (토요일) 접속:
  hong → 접속 → HLDY_YN='Y' → ★ 탐지
  kim  → 접속 없음 → 미해당
```

### R02(야간)와의 관계

```
                    평일          주말/공휴일
                 ─────────     ─────────────
  업무시간       정상           R08 탐지
  (09~20시)

  야간           R02 탐지      R02 + R08 동시 탐지
  (20~06시)                    (더 의심스러움 → 2건)
```

### 영업일 달력 관리

- `TBL_PIIBIZDAY`는 배치 Job(`DLM_BATCH_BIZDAY`)으로 고객사 처리계에서 수집
- 주말은 자동 휴일 처리
- 공휴일/임시휴일은 고객사가 등록 또는 처리계에서 수집
- 영업일 달력이 비어있으면 R08은 탐지 결과 없음 (안전)

---

## 탐지 실행 흐름

```
AccessLogScheduler (매 5분)
    │
    ▼
AccessLogDetectionEngineImpl.detectAll()
    │
    ├─ R01: detectVolumeAnomaly(threshold=100, timeWindowMin=60)
    ├─ R02: detectTimeRangeAnomaly(timeStart='20:00', timeEnd='06:00')
    ├─ R03: detectAccessDenied(threshold=5, timeWindowMin=30)
    ├─ R04: detectPiiGradeAnomaly(threshold=50, timeWindowMin=60, piiGrade='1')
    ├─ R05: detectRepeatAccess(threshold=30, timeWindowMin=30)
    ├─ R06: detectNewIp()
    ├─ R07: detectInactiveAccount(inactiveDays=90)
    └─ R08: detectHolidayAccess()
    │
    ▼
탐지된 건 → TBL_ACCESS_LOG_ALERT INSERT
    │
    ▼
대시보드 알림 표시 + 소명 프로세스
```

---

## 임계값 튜닝 가이드

| 규칙 | 기본값 | 금융사 권장 | 소규모 기관 권장 |
|------|--------|-----------|---------------|
| R01 임계값 | 100건 | 50~100건 | 200~500건 |
| R01 시간 윈도우 | 60분 | 30~60분 | 60~120분 |
| R02 야간 시작 | 20:00 | 19:00~22:00 | 22:00 |
| R02 야간 종료 | 06:00 | 06:00~08:00 | 06:00 |
| R03 임계값 | 5회 | 3~5회 | 10회 |
| R04 임계값 | 50건 | 20~50건 | 100건 |
| R05 임계값 | 30회 | 20~30회 | 50회 |
| R06 IP 이력 기간 | 90일 | 60~90일 | 90~180일 |
| R07 비활성 기간 | 90일 | 30~60일 | 90~180일 |

- **오탐이 많으면**: 임계값 올리기, 시간 윈도우 넓히기
- **탐지 누락이 우려되면**: 임계값 내리기, 시간 윈도우 좁히기
- 환경설정 화면에서 관리자가 직접 수정 가능 (저장 즉시 반영)

---

*본 문서는 AccessLogMapper.xml의 탐지 쿼리 기준으로 작성되었습니다.*
*규칙 설정은 DLM 접속기록관리 > 환경설정 > 이상행위 탐지 규칙에서 변경 가능합니다.*
