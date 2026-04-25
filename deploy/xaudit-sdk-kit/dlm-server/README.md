# X-Audit — DLM 서버 운영자 가이드

**고객사에 전달하지 마세요.** 이 디렉토리는 DLM 서버 운영자가 사용하는 DDL 원본을 담고 있습니다.

---

## 이 디렉토리의 용도 — DDL 2종

| 파일 | DBMS | 사용 시점 |
|------|------|-----------|
| `database/XAUDIT_SCHEMA_MARIADB.sql` | **MariaDB / MySQL** | `XAUDIT_STORAGE_MODE=EXTERNAL` 일 때 고객사 **별도 MariaDB** 에 실행 |
| `database/XAUDIT_SCHEMA_ORACLE.sql` | **Oracle / Tibero** | `XAUDIT_STORAGE_MODE=EXTERNAL` 일 때 고객사 **별도 Oracle/Tibero** 에 실행 |

> ⚠️ **DLM 내부 MariaDB(COTDL 스키마) 에는 실행할 필요 없음.**
> `XAUDIT_STORAGE_MODE=COTDL` (default) 저장 경로는 `database/ddl/DLM_DDL_MASTER_ACCESSLOG.sql`
> 에 이미 통합되어 있어 DLM 신규 설치 시 자동 생성됨.

---

## 배포 절차 (EXTERNAL 모드 전환 시 1회)

### Step 1. 고객사 별도 DB 에 DDL 실행

**MariaDB 고객사:**
```bash
mariadb -h <host> -u <xaudit_user> -p <xaudit_db> < database/XAUDIT_SCHEMA_MARIADB.sql
```

**Oracle / Tibero 고객사:**
```bash
sqlplus <xaudit_user>/<pwd>@<host>:<port>/<service> @database/XAUDIT_SCHEMA_ORACLE.sql
```

### Step 2. 생성 확인

**MariaDB:**
```sql
SHOW TABLES LIKE 'TBL_XAUDIT%';
-- → TBL_XAUDIT_ACCESS_LOG, TBL_XAUDIT_SQL_LOG
```

**Oracle / Tibero:**
```sql
SELECT table_name FROM user_tables WHERE table_name LIKE 'TBL_XAUDIT%';
-- → TBL_XAUDIT_ACCESS_LOG, TBL_XAUDIT_SQL_LOG
```

### Step 3. DLM 설정 전환

`.env` (또는 고객사 배포 `.env.*`) 수정:
```bash
XAUDIT_STORAGE_MODE=EXTERNAL
# XAUDIT_STORAGE_DB_KEY 는 default=XAUDIT_DB 이므로 생략 가능
# Oracle/Tibero 에서 dbuser=스키마 사용 시 XAUDIT_STORAGE_SCHEMA 는 빈값 유지
```

TBL_PIIDATABASE 에 `db='XAUDIT_DB'` 엔트리 등록(UI 권장 — pwd 자동 AES256 암호화).
`docker compose up -d dlm` 재기동 → 로그에 `[X-Audit] external DataSource initialized` 확인.

### Step 4. DLM 애플리케이션은 이미 수신 엔드포인트 탑재
- `POST /api/xaudit/events` — 고객사 처리계의 SDK가 호출
- `/xaudit/dashboard` / `/xaudit/access` / `/xaudit/sql` / `/xaudit/detail/{reqId}` — DLM 운영자 조회 UI
  (Phase 1 — EXTERNAL 모드에서 조회 UI 는 Phase 2 에서 지원 예정)

---

## 생성되는 오브젝트

| 오브젝트 | 설명 | 주요 인덱스 |
|---------|------|-------------|
| `TBL_XAUDIT_ACCESS_LOG` | HTTP 요청 단위 접속기록 (1 요청 = 1 row) | req_id, (user_id, time), time, partition_key, (service_name, time) |
| `TBL_XAUDIT_SQL_LOG` | 요청 내부에서 실행된 개별 SQL (1 요청 = N rows) | req_id, (user_id, time), time, partition_key, pii_detected, (sql_type, time), (service_name, time) |
| `V_XAUDIT_UNIFIED` | req_id 로 조인된 통합 조회 뷰 | — |

공통 필드:
- `req_id` : 두 테이블 조인 키 (UUID)
- `hash_prev` / `hash_cur` : SHA-256 해시체인 (안전성확보조치 제8조 3항)
- `partition_key` : YYYYMMDD (보관 정책·파티션 전환 근거)

---

## 보관 정책 (차등 적용)

DLM 서버가 자체 스케줄러로 아래 법규에 맞춰 월별 파티션을 정리합니다.

| 법규 | 보관 | 본 SDK 대응 |
|------|------|------|
| 개인정보 안전성 확보조치 기준 제8조 | 1년 (특례 2년) | partition_key + retention 엔진 |
| 신용정보업감독규정 별표3 | 개인신용정보 3년 | 동일 |
| 전자금융감독규정 시행세칙 제13조제1항제9호 (2025.2.3 신설) | SQL 원문 의무 | `sql_text` 컬럼 보존 |
| 안전성확보조치 제8조 3항 | 위·변조 방지 | SHA-256 체인 (자동) |

---

## 운영 쿼리 예시

```sql
-- 오늘 수신 현황
SELECT service_name, COUNT(*) AS access_cnt,
       (SELECT COUNT(*) FROM TBL_XAUDIT_SQL_LOG s
         WHERE s.partition_key=a.partition_key AND s.service_name=a.service_name) AS sql_cnt
  FROM TBL_XAUDIT_ACCESS_LOG a
 WHERE partition_key = DATE_FORMAT(NOW(),'%Y%m%d')
 GROUP BY service_name;

-- 특정 사용자의 하루 감사 추적
SELECT request_time, user_id, menu_id, sql_type, LEFT(sql_text, 60) AS sql
  FROM V_XAUDIT_UNIFIED
 WHERE user_id = ? AND DATE(request_time) = ?
 ORDER BY request_time;

-- PII 탐지된 SQL 목록
SELECT access_time, user_id, pii_detected, LEFT(sql_text, 100) AS sql
  FROM TBL_XAUDIT_SQL_LOG
 WHERE pii_detected IS NOT NULL
   AND access_time >= DATE_SUB(NOW(), INTERVAL 1 DAY)
 ORDER BY access_time DESC;

-- 해시체인 무결성 샘플 검증 (가장 최근 10건)
SELECT log_id, LEFT(hash_prev,8) AS prev, LEFT(hash_cur,8) AS cur
  FROM TBL_XAUDIT_ACCESS_LOG
 ORDER BY log_id DESC LIMIT 10;
```

---

## 주의사항

- **롤백**: `DROP TABLE TBL_XAUDIT_ACCESS_LOG, TBL_XAUDIT_SQL_LOG; DROP VIEW V_XAUDIT_UNIFIED;` — 기존 DLM 기능(DB_AUDIT/DB_DAC/WAS_AGENT)에 영향 없음
- **SecurityConfig**: `/api/xaudit/**` 는 permitAll + CSRF ignore (SDK가 인증 없이 POST). 운영 보안 강화가 필요하면 API Key 검증 Interceptor 추가 고려
- **`PACKAGE CONTENTS`**: DDL 파일만 들어있음. SDK JAR·설정 예시는 `customer/` 디렉토리에 있고 **고객사 처리계 개발/운영팀에 전달**
