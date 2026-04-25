# 접속기록관리 금융사 요건 갭(Gap) 분석 및 추가 기능 설계서

> 작성일: 2026-04-17
> 버전: v1.0
> 목적: 금융사 법규·감독규정·타 솔루션 대비 DLM 접속기록관리 모듈의 갭 분석 및 추가 구현 설계
> 참조: 개인정보보호법, 안전성확보조치 고시(2023 개정), 전자금융감독규정(2025 개정), 신용정보법, 타 솔루션(소만사·넷앤드·신시웨이·웨어밸리·피앤피시큐어)

> **용어 안내**: 본 문서에서 "DLM"은 X-One 플랫폼의 기술 내부 명칭(Data Lifecycle Management)이며, 코드·인프라·DB에서 사용되는 기술명이다. 대외적으로는 "X-One 통합 데이터 관리 플랫폼"으로 표기한다.

---

## 1. 개요

### 1.1 배경

DLM 접속기록관리 모듈은 핵심 기능(수집, 해시검증, 이상행위탐지, 소명 워크플로우, 보고서, 파티션 관리)이 구현 완료된 상태이다. 그러나 금융사 납품을 위해 다음 기준을 충족해야 한다:

- **안전성확보조치 고시** 제8조 (2023년 개정) — "처리한 정보주체 정보" 필수항목 추가
- **전자금융감독규정** 제32조, 제38조 — 권한이력 5년 보관, 감사추적
- **신용정보법** 제35조 — 정보주체 조회기록 열람권
- **금융분야 가이드라인** — 8개 필수항목, 일단위 모니터링, 별도 백업

### 1.2 현재 구현 상태 (완료)

| 기능 | 법적 근거 | 구현 수준 |
|------|-----------|-----------|
| 접속기록 자동 수집 (DB_AUDIT, DB_DAC, WAS_AGENT) | 고시 제8조① | 완료 |
| 필수 5개 항목 기록 (계정, 일시, IP, 수행업무, 대상테이블) | 고시 제8조① | 완료 |
| SHA-256 해시 체인 무결성 검증 | 고시 제8조③④ | 완료 (월 1회 스케줄러) |
| 이상행위 탐지 7가지 규칙 | 금융 가이드라인 | 완료 |
| 소명 워크플로우 (토큰 기반 72시간) | 내부통제 | 완료 |
| 보고서 생성/Excel 다운로드 (4종) | 전금감독규정 제38조 | 완료 |
| 파티션 기반 아카이빙 (5년 보관) | 전금감독규정 제32조 | 완료 |
| 다운로드 감사 로깅 | 고시 제8조⑤ | 완료 |
| 알림 예외 규칙 (Suppression) | 개보법 제29조 | 완료 |
| 이메일 알림 (비동기) | 내부통제 | 완료 |

### 1.3 타 솔루션 기능 비교

| 기능 | 피앤피시큐어 DBSAFER | 소만사 DB-i | 넷앤드 HIWARE | 웨어밸리 Chakra | 신시웨이 Petra | **DLM 현재** |
|------|---------------------|------------|--------------|----------------|---------------|-------------|
| 접속기록 자동 수집 | O | O | O | O | O | **O** |
| SQL 전문 로깅 | O | O | O | O | O | **O** (설정) |
| 위변조 방지 (해시) | O | O | O | O | O | **O** |
| 이상행위 탐지 | O | O | O | O | O | **O** |
| 소명 워크플로우 | △ | △ | △ | △ | X | **O** |
| 대량 다운로드 탐지 | O | O | O | O | O | **O** |
| 정보주체 기반 조회 | O | O | △ | △ | △ | **X** |
| 결재 기반 접근 통제 | O | △ | O | O | O | **X** |
| 정기 보고서 자동생성 | O | O | O | O | O | **O** |
| 역할 기반 접근 제어 | O | O | O | O | O | **△** |
| 개인정보 마스킹 | O | O | O | O | O | **X** |
| 별도 백업 | O | O | O | O | O | **X** |
| 다채널 알림 | O | O | O | △ | △ | **X** |
| 실시간 대시보드 | O | O | O | O | △ | **X** |

---

## 2. 갭 분석 종합

### 2.1 우선순위 기준

| 등급 | 기준 | 의미 |
|------|------|------|
| **P1** | 법적 필수 | 미준수 시 과태료·행정처분·감독 지적 |
| **P2** | 금융사 실무 표준 | 감독 검사 시 지적 가능, 타 솔루션 기본 기능 |
| **P3** | 경쟁력 강화 | 차별화, 편의성, 시장 경쟁력 |

### 2.2 갭 목록

| # | 갭 항목 | 우선순위 | 법적 근거 | 현재 상태 |
|---|---------|---------|-----------|-----------|
| GAP-1 | 처리한 정보주체 정보 기록 | **P1** | 고시 제8조① (2023 개정) | 부분구현 |
| GAP-2 | 접속기록 별도 백업 | **P1** | 고시 제8조③, 전금감독규정 제38조 | 미구현 |
| GAP-3 | 역할 기반 접근 제어 (RBAC) | **P1** | 고시 제5조, 전금감독규정 제32조 | 부분구현 |
| GAP-4 | 접속기록 내 개인정보 마스킹 | **P1** | 개보법 제29조, 금융 가이드라인 | 미구현 |
| GAP-5 | 권한 부여/변경/삭제 이력 | **P2** | 전금감독규정 제32조 | 미구현 |
| GAP-6 | 감사 대응 보고서 | **P2** | 전금감독규정 제38조 | 부분구현 |
| GAP-7 | 정보주체 조회기록 열람 | **P2** | 신용정보법 제35조, 개보법 제35조 | 미구현 |
| GAP-8 | 결재 기반 사전 접근 통제 | **P2** | 금융 가이드라인, 타 솔루션 표준 | 미구현 |
| GAP-9 | 다채널 알림 (SMS/카카오) | **P3** | — | 미구현 |
| GAP-10 | 실시간 대시보드 (WebSocket) | **P3** | — | 미구현 |
| GAP-11 | 출력(PRINT) 행위 기록 | **P3** | 고시 제8조① "출력" 포함 | 미구현 |
| GAP-12 | AI 기반 이상행위 분석 | **P3** | — | 예약만 |

---

## 3. P1 — 법적 필수 기능 상세 설계

### 3.1 GAP-1: 처리한 정보주체 정보 기록

#### 3.1.1 요건

2023년 안전성확보조치 고시 제8조① 개정으로 접속기록 필수항목이 5개에서 **6개**로 확대되었다:

| # | 필수항목 | DLM 매핑 필드 | 상태 |
|---|---------|--------------|------|
| 1 | 계정(ID) | `user_account` | 완료 |
| 2 | 접속일시 | `access_time` | 완료 |
| 3 | 접속지 정보 | `client_ip` | 완료 |
| 4 | 수행업무 | `action_type` | 완료 |
| 5 | 처리한 정보주체 정보 | **미매핑** | **미흡** |
| 6 | 처리한 정보항목 (권장) | `target_columns`, `pii_type_codes` | 완료 |

> "처리한 정보주체 정보"란 접속한 자가 **누구의 개인정보를** 처리했는지 알 수 있는 정보를 말한다.
> 예: 고객번호, 고객명, 주민등록번호 앞자리 등 정보주체를 식별할 수 있는 키 값

#### 3.1.2 설계

**DDL 변경:**

```sql
ALTER TABLE TBL_ACCESS_LOG
  ADD COLUMN data_subject_id    VARCHAR(200) NULL COMMENT '처리한 정보주체 식별자 (고객번호 등)',
  ADD COLUMN data_subject_count INT          NULL COMMENT '처리한 정보주체 건수';

CREATE INDEX idx_access_log_subject
  ON TBL_ACCESS_LOG (data_subject_id, access_time);
```

**도메인 변경 — `AccessLogVO.java`:**

```java
private String dataSubjectId;     // 정보주체 식별자 (예: 고객번호, 복수 시 쉼표 구분)
private Integer dataSubjectCount; // 처리한 정보주체 건수
```

**수집 로직 — 정보주체 추출 방식:**

| 수집 방식 | 추출 방법 |
|-----------|----------|
| WAS_AGENT | Agent가 SQL WHERE절에서 PII 컬럼(고객번호 등) 조건값 추출 |
| DB_AUDIT | Audit 로그의 bind variable에서 PII 컬럼 값 추출 |
| DB_DAC | DAC 쿼리 결과의 정보주체 관련 컬럼 매핑 |

**Agent 수집 흐름:**

```
1. Agent가 JDBC SQL 파싱 시 WHERE절 분석
2. BCI Target에 등록된 PII 컬럼 (예: CUST_NO, CUST_NM) 매칭
3. 조건값이 존재하면 dataSubjectId에 기록
4. SELECT의 경우 ResultSet 건수를 dataSubjectCount에 기록
5. 마스킹 적용: 주민번호 → 앞 6자리만 기록 (예: 900101-*)
```

**조회 UI 반영:**

- `logs.jsp` 검색 조건에 "정보주체 ID" 필터 추가
- 상세 보기에 정보주체 정보 표시
- 보고서에 정보주체별 접근 통계 포함

**수정 대상 파일:**

| 파일 | 변경 내용 |
|------|----------|
| `AccessLogVO.java` | dataSubjectId, dataSubjectCount 필드 추가 |
| `AccessLogMapper.xml` | INSERT/SELECT 컬럼 추가, 검색 조건 추가 |
| `AccessLogCollectorImpl.java` | 수집 시 정보주체 매핑 로직 |
| `AgentApiController.java` | Agent 로그 수신 시 정보주체 필드 매핑 |
| `logs.jsp` | 검색 필터, 목록 컬럼, 상세 표시 추가 |
| DDL 패치 파일 | ALTER TABLE 스크립트 |

---

### 3.2 GAP-2: 접속기록 별도 백업

#### 3.2.1 요건

> 고시 제8조③: "접속기록이 위변조 및 도난, 분실되지 않도록 해당 접속기록을 안전하게 보관하여야 한다"
> 전자금융감독규정 제38조: "감사추적을 위한 기록을 유지"

현재 같은 DB 내 파티션 관리만 수행하며, **별도 경로/장치로의 백업이 없다**. 감독 검사 시 "접속기록과 운영 DB가 동일 장치에 있어 위변조 방지 미흡"으로 지적될 수 있다.

#### 3.2.2 설계

**백업 스케줄러 — `AccessLogBackupScheduler.java`:**

```
┌─────────────────────────────────────────────────┐
│  AccessLogBackupScheduler                       │
│  cron: 매일 04:00 (BACKUP_SCHEDULE 설정)        │
├─────────────────────────────────────────────────┤
│  1. 전일 접속기록 조회 (partition_key 기준)      │
│  2. CSV 파일 생성 (UTF-8, 헤더 포함)            │
│  3. SHA-256 해시 매니페스트 파일 생성            │
│  4. AES-256 암호화 (선택, BACKUP_ENCRYPT=Y)     │
│  5. 백업 경로에 저장                            │
│  6. 이력 테이블에 결과 기록                     │
│  7. 보관기간 초과 백업 파일 삭제                │
└─────────────────────────────────────────────────┘
```

**백업 파일 구조:**

```
{BACKUP_PATH}/
  └── 2026/
      └── 04/
          ├── accesslog_20260416.csv.enc       ← 암호화된 접속기록
          ├── accesslog_20260416.manifest      ← SHA-256 해시 매니페스트
          └── accesslog_20260416.meta.json     ← 메타데이터 (건수, 생성시간 등)
```

**매니페스트 파일 예시:**

```json
{
  "date": "2026-04-16",
  "totalRecords": 15234,
  "sha256": "a1b2c3d4...",
  "generatedAt": "2026-04-17T04:00:15",
  "generatedBy": "DLM_BACKUP_SCHEDULER"
}
```

**DDL — 백업 이력:**

```sql
CREATE TABLE TBL_ACCESS_LOG_BACKUP_HISTORY (
  backup_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
  backup_date     DATE         NOT NULL COMMENT '백업 대상 일자',
  file_path       VARCHAR(500) NOT NULL COMMENT '백업 파일 경로',
  file_size_bytes BIGINT       NULL     COMMENT '파일 크기',
  record_count    INT          NOT NULL COMMENT '백업 건수',
  hash_value      VARCHAR(64)  NOT NULL COMMENT '파일 SHA-256 해시',
  encrypted       CHAR(1)      DEFAULT 'N' COMMENT '암호화 여부',
  status          VARCHAR(20)  NOT NULL COMMENT 'SUCCESS/FAILED',
  error_msg       TEXT         NULL     COMMENT '오류 메시지',
  started_at      DATETIME     NOT NULL,
  completed_at    DATETIME     NULL,
  created_at      DATETIME     DEFAULT NOW()
) ENGINE=InnoDB;
```

**설정 항목:**

| 설정키 | 기본값 | 설명 |
|--------|--------|------|
| `BACKUP_ENABLED` | N | 백업 기능 활성화 |
| `BACKUP_PATH` | /backup/accesslog | 백업 저장 경로 |
| `BACKUP_SCHEDULE` | 0 0 4 * * * | 실행 주기 (매일 04:00) |
| `BACKUP_ENCRYPT` | Y | AES-256 암호화 여부 |
| `BACKUP_ENCRYPT_KEY` | (설정 필수) | 암호화 키 |
| `BACKUP_RETENTION_DAYS` | 1825 | 백업 보관일수 (5년=1825일) |

**복원(Restore) 기능:**

- 관리자 UI에서 백업 이력 조회
- 특정 날짜 백업 파일 선택 → 복원 실행
- 복원 시 기존 데이터와 중복 체크 (log_id 기준)
- 복원 이력 기록

**수정 대상 파일:**

| 파일 | 변경 내용 |
|------|----------|
| 신규 `AccessLogBackupScheduler.java` | 백업 스케줄러 |
| 신규 `AccessLogBackupService.java` | 백업/복원 비즈니스 로직 |
| DDL 패치 파일 | TBL_ACCESS_LOG_BACKUP_HISTORY |
| `settings.jsp` | 백업 설정 UI 섹션 추가 |
| `AccessLogController.java` | 백업 이력 조회/복원 API |

---

### 3.3 GAP-3: 역할 기반 접근 제어 (RBAC)

#### 3.3.1 요건

> 고시 제5조: "접근권한을 업무 수행에 필요한 최소한의 범위로 차등 부여"
> 전자금융감독규정 제32조: "접근권한 부여·변경·삭제 기록을 보관"

현재 모든 접속기록 API가 `@PreAuthorize("isAuthenticated()")`만 검사하여, 인증된 사용자면 누구나 전체 기능에 접근 가능하다.

#### 3.3.2 역할 설계

| 역할 | 코드 | 권한 범위 |
|------|------|----------|
| 접속기록 관리자 | `ROLE_ALOG_ADMIN` | 전체 기능 (설정, 규칙, 수집원, 삭제 포함) |
| 접속기록 감사자 | `ROLE_ALOG_AUDITOR` | 조회, 보고서 생성/다운로드, 해시 검증, 소명 승인/거부 |
| 접속기록 조회자 | `ROLE_ALOG_VIEWER` | 기본 조회만 (마스킹 적용), 보고서 열람 |

#### 3.3.3 API별 권한 매핑

| API | 현재 | 변경 후 |
|-----|------|---------|
| `GET /api/logs` (목록 조회) | isAuthenticated | VIEWER 이상 |
| `GET /api/logs/{id}` (상세) | isAuthenticated | VIEWER 이상 |
| `POST /api/logs/download` | isAuthenticated | AUDITOR 이상 |
| `GET /api/dashboard-stats` | isAuthenticated | VIEWER 이상 |
| `POST /api/report/generate` | isAuthenticated | AUDITOR 이상 |
| `GET /api/report/{id}/download` | isAuthenticated | AUDITOR 이상 |
| `POST /api/alert/{id}/approve` | isAuthenticated | AUDITOR 이상 |
| `POST /api/alert-rule` (생성) | isAuthenticated | **ADMIN만** |
| `PUT /api/alert-rule/{id}` (수정) | isAuthenticated | **ADMIN만** |
| `DELETE /api/alert-rule/{id}` | isAuthenticated | **ADMIN만** |
| `POST /api/source` (수집원 등록) | isAuthenticated | **ADMIN만** |
| `PUT /api/config` (설정 변경) | isAuthenticated | **ADMIN만** |
| `POST /api/suppression` (예외 등록) | isAuthenticated | **ADMIN만** |

#### 3.3.4 구현 방식

```java
// AccessLogController.java 예시
@GetMapping("/api/logs")
@PreAuthorize("hasAnyRole('ALOG_ADMIN','ALOG_AUDITOR','ALOG_VIEWER')")
public ResponseEntity<?> getAccessLogs(...) { ... }

@PostMapping("/api/alert-rule")
@PreAuthorize("hasRole('ALOG_ADMIN')")
public ResponseEntity<?> createAlertRule(...) { ... }
```

**VIEWER 역할의 마스킹 연동:**
- VIEWER로 조회 시 자동으로 마스킹 적용 (GAP-4 연동)
- AUDITOR 이상은 원본 데이터 확인 가능

**수정 대상 파일:**

| 파일 | 변경 내용 |
|------|----------|
| `AccessLogController.java` | @PreAuthorize 어노테이션 변경 (전체 API) |
| `SecurityConfig.java` | 역할 정의, URL 패턴별 접근 제어 |
| `settings.jsp` | 역할 할당 UI |
| 관련 JSP 파일 | 역할별 버튼/메뉴 표시 제어 (sec:authorize 태그) |

---

### 3.4 GAP-4: 접속기록 내 개인정보 마스킹

#### 3.4.1 요건

> 개보법 제29조: 개인정보의 안전성 확보에 필요한 조치
> 금융분야 가이드라인: 접속기록 열람 시 최소 권한 원칙 적용

접속기록 자체에 개인정보가 포함될 수 있다:
- `user_name`: 차민석 → **차*석**
- `client_ip`: 192.168.1.100 → **192.168.*.**
- `user_account`: chaminseok → **cha*****k**
- `sql_text`: WHERE cust_no = '900101-1234567' → **WHERE cust_no = '900101-*******'**
- `search_condition`: 주민등록번호 등 리터럴 포함 가능
- `data_subject_id` (GAP-1): 고객번호 → 일부 마스킹

#### 3.4.2 마스킹 정책

| 필드 | VIEWER | AUDITOR | ADMIN |
|------|--------|---------|-------|
| user_account | cha****k | 원본 | 원본 |
| user_name | 차*석 | 원본 | 원본 |
| client_ip | 192.168.*.* | 원본 | 원본 |
| sql_text | 리터럴 마스킹 | 원본 | 원본 |
| search_condition | 리터럴 마스킹 | 원본 | 원본 |
| data_subject_id | 앞3자리만 표시 | 원본 | 원본 |

#### 3.4.3 구현

**마스킹 유틸리티 — `AccessLogMaskingUtil.java`:**

```java
public class AccessLogMaskingUtil {

    /** 이름 마스킹: 차민석 → 차*석, 홍길동 → 홍*동 */
    public static String maskName(String name) { ... }

    /** 계정 마스킹: chaminseok → cha****k */
    public static String maskAccount(String account) { ... }

    /** IP 마스킹: 192.168.1.100 → 192.168.*.* */
    public static String maskIp(String ip) { ... }

    /** SQL 리터럴 마스킹: 문자열/숫자 리터럴을 '***' 로 치환 */
    public static String maskSqlLiterals(String sql) { ... }

    /** 정보주체 ID 마스킹: C001234 → C00**** */
    public static String maskSubjectId(String id) { ... }

    /** 역할에 따라 AccessLogVO 전체 마스킹 적용 */
    public static void applyMasking(AccessLogVO log, String role) {
        if ("ROLE_ALOG_VIEWER".equals(role)) {
            log.setUserName(maskName(log.getUserName()));
            log.setUserAccount(maskAccount(log.getUserAccount()));
            log.setClientIp(maskIp(log.getClientIp()));
            log.setSqlText(maskSqlLiterals(log.getSqlText()));
            log.setSearchCondition(maskSqlLiterals(log.getSearchCondition()));
            log.setDataSubjectId(maskSubjectId(log.getDataSubjectId()));
        }
    }
}
```

**적용 지점:**

```
AccessLogController → AccessLogServiceImpl.getAccessLogs()
  → DB 조회 후, 응답 직전에 현재 사용자 역할 확인
  → VIEWER이면 마스킹 적용 후 반환
  → 다운로드(Excel) 시에도 동일 정책 적용
```

**수정 대상 파일:**

| 파일 | 변경 내용 |
|------|----------|
| 신규 `AccessLogMaskingUtil.java` | 마스킹 유틸리티 |
| `AccessLogServiceImpl.java` | 조회 결과에 역할 기반 마스킹 적용 |
| `AccessLogReportService.java` | 보고서 생성 시 마스킹 적용 |
| `AccessLogController.java` | 현재 사용자 역할 전달 |

---

## 4. P2 — 금융사 실무 표준 상세 설계

### 4.1 GAP-5: 권한 부여/변경/삭제 이력 관리

#### 4.1.1 요건

> 전자금융감독규정 제32조: "전산자료에 대한 접근권한 부여·변경·삭제 기록을 5년간 보관"

현재 `AuthToChangeVO`로 권한 변경 처리만 하고, **이력(history)을 남기지 않는다**.

#### 4.1.2 설계

**DDL:**

```sql
CREATE TABLE TBL_ACCESS_AUTH_HISTORY (
  history_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id      VARCHAR(50)  NOT NULL COMMENT '대상 사용자 ID',
  auth_type    VARCHAR(50)  NOT NULL COMMENT '권한 유형 (ROLE_ALOG_ADMIN 등)',
  action       VARCHAR(20)  NOT NULL COMMENT 'GRANT / REVOKE / CHANGE',
  prev_value   VARCHAR(200) NULL     COMMENT '변경 전 값',
  new_value    VARCHAR(200) NULL     COMMENT '변경 후 값',
  changed_by   VARCHAR(50)  NOT NULL COMMENT '변경 수행자',
  reason       VARCHAR(500) NULL     COMMENT '변경 사유',
  changed_at   DATETIME     DEFAULT NOW(),
  INDEX idx_auth_hist_user   (user_id, changed_at),
  INDEX idx_auth_hist_action (action, changed_at)
) ENGINE=InnoDB;
```

**구현 방식 — AOP:**

```java
@Aspect
@Component
public class AuthChangeAuditAspect {
    @Around("execution(* datablocks.dlm.mapper.PiiAuthMapper.update(..))")
    public Object auditAuthChange(ProceedingJoinPoint pjp) {
        // 1. 변경 전 상태 조회
        // 2. 실제 변경 수행
        // 3. TBL_ACCESS_AUTH_HISTORY에 이력 INSERT
    }
}
```

**조회 UI:**

- `settings.jsp` 내 "권한 변경 이력" 탭 추가
- 사용자별/기간별 검색
- Excel 다운로드 (감사 대응용)

---

### 4.2 GAP-6: 감사 대응 보고서

#### 4.2.1 요건

> 전자금융감독규정 제38조: "감사추적(Audit Trail)을 위한 기록을 유지"

금감원·개보위 현장 검사 시 **즉시 제출 가능한 표준 양식 보고서**가 필요하다.

#### 4.2.2 추가 보고서 유형

| 보고서 코드 | 명칭 | 내용 |
|------------|------|------|
| `AUDIT_RESPONSE` | 감사 대응 보고서 | 기간별 접속기록 전체 현황 + 해시검증 결과 + 이상행위 요약 |
| `INCIDENT` | 사건 대응 보고서 | 특정 사용자/테이블/기간 조합의 상세 접근 이력 + 증거 체인 |

**감사 대응 보고서 구성:**

```
1. 요약 (Summary)
   - 기간, 총 접속건수, 사용자 수, 이상행위 건수
2. 해시 무결성 검증 결과
   - 일별 검증 현황, 위반 건수, 첫 위반 ID
3. 이상행위 탐지 현황
   - 규칙별 발생 건수, 심각도별 분포
4. 소명 처리 현황
   - 요청/완료/미처리 건수, SLA 준수율
5. 접속기록 상세
   - 전체 접속기록 (필터 적용 가능)
```

**수정 대상 파일:**

| 파일 | 변경 내용 |
|------|----------|
| `AccessLogReportService.java` | AUDIT_RESPONSE, INCIDENT 보고서 생성 로직 |
| `AccessLogMapper.xml` | 감사 대응용 통합 조회 쿼리 |
| `reports.jsp` | 보고서 유형 선택에 2종 추가 |

---

### 4.3 GAP-7: 정보주체 조회기록 열람

#### 4.3.1 요건

> 신용정보법 제35조: 정보주체가 자신의 개인신용정보 조회기록 열람 가능
> 개보법 제35조: 정보주체의 개인정보 열람 요구권

#### 4.3.2 설계

금융사 실무에서는 고객이 직접 DLM에 접속하지 않으므로, **관리자가 정보주체 ID로 검색하여 결과를 제공하는 반자동 방식**이 현실적이다.

**구현 방안:**

```
1. logs.jsp에 "정보주체 조회" 전용 검색 모드 추가
2. data_subject_id 기반 검색 (GAP-1 필드 활용)
3. 검색 결과를 Excel/PDF로 내보내기
4. 열람 제공 이력 기록 (TBL_ACCESS_LOG_DOWNLOAD에 purpose='DATA_SUBJECT_REQUEST')
```

**향후 확장:**
- 고객 포털 연동 API (`GET /api/data-subject/{subjectId}/access-history`)
- 본인인증 연동 (PASS, 공동인증서 등)

---

### 4.4 GAP-8: 결재 기반 사전 접근 통제

#### 4.4.1 요건

> 금융분야 가이드라인: 고위험 데이터 접근 시 사전 승인 필요
> 타 솔루션 공통 기능 (넷앤드 HIWARE, 웨어밸리 Chakra 등)

#### 4.4.2 설계 (대규모 — 별도 프로젝트 권장)

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  사용자       │───→│  결재 요청    │───→│  승인자       │
│  (DB 접근)   │    │  (자동 생성)  │    │  (관리자)     │
└──────────────┘    └──────────────┘    └──────────────┘
       │                    │                    │
       ▼                    ▼                    ▼
  Agent 정책 확인     TBL_ACCESS_APPROVAL    승인/거부 처리
  → 미승인 시 차단      결재 이력 저장        → 이메일 알림
  → 또는 경고 후 기록                        → 유효기간 설정
```

**적용 대상 (정책 기반):**
- PII 등급 1~2 테이블 접근
- 1,000건 이상 대량 조회
- 업무시간 외 접근
- 비정상 IP에서의 접근

**DDL:**

```sql
CREATE TABLE TBL_ACCESS_APPROVAL (
  approval_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
  requester_id   VARCHAR(50)  NOT NULL,
  target_table   VARCHAR(200) NOT NULL,
  action_type    VARCHAR(20)  NOT NULL,
  reason         VARCHAR(500) NOT NULL,
  approver_id    VARCHAR(50)  NULL,
  status         VARCHAR(20)  DEFAULT 'PENDING' COMMENT 'PENDING/APPROVED/REJECTED/EXPIRED',
  valid_from     DATETIME     NULL,
  valid_until    DATETIME     NULL,
  decided_at     DATETIME     NULL,
  created_at     DATETIME     DEFAULT NOW()
) ENGINE=InnoDB;
```

> **참고**: 이 기능은 Agent 정책 변경, 결재 UI, 실시간 차단 로직 등 대규모 변경을 수반하므로 별도 프로젝트 단위로 검토한다.

---

## 5. P3 — 경쟁력 강화 기능 설계

### 5.1 GAP-9: 다채널 알림 (SMS/카카오톡/Slack)

**현재**: `AccessLogEmailService`에서 이메일만 지원

**설계 — 인터페이스 분리:**

```java
public interface AccessLogNotificationChannel {
    void send(NotificationMessage message);
    boolean isAvailable();
    String getChannelType(); // EMAIL, SMS, KAKAO, SLACK
}

// 구현체
EmailNotificationChannel     // 기존 이메일 (리팩토링)
SmsNotificationChannel       // SMS API 연동 (NHN Cloud, CoolSMS 등)
KakaoNotificationChannel     // 카카오 알림톡 API
SlackNotificationChannel     // Slack Webhook
```

**설정:**
- `NOTIFICATION_CHANNELS`: EMAIL,SMS (활성 채널 목록)
- `SMS_API_KEY`, `SMS_SENDER_NUMBER`: SMS 설정
- `KAKAO_API_KEY`, `KAKAO_TEMPLATE_CODE`: 카카오 알림톡 설정

### 5.2 GAP-10: 실시간 대시보드 (WebSocket/SSE)

**현재**: 폴링 기반 (수동 새로고침)

**설계:**

```
WebSocketConfig → /ws/accesslog
  ├── 신규 접속기록 실시간 스트리밍
  ├── 이상행위 알림 실시간 push
  └── 수집 상태 변경 알림
```

**적용 대상 화면:**
- `dashboard.jsp`: 시간대별 차트 실시간 업데이트
- `alerts.jsp`: 신규 알림 자동 갱신
- `sources.jsp`: 수집 상태 실시간 표시

### 5.3 GAP-11: 출력(PRINT) 행위 기록

**현재**: actionType에 DOWNLOAD/EXPORT만 존재

**설계:**
- actionType에 `PRINT` 유형 추가
- 브라우저 `window.print()` 호출 시 JavaScript에서 서버로 기록 전송
- Java Agent (BCI)에서도 리포트 출력 이벤트 캡처

### 5.4 GAP-12: AI 기반 이상행위 분석

**현재**: `ReportType.AI_ANALYSIS` 예약만 존재

**설계 (DLM-Privacy-AI 연동):**

```
접속기록 → 행동 패턴 벡터화 → 베이스라인 학습 → 편차 탐지
  ├── 사용자별 접근 패턴 프로파일링
  ├── 시계열 이상 탐지 (Isolation Forest, LSTM)
  ├── 동료 그룹 대비 이탈도 분석
  └── 위험도 스코어링 (0~100)
```

> **참조**: `DLM_접속기록관리_AI기능_요건정의서.md` 참고

---

## 6. 구현 로드맵

```
Phase 1 (즉시 착수) ─── 법적 필수
│
├── GAP-1: 정보주체 정보 필드
│   ├── DDL 패치
│   ├── VO/Mapper 변경
│   ├── 수집 로직 변경
│   └── UI 반영
│
├── GAP-2: 접속기록 별도 백업
│   ├── 백업 스케줄러
│   ├── 암호화/매니페스트
│   ├── 복원 기능
│   └── 설정 UI
│
├── GAP-3: RBAC 역할 분리
│   ├── 역할 정의 (ADMIN/AUDITOR/VIEWER)
│   ├── Controller @PreAuthorize 변경
│   ├── SecurityConfig 변경
│   └── JSP 역할별 표시 제어
│
└── GAP-4: 개인정보 마스킹
    ├── MaskingUtil 구현
    ├── Service 레이어 적용
    └── 보고서/다운로드 적용

Phase 2 (단기) ─── 감독 대응
│
├── GAP-5: 권한 변경 이력
├── GAP-6: 감사 대응 보고서 (2종)
├── GAP-7: 정보주체 열람권
└── GAP-8: 결재 기반 접근 통제 (설계/PoC)

Phase 3 (중기) ─── 경쟁력
│
├── GAP-9: 다채널 알림
├── GAP-10: 실시간 대시보드
└── GAP-11: 출력 행위 기록

Phase 4 (장기) ─── 차별화
│
└── GAP-12: AI 이상행위 분석
```

---

## 7. 참조 법규 요약

| 법규 | 조항 | 핵심 요건 |
|------|------|-----------|
| 개인정보보호법 | 제29조 | 안전조치의무 (접속기록 보관) |
| 시행령 | 제48조의2, 제30조 | 안전성확보조치 기준 위임 |
| 안전성확보조치 고시 | 제5조 | 접근권한 관리 (최소 권한) |
| 안전성확보조치 고시 | 제8조①~⑤ | 필수항목 6개, 보관 2년, 위변조방지, 월1회 점검, 대량다운로드 탐지 |
| 전자금융감독규정 | 제13조 | 전산자료 보호대책 |
| 전자금융감독규정 | 제17조 | DB 접속기록 관리 |
| 전자금융감독규정 | 제32조 | 접근권한 부여·변경·삭제 기록 5년 보관 |
| 전자금융감독규정 | 제37조 | 전자금융거래 기록 5년 보존 |
| 전자금융감독규정 | 제38조 | 감사추적(Audit Trail) 기록 유지 |
| 신용정보법 | 제19조 | 접근기록 보관의무 |
| 신용정보법 | 제35조 | 정보주체 조회기록 열람권 |
| 금융분야 가이드라인 | — | 8개 필수항목, 5년 보관, 이상행위탐지 필수 |
| 정보통신망법 (ISMS-P) | 2.9.4, 2.5.6 | 로그 관리, 접근권한 검토 |
