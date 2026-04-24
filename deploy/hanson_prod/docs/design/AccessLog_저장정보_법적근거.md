# 접속기록(Access Log) 저장 정보 및 법적 근거

> 작성일: 2026-04-11
> 버전: v1.0
> 대상 테이블: COTDL.TBL_ACCESS_LOG

> **용어 안내**: 본 문서에서 "DLM"은 X-One 플랫폼의 기술 내부 명칭(Data Lifecycle Management)이며, 코드·인프라·DB에서 사용되는 기술명이다. 대외적으로는 "X-One 통합 데이터 관리 플랫폼"으로 표기한다.

---

## 1. 개요

DLM의 접속기록 관리 모듈은 개인정보처리시스템에 대한 모든 접근 이력을 수집, 저장, 감사하기 위한 시스템이다.
DLM Java Agent(ByteBuddy BCI)가 WAS의 JDBC 호출을 가로채어 SQL을 실시간 파싱하고, DLM 서버로 배치 전송하여 `TBL_ACCESS_LOG`에 적재한다.

### 적용 범위

- DLM Agent가 설치된 WAS (Java 기반 애플리케이션 서버)
- DB Audit Log 수집 (Oracle, MariaDB 등)
- 향후 Application SDK (BCI 불가 환경)

---

## 2. 법적 근거

### 2.1 개인정보보호법

| 조항 | 내용 |
|------|------|
| **제29조 (안전조치의무)** | 개인정보처리자는 개인정보가 분실, 도난, 유출, 위조, 변조 또는 훼손되지 않도록 안전성 확보에 필요한 기술적, 관리적 및 물리적 조치를 하여야 한다 |
| **시행령 제30조** | 접속기록의 보관 및 점검에 관한 사항을 안전성 확보조치에 포함 |

### 2.2 개인정보의 안전성 확보조치 기준 (고시)

| 조항 | 내용 |
|------|------|
| **제8조 제1항** | 개인정보처리자는 개인정보처리시스템에 접속한 기록을 1년 이상 보관, 관리하여야 한다 |
| **제8조 제2항** | 5만명 이상의 정보주체에 관한 개인정보를 처리하거나, 고유식별정보 또는 민감정보를 처리하는 경우 **2년 이상** 보관 |
| **제8조 제3항** | 접속기록에는 **식별자, 접속일시, 접속지 정보, 처리한 정보주체 정보, 수행업무**를 포함하여야 한다 |
| **제8조 제4항** | 접속기록이 **위변조 및 도난, 분실되지 않도록** 해당 접속기록을 안전하게 보관하여야 한다 |

### 2.3 정보통신망법 (ISMS-P 관련)

| 항목 | 내용 |
|------|------|
| **2.9.4 로그 및 접속기록 관리** | 서버, 응용프로그램, 보안시스템 등의 접근기록을 안전하게 보관 |
| **2.5.6 접근권한 검토** | 접속기록을 반기별 1회 이상 점검하여 불법적인 접근 여부 확인 |

### 2.4 금융 분야 (해당 시)

| 근거 | 내용 |
|------|------|
| **전자금융감독규정 제13조** | 전산자료 및 접근기록의 보관 — **5년** |
| **개인신용정보 관련** | 신용정보법에 따른 접근기록 보관의무 |

---

## 3. 법적 필수 기록 항목과 DLM 매핑

안전성 확보조치 기준 **제8조 제3항**이 요구하는 5대 항목과 DLM 대응:

| 법적 필수 항목 | 의미 | DLM 칼럼 | 저장 여부 |
|---|---|---|---|
| **식별자** (누가) | 접속한 사용자 계정 | `user_account`, `user_name`, `department` | O (항상) |
| **접속일시** (언제) | 접속한 날짜와 시간 | `access_time` (DATETIME(3), 밀리초 정밀도) | O (항상) |
| **접속지 정보** (어디서) | 접속자의 IP 주소 등 | `client_ip` (IPv6 대응), `session_id`, `access_channel` | O (항상) |
| **처리한 정보주체 정보** (누구의) | 접근 대상 및 조건 | `target_db`, `target_schema`, `target_table`, `target_columns`, `search_condition` | O (항상) |
| **수행업무** (무엇을) | 조회/수정/삭제 등 행위 | `action_type` (SELECT/INSERT/UPDATE/DELETE/DOWNLOAD/EXPORT) | O (항상) |

> **핵심**: 위 5대 항목은 SQL 전문 저장 옵션(`SQL_TEXT_LOGGING`)과 **무관하게 항상 저장**된다.
> SQL 파싱을 통해 메타데이터를 추출하므로 SQL 원문 없이도 법적 요건 충족이 가능하다.

---

## 4. SQL 유형(action_type) 구분의 법적 필요성

### 4.1 구분이 필요한 이유

안전성 확보조치 기준 제8조 제3항의 **"수행업무"** 항목은 단순히 "접속했다"가 아니라 **무엇을 했는지**를 기록할 것을 요구한다.

| 행위 유형 | 법적/감사적 의미 | 위험도 |
|---|---|---|
| **SELECT** (조회) | 개인정보 열람 — 유출 가능성 판단의 기초 | 보통 |
| **UPDATE** (수정) | 개인정보 변경 — 위변조 여부 판단 | 높음 |
| **DELETE** (삭제) | 개인정보 파기 — 무단 삭제 여부 판단 | 매우 높음 |
| **INSERT** (입력) | 개인정보 생성 — 무단 수집 여부 판단 | 보통 |
| **DOWNLOAD/EXPORT** | 개인정보 반출 — 유출 사고의 직접 원인 | 매우 높음 |

### 4.2 DLM의 action_type 감지 방식

DLM Agent의 `SqlAnalyzer.detectActionType()`이 SQL 문 앞부분(prefix)으로 판별:

```
SELECT ... → "SELECT"
INSERT ... → "INSERT"
UPDATE ... → "UPDATE"
DELETE ... → "DELETE"
MERGE  ... → "MERGE"
CALL   ... → "CALL"
기타       → "OTHER"
```

- SQL 전문 저장 여부와 **완전히 독립적**으로 동작
- SQL이 Agent에서 파싱된 후 `action_type`은 항상 추출되어 전송됨
- `TBL_ACCESS_LOG.action_type`은 NOT NULL + 인덱스 포함

### 4.3 SQL 전문 없이도 충분한가?

| 상황 | SQL 전문 필요? | 이유 |
|---|---|---|
| 법적 기본 요건 충족 | **불필요** | `action_type` + `target_table` + `target_columns` + `search_condition`으로 5대 항목 충족 |
| 포렌식/사고조사 | 권장 | 정확한 SQL 재현이 필요한 경우 |
| ISMS-P 심사 | 상황에 따라 | 메타데이터 기록으로 대부분 충분, 심사원 판단에 따라 다름 |
| 금융권 감사 | 권장 | 감독규정상 전산자료 보관 범위에 포함될 수 있음 |

> **결론**: 법적 최소 요건은 메타데이터로 충족되나, 보안 사고 대응 및 금융권에서는 SQL 전문 저장(`SQL_TEXT_LOGGING = Y`)을 권장한다.

---

## 5. TBL_ACCESS_LOG 스키마 상세

| 칼럼 | 타입 | 필수 | 설명 | 법적 대응 |
|---|---|---|---|---|
| `log_id` | BIGINT (PK) | O | 로그 식별자 (AUTO_INCREMENT) | — |
| `source_system_id` | VARCHAR(36) | — | 수집원 시스템 ID | — |
| `user_account` | VARCHAR(100) | — | 접속자 계정 | **식별자** |
| `user_name` | VARCHAR(100) | — | 접속자 이름 | **식별자** |
| `department` | VARCHAR(100) | — | 소속 부서 | **식별자** |
| `access_time` | DATETIME(3) | O | 접속일시 (밀리초) | **접속일시** |
| `client_ip` | VARCHAR(45) | — | 접속지 IP (IPv6 대응) | **접속지 정보** |
| `action_type` | VARCHAR(20) | O | 수행업무: SELECT/UPDATE/DELETE/INSERT/DOWNLOAD/EXPORT | **수행업무** |
| `target_db` | VARCHAR(100) | — | 대상 DB명 | **정보주체 정보** |
| `target_schema` | VARCHAR(100) | — | 대상 스키마 | **정보주체 정보** |
| `target_table` | VARCHAR(200) | — | 대상 테이블 (파싱 결과) | **정보주체 정보** |
| `target_columns` | TEXT | — | 접근 칼럼 목록 (콤마 구분) | **정보주체 정보** |
| `pii_type_codes` | VARCHAR(500) | — | PII 유형 코드 | 개인정보 등급 분류 |
| `pii_grade` | CHAR(1) | — | 개인정보 등급 (1/2/3) | 민감정보 구분 |
| `affected_rows` | INT | — | 영향받은 행 수 | 대량 처리 탐지 |
| `search_condition` | TEXT | — | WHERE 조건문 | **정보주체 정보 (Whom)** |
| `sql_text` | TEXT | — | SQL 전문 (옵션, 기본 OFF) | 포렌식 용도 |
| `access_channel` | VARCHAR(20) | — | 접근 경로: WEB/WAS/DB_DIRECT/API/BATCH | **접속지 정보** |
| `session_id` | VARCHAR(100) | — | 세션 ID | 세션 추적 |
| `result_code` | VARCHAR(10) | — | 수행 결과: SUCCESS/FAIL/DENIED | 접근 거부 탐지 |
| `hash_value` | VARCHAR(64) | — | SHA-256 해시 | **위변조 방지** |
| `prev_hash` | VARCHAR(64) | — | 이전 레코드 해시 (체인) | **위변조 방지** |
| `collected_at` | DATETIME | — | DLM 수집 시간 | 수집 추적 |
| `partition_key` | VARCHAR(8) | — | 파티셔닝 키 (YYYYMMDD) | 보관/삭제 관리 |

### 인덱스 구성

| 인덱스 | 칼럼 | 용도 |
|---|---|---|
| PK | `log_id, access_time` | 파티셔닝 대응 복합 PK |
| `idx_al_access_time` | `access_time, source_system_id` | 기간 검색 |
| `idx_al_user_account` | `user_account, access_time` | 사용자별 조회 |
| `idx_al_target_table` | `target_db, target_schema, target_table, access_time` | 테이블별 조회 |
| `idx_al_action_type` | `action_type, access_time` | 행위 유형별 조회 |
| `idx_al_pii_grade` | `pii_grade, access_time` | 개인정보 등급별 조회 |
| `idx_al_hash` | `hash_value` | 해시 무결성 검증 |

### 파티셔닝

- 방식: `RANGE COLUMNS (access_time)` — 월별 파티션
- 보관: 기본 2년, 금융권 5년 (`RETENTION_PERIOD_YEARS`, `RETENTION_FINANCIAL_YEARS`)
- 아카이브: `TBL_ACCESS_LOG_ARCHIVE_HISTORY`로 이력 관리

---

## 6. 데이터 수집 흐름

```
WAS Application (JDBC 호출)
    │
    ▼
DLM Java Agent (ByteBuddy BCI)
    │  Statement/PreparedStatement 가로채기
    ▼
SqlAnalyzer
    │  ① detectActionType() → action_type 추출
    │  ② extractColumns()   → target_table, target_columns 추출
    │  ③ enrichPiiInfo()     → PII 정책 대조 (pii_grade, pii_type_codes)
    ▼
LogBuffer (비동기 큐, 기본 10,000건)
    │
    ▼
LogShipper (배치 500건, 3초 플러시)
    │  HTTP POST /api/agent/logs
    ▼
DLM Server (AgentApiController)
    │  AccessLogService.registerAccessLogBatch()
    │  해시 체인 생성 (SHA-256)
    ▼
TBL_ACCESS_LOG (MariaDB, 월별 파티션)
```

### 핵심 설정 (dlm-agent.properties)

| 설정 | 기본값 | 설명 |
|---|---|---|
| `dlm.buffer.capacity` | 10000 | Agent 내 로그 큐 크기 |
| `dlm.shipper.batch-size` | 500 | 배치 전송 건수 |
| `dlm.shipper.flush-interval-ms` | 3000 | 최대 대기 시간 (ms) |
| `dlm.exclude.sql-patterns` | SELECT 1, SELECT SYSDATE, PING, SET NAMES | 제외 SQL 패턴 |
| `dlm.exclude.users` | SYS, SYSTEM, MONITOR | 제외 계정 |
| `dlm.policy.sync-interval-ms` | 300000 | PII 정책 동기화 주기 (5분) |

---

## 7. SQL 파싱 구조

### 7.1 파싱 엔진

- **기본**: JSqlParser 라이브러리 (`CCJSqlParserUtil.parse()`)
- **폴백**: Regex 기반 테이블명 추출 (JSqlParser 실패 시)
- **캐시**: LRU 1,000건 (동일 SQL 반복 시 재파싱 방지)

### 7.2 추출 항목

| SQL 유형 | 테이블 추출 | 칼럼 추출 | 비고 |
|---|---|---|---|
| SELECT | FROM, JOIN 절 | SELECT 절 칼럼 | `SELECT *` → "ALL_COLUMNS" 마커 |
| INSERT | INTO 절 | INSERT 칼럼 목록 | — |
| UPDATE | UPDATE 절 | SET 절 칼럼 | — |
| DELETE | FROM 절 | — (칼럼 없음) | WHERE 조건은 search_condition에 별도 저장 |

### 7.3 PII 정책 대조

파싱된 테이블.칼럼을 `PiiPolicyCache`와 대조하여:
- `pii_type_codes`: 해당 칼럼의 PII 유형 (주민번호, 휴대폰번호 등)
- `pii_grade`: 최고 등급 (1등급 > 2등급 > 3등급)

---

## 8. SQL 전문 저장 옵션

### 설정

| 설정 키 | 기본값 | 위치 |
|---|---|---|
| `SQL_TEXT_LOGGING` | `N` (비활성) | `TBL_ACCESS_LOG_CONFIG` |

### SQL 전문 저장 시 추가되는 정보

| 항목 | 메타데이터만 | SQL 전문 포함 |
|---|---|---|
| 행위 유형 (SELECT/UPDATE/DELETE) | O | O |
| 대상 테이블 | O | O |
| 접근 칼럼 | O | O |
| WHERE 조건 (정보주체 식별) | O | O |
| 서브쿼리 구조 | X | O |
| UNION/복합 쿼리 전문 | X | O |
| 바인드 변수 값 | X | O (PreparedStatement 한정) |
| 정확한 SQL 재현 | X | O |

### 권장 사항

| 환경 | SQL_TEXT_LOGGING | 이유 |
|---|---|---|
| 일반 기업 | `N` | 메타데이터로 법적 요건 충족, 저장 공간 절약 |
| 금융권 | `Y` | 감독규정 전산자료 보관, 포렌식 대응 |
| ISMS-P 인증 대상 | `Y` 권장 | 심사 시 상세 증적 제출 가능 |
| 보안 사고 대응 | `Y` | 정확한 SQL 재현 필요 |

---

## 9. 위변조 방지

안전성 확보조치 기준 **제8조 제4항**에 따라 접속기록의 위변조를 방지한다.

### 해시 체인 구조

```
Record N-1:  hash_value = SHA-256(log_id + user + time + action + ...)
                ↓
Record N:    prev_hash  = Record N-1의 hash_value
             hash_value = SHA-256(log_id + user + time + action + ... + prev_hash)
                ↓
Record N+1:  prev_hash  = Record N의 hash_value
             ...
```

- 중간 레코드가 변조되면 이후 모든 해시가 불일치
- 정기 검증: `HASH_VERIFY_SCHEDULE` (기본: 매월 1일 03:00)
- 검증 이력: `TBL_ACCESS_LOG_HASH_VERIFY` 테이블에 기록

---

## 10. 보존 기간

| 설정 키 | 기본값 | 법적 근거 |
|---|---|---|
| `RETENTION_PERIOD_YEARS` | **2년** | 안전성 확보조치 기준 제8조 제2항 (5만명 이상 또는 민감정보) |
| `RETENTION_FINANCIAL_YEARS` | **5년** | 전자금융감독규정 제13조 |

> 참고: 일반적인 경우 최소 1년, 5만명 이상 정보주체 또는 고유식별정보/민감정보 처리 시 최소 2년.
> DLM은 보수적으로 기본 2년을 적용하며, 금융권은 5년으로 설정 가능.

---

## 참조 파일

| 파일 | 설명 |
|---|---|
| `database/ddl/ACCESSLOG_DDL_DEPLOY.sql` | 접속기록 전체 DDL |
| `DLM/dlm-agent/.../analyzer/SqlAnalyzer.java` | SQL 파싱 엔진 |
| `DLM/dlm-agent/.../model/AccessLogEntry.java` | Agent 로그 엔트리 모델 |
| `DLM/dlm-agent/.../interceptor/StatementInterceptor.java` | JDBC Statement 가로채기 |
| `DLM/dlm-agent/.../interceptor/PreparedStatementInterceptor.java` | PreparedStatement 가로채기 |
| `DLM/dlm-agent/.../buffer/LogBuffer.java` | 비동기 로그 버퍼 |
| `DLM/dlm-agent/.../shipper/LogShipper.java` | 배치 전송 |
| `DLM/dlm-agent/src/main/resources/dlm-agent.properties` | Agent 설정 |
