# X-Audit — DLM 서버 운영자 가이드

> ⚠️ **DDL 위치 이동 안내 (2026-04-27)**
> XAUDIT 저장소 스키마는 **4가지 수집방식 (DB_AUDIT / DB_DAC / WAS_AGENT / WAS_SDK) 공통**이라
> SDK 전용 디렉토리가 아닌 공용 위치로 이동했습니다.
>
> **새 경로** → [`database/xaudit/`](../../../database/xaudit)
> - `XAUDIT_SCHEMA_MARIADB.sql` — MariaDB / MySQL
> - `XAUDIT_SCHEMA_ORACLE.sql` — Oracle / Tibero (월 INTERVAL 파티션 적용)

---

## 배포 절차 (EXTERNAL 모드 전환 시 1회)

### Step 1. 고객사 별도 DB 에 DDL 실행

**MariaDB 고객사:**
```bash
mariadb -h <host> -u <xaudit_user> -p <xaudit_db> \
    < database/xaudit/XAUDIT_SCHEMA_MARIADB.sql
```

**Oracle / Tibero 고객사:**
```bash
sqlplus <xaudit_user>/<pwd>@<host>:<port>/<service> \
    @database/xaudit/XAUDIT_SCHEMA_ORACLE.sql
```

### Step 2. 생성 확인

```sql
-- MariaDB
SHOW TABLES LIKE 'TBL_ACCESS_LOG%';
-- → TBL_ACCESS_LOG, TBL_ACCESS_LOG_DETAIL

-- Oracle / Tibero
SELECT table_name FROM user_tables WHERE table_name LIKE 'TBL_ACCESS_LOG%';
```

### Step 3. DLM 설정 전환

`.env` (또는 고객사 배포 `.env.*`):
```bash
XAUDIT_STORAGE_MODE=EXTERNAL
# XAUDIT_STORAGE_DB_KEY 는 default=XAUDIT_DB 이므로 생략 가능
```

`/pii/database/list` UI 에서 `XAUDIT_DB` 엔트리 등록(또는 자동등록 후 수정).
`docker compose up -d dlm` 재기동 → 로그에 `[X-Audit] XAUDIT_DB DataSource ready` 확인.

---

## 생성되는 오브젝트 (V3, 2026-04 기준)

| 오브젝트 | 설명 |
|---------|------|
| `TBL_ACCESS_LOG` | 접속기록 Master (월 파티션) |
| `TBL_ACCESS_LOG_DETAIL` | SQL 원문/바인드 등 sidecar (월 파티션) |
| `V_ACCESS_LOG_UNIFIED` | 두 테이블 LEFT JOIN 통합 조회 뷰 |

자세한 컬럼 정의·인덱스·파티션 운영은 SQL 파일 헤더 주석 참조.

---

## 관련 문서

- 통합 처리구조: [docs/architecture/접속기록_통합처리구조.md](../../../docs/architecture/접속기록_통합처리구조.md)
- SDK 상세가이드: [docs/design/X-Audit_SDK_상세가이드.md](../../../docs/design/X-Audit_SDK_상세가이드.md)
- SDK 클라이언트(고객사 전달): [`../customer/`](../customer/)
