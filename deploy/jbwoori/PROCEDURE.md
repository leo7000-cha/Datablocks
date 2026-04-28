# 고객사 반입 — 단계별 수행 절차서 (JB우리캐피탈)

> **버전**: v1.0.0  | **반입일**: 2026-04-26 | **사이트**: JB우리캐피탈 (Rocky Linux 9 / 호스트 OS MariaDB / 폐쇄망)
> **이 문서 한 장으로 끝냅니다.** 상세는 [README-JB우리캐피탈.md](README-JB우리캐피탈.md), Agent 는 [dlm-agent/README-Agent설치가이드.md](dlm-agent/README-Agent설치가이드.md), SDK 는 [xaudit-sdk/README.md](xaudit-sdk/README.md).

---

## 0. USB 반입 패키지 (체크리스트)

| # | 폴더/파일 | 크기 | 누가 사용 | ☐ |
|---|-----------|------|----------|---|
| 1 | `images/dlm-app.tar.gz` + `dlm-privacy-ai.tar.gz` | 476 MB | DLM 운영자 | ☐ |
| 2 | `docker-rpms/` (Docker 오프라인 RPM) | — | DLM 운영자 | ☐ |
| 3 | `docker-compose.jbwoori.yml` + `.env.jbwoori`     | 6 KB  | DLM 운영자 | ☐ |
| 4 | `scripts/install-docker.sh` + `deploy.sh`        | —     | DLM 운영자 | ☐ |
| 5 | `database/ddl/` + `database/init/`               | 5 MB  | DBA       | ☐ |
| 6 | `custom-prod.cnf` (MariaDB 튜닝)                  | 2 KB  | DBA       | ☐ |
| 7 | `certs/` (HTTPS 옵션, 사용 시만)                  | —     | DLM 운영자 | ☐ |
| 8 | **`dlm-agent/`** (Java Agent BCI — WAS_AGENT 경로) | 4.5 MB | **고객 처리계 운영팀** | ☐ |
| 9 | **`xaudit-sdk/`** (AOP SDK — WAS_SDK 경로)        | 80 KB | **고객 처리계 개발팀** | ☐ |
| 10 | `docs/` (사이트 가이드 + 설계문서)                | 868 KB | 인수인계용 | ☐ |
| 11 | `README-JB우리캐피탈.md` + 본 `PROCEDURE.md`      | —     | 모두      | ☐ |

```bash
# USB → 서버로 복사 후
sudo cp -r /mnt/usb/jbwoori /app/Datablocks/deploy/
cd /app/Datablocks/deploy/jbwoori
ls    # 위 표 11개가 다 보여야 OK
```

---

## 1. 사전 조건 확인 (5분)

```bash
# (1) OS / 메모리
cat /etc/redhat-release      # → Rocky Linux 9.x
free -h                       # → 16GB+ 권장

# (2) 호스트 MariaDB 가 실행 중 + cotdl DB 존재
sudo systemctl status mariadb
mariadb -h 127.0.0.1 -u cotdl -p cotdl -e "SELECT 1;"
#  → 비밀번호 입력 후 1 출력 = OK

# (3) 8080 포트 free
sudo ss -tlnp | grep 8080    # 출력 없으면 OK
```

**※ MariaDB 미설치라면 [README §3 MariaDB 사전 설정](README-JB우리캐피탈.md) 먼저 진행**

---

## 2. Docker 설치 (Docker 미설치 시 1회만)

```bash
cd /app/Datablocks/deploy/jbwoori
sudo bash scripts/install-docker.sh
docker --version             # → Docker 24.x 표시되면 OK
sudo systemctl enable --now docker
```

---

## 3. DB 스키마 적용 (최초 1회만)

> **⚠️ DROP 포함 DDL 입니다 — 운영 DB 라면 반드시 백업 먼저!**
> ```bash
> mysqldump -h 127.0.0.1 -u root -p cotdl > /tmp/cotdl_backup_$(date +%Y%m%d).sql
> ```

```bash
cd /app/Datablocks/deploy/jbwoori/database/ddl

# (1) 마스터 DDL 3종
mariadb -h 127.0.0.1 -u cotdl -p cotdl < 10_DDL_MASTER_CORE.sql
mariadb -h 127.0.0.1 -u cotdl -p cotdl < 20_DDL_MASTER_DISCOVERY.sql
mariadb -h 127.0.0.1 -u cotdl -p cotdl < 30_DDL_MASTER_ACCESSLOG.sql      # ★ 접속기록저장 핵심
mariadb -h 127.0.0.1 -u cotdl -p cotdl < CREATE_INDEX.sql

# (2) 초기 데이터 (000~200 시리즈 모두)
cd ../init
for f in $(ls *.sql | sort); do
  echo "[init] $f"
  mariadb -h 127.0.0.1 -u cotdl -p cotdl < $f || break
done
```

**검증:**
```bash
mariadb -h 127.0.0.1 -u cotdl -p cotdl -e "
  SELECT COUNT(*) AS access_log_tables
    FROM information_schema.TABLES
   WHERE TABLE_SCHEMA='cotdl'
     AND TABLE_NAME LIKE 'TBL_ACCESS_LOG%';"
# → 15 출력되면 접속기록저장소 스키마 OK

mariadb -h 127.0.0.1 -u cotdl -p cotdl -e "
  SELECT COUNT(*) AS rules FROM TBL_ACCESS_LOG_ALERT_RULE WHERE is_active='Y';"
# → 10 출력되면 이상행위 알림룰 OK
```

---

## 4. DLM 서버 배포 (한 줄)

```bash
cd /app/Datablocks/deploy/jbwoori
bash scripts/deploy.sh
```

**deploy.sh 자동 5단계:**
1. 호스트 MariaDB 접속 정보 확인
2. 연결 테스트 (`mariadb` 또는 `nc -z`)
3. 이미지 로드 (`docker load`)
4. `docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml up -d`
5. 헬스체크

**소요 시간**: 2~3분

---

## 5. DLM 서버 동작 확인 (3분)

```bash
# 5-1. 컨테이너 상태
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep dlm

# 5-2. 로그
docker logs --tail 30 dlm-app | grep -iE "started|error"
#  → "Started DlmApplication in X seconds" = OK

# 5-3. 화면
# 브라우저: http://<서버IP>:8080  (admin / 1111)
#  → 좌측 "접속기록관리" 클릭 → 대시보드 표시되면 OK
```

---

## 6. ★ 접속기록저장소 — 수집 경로 활성화 (4 경로)

DLM 서버 자체 설치만으로 접속기록저장소(TBL_ACCESS_LOG …) **그릇은 준비** 됩니다.
**실제 로그를 채우려면** 아래 **4 경로** 중 사이트 합의된 것을 활성화합니다.

```
                            [DLM 서버 :8080]
                                   ▲
       ┌──────────────┬────────────┴────────────┬────────────────┐
  POST /api/agent/logs  POST /api/xaudit/events    PULL (스케줄 5분주기)
       │              │                         │                │
 ┌─────┴──────┐ ┌─────┴──────┐           ┌──────┴──────┐ ┌───────┴────────┐
 │ WAS_AGENT  │ │ WAS_SDK    │           │ DB_AUDIT    │ │ DB_DAC         │
 │ Java BCI   │ │ AOP/Filter │           │ DB 자체     │ │ DB 접근통제    │
 │            │ │            │           │ Audit log   │ │ 솔루션         │
 │ dlm-agent/ │ │ xaudit-sdk/│           │ (mysql.audit│ │ (DBSAFER/PSM/  │
 │            │ │            │           │  / SYS.AUD$)│ │  Chakra 등)    │
 └─────┬──────┘ └─────┬──────┘           └──────┬──────┘ └────────┬───────┘
       ▼              ▼                         ▼                  ▼
 -javaagent:    pom + yml 병합              audit 켜기      사용자 SELECT문
 dlm-agent.jar  +dlm-aop-sdk                + DLM UI       + DLM UI 등록
                                              등록만
       └──────── PUSH (실시간) ────────┘   └────────── PULL ─────────┘
```

| 경로 | 권장 사이트 | 적용 위치 | 코드수정 | 재기동 | 본 패키지 자료 | 비고 |
|------|-----------|---------|---------|------|---------------|------|
| **WAS_AGENT** (BCI) | Spring Boot / 표준 WAS | JVM 시작옵션 | **0** | 필요 | `dlm-agent/` | JDBC 호출 자동 가로채기 |
| **WAS_SDK** (AOP)   | MyBatis + 라이브러리 추가 가능 | pom + yml | **0** | 필요 | `xaudit-sdk/` | MyBatis Interceptor + Filter |
| **DB_AUDIT** (PULL) | DB 자체 audit 활성화 가능 | DLM UI | **0** | 불필요 | DLM 화면 | mysql.audit_log / SYS.AUD$ 등 직접 조회 |
| **DB_DAC** (PULL)   | DBSAFER/PSM 등 **DB 접근통제 솔루션** 운영 중일 때 | DLM UI | **0** | 불필요 | DLM 화면 | DAC 솔루션 audit 테이블에 사용자 SELECT |

> **JB우리캐피탈 1차 합의 범위는 처리계팀·보안팀과 협의 — 보통 WAS_AGENT (LG DevOn 환경 검증 필요) 또는 DB_DAC (기존 DBSAFER 운영 시) 우선**

---

## 6-A. WAS_AGENT 활성화 (Java Agent / BCI)

> 처리계 WAS 운영팀에 `dlm-agent/` 폴더 통째로 전달.

```bash
# (1) 처리계 서버에서
cd <처리계>/dlm-agent
sudo bash install.sh                # /opt/dlm-agent 로 설치

# (2) dlm-agent.properties 편집
vi /opt/dlm-agent/dlm-agent.properties
#   server.url=http://<DLM서버IP>:8080
#   agent.id=jbwoori-loan-was-01
#   agent.secret=<DLM TBL_ACCESS_LOG_CONFIG.AGENT_API_SECRET 과 동일>

# (3) 처리계 WAS JVM 옵션에 추가 (Tomcat catalina.sh / setenv.sh / WebLogic startWebLogic.sh)
JAVA_OPTS="$JAVA_OPTS -javaagent:/opt/dlm-agent/dlm-agent-1.0.0.jar=/opt/dlm-agent/dlm-agent.properties"

# (4) 처리계 WAS 재기동
# 정상 기동 로그:
#  [XAudit-Agent] DLM Access Log Agent v1.0.0 starting...
#  [XAudit-Agent] Agent successfully installed.
```

**(5) DLM 화면에서 수집원 등록 — `접속기록 → 수집원 → + 등록 → Java Agent (BCI)`**
   - Agent ID = `jbwoori-loan-was-01` (위 properties 와 일치)
   - 대상 DB = 처리계가 접근하는 cotdl 또는 외부 DB

**(6) 검증 — DLM 화면 `접속기록 → Agent 상태` 에서 ACTIVE + heartbeat 갱신 확인**

상세: [dlm-agent/README-Agent설치가이드.md](dlm-agent/README-Agent설치가이드.md)

---

## 6-B. WAS_SDK 활성화 (AOP / Filter)

> 처리계 **개발팀**에 `xaudit-sdk/` 폴더 통째로 전달.

```bash
# (1) SDK JAR 사내 Nexus 업로드 또는 mvn local 설치 (Maven 예시)
mvn install:install-file \
  -Dfile=xaudit-sdk/lib/dlm-aop-sdk-1.0.0.jar \
  -DgroupId=datablocks -DartifactId=dlm-aop-sdk \
  -Dversion=1.0.0 -Dpackaging=jar

# (2) 처리계 pom.xml 의 <dependencies> 에 snippets/pom-snippet.xml 블록 병합
#     Gradle 이면 build.gradle 에 build-snippet.gradle 병합

# (3) 처리계 application.yml 에 snippets/xaudit-config-snippet.yml 의 xaudit: 섹션 병합
#     → 최소 3줄:
#        xaudit:
#          service-name: LOAN_CORE
#          server:
#            url: http://<DLM서버IP>:8080/api/xaudit/events

# (4) 처리계 WAS 재기동 → 로그:
#  [X-Audit] activated: service=LOAN_CORE, server=http://...
#  [X-Audit] HTTP sender started

# (5) Smoke test
bash xaudit-sdk/scripts/smoke-test.sh http://<DLM서버IP>:8080
#  → {"inserted":2,"success":true,"received":2}
```

**(6) DLM 화면 등록 — `접속기록 → 수집원 → + 등록 → SDK (AOP/Filter)` , service-name 일치**

상세: [xaudit-sdk/README.md](xaudit-sdk/README.md), [xaudit-sdk/snippets/README.md](xaudit-sdk/snippets/README.md)

> **JB우리캐피탈 LG DevOn 처리계 적용 시 주의** — DevOn 이 Spring MVC legacy / javax.servlet 기반인지 먼저 확인.
> SDK 1.0.0 은 javax.servlet (Spring Boot 2.x) 검증본이며 jakarta (Spring Boot 3+) 는 Phase 2.

---

## 6-C. DB_AUDIT 활성화 (DB 자체 Audit log PULL)

> 처리계가 사용하는 DB 의 **자체 audit 기능**을 켜고, DLM 스케줄러가 5분 주기로 PULL.

1. DLM 화면: `시스템 관리 → DB 관리` 에서 대상 DB 등록 (계정/암호 AES256 자동 저장)
2. `접속기록 → 수집원 → + 등록 → DB Audit`
3. 대상 DB 선택, 수집 주기 (분), 제외 계정, 테이블 필터 입력
4. `시작` 버튼 → status=RUNNING 확인

DB 측 사전 작업 (대상 DB 운영자):
- **MariaDB**: `INSTALL SONAME 'server_audit'; SET GLOBAL server_audit_logging=ON;`
- **Oracle**: `AUDIT_TRAIL=DB`, `AUDIT SELECT TABLE BY <user>;`

---

## 6-D. DB_DAC 활성화 (DB 접근통제 솔루션 연동)

> **DBSAFER / PSM (Pentasecurity) / Chakra Max** 같은 DB 접근통제 솔루션이 이미 운영 중일 때 사용.
> 솔루션이 자체 audit 테이블에 쌓아둔 접속기록을 DLM 이 **사용자 정의 SELECT 문**으로 5분 주기 PULL.
> ※ 처리계 / DB 어디에도 손대지 않음 — 보안팀이 가장 선호하는 경로.

**구조:**
```
   [업무 사용자] → [DAC 솔루션 게이트웨이] → [업무 DB]
                          │
                          ▼
                   DAC 솔루션 audit 테이블
                   (예: SECURE.TB_AUDIT_LOG)
                          │
                          │ ← DLM 스케줄러가 SELECT
                          ▼
                   TBL_ACCESS_LOG (collect_type=DB_DAC)
```

**(1) 보안팀 / DAC 운영자에게 다음을 요청:**
- DAC 솔루션이 audit 데이터를 쌓는 **테이블·뷰명**
- audit 테이블 조회용 **READ-ONLY 계정**
- 컬럼 매핑 정보 (어느 컬럼이 사용자ID, 시각, SQL 원문, 클라이언트 IP 인지)

**(2) DLM 화면: `시스템 관리 → DB 관리` 에서 DAC audit DB 등록**

**(3) `접속기록 → 수집원 → + 등록 → DB 접근제어` 선택, SELECT 문 작성**

DLM 이 요구하는 **표준 컬럼 alias 17 종** — alias 만 표준명에 맞추면 두 테이블 (`TBL_ACCESS_LOG` + `TBL_ACCESS_LOG_DETAIL`) 에 자동 분리 적재됩니다.

**Master 컬럼 alias** (TBL_ACCESS_LOG):

| alias | 의미 | 필수 |
|-------|------|------|
| `access_time`     | 접속 일시 (DATETIME) | ★ 필수 |
| `user_account`    | 접속자 ID | 권장 |
| `user_name`       | 접속자 이름 |  |
| `department`      | 소속 |  |
| `client_ip`       | 클라이언트 IP |  |
| `session_id`      | 세션 ID |  |
| `action_type`     | SELECT/INSERT/UPDATE/DELETE 등 |  |
| `target_table`    | 대상 테이블 |  |
| `target_schema`   | 대상 스키마 |  |
| `result_code`     | SUCCESS / FAIL / DENIED |  |
| `access_channel`  | WEB / WAS / DB_DIRECT / API / BATCH |  |

**Sidecar 컬럼 alias** (TBL_ACCESS_LOG_DETAIL — 1 개라도 있으면 자동 분리 INSERT):

| alias | 의미 |
|-------|------|
| `sql_text`         | SQL 원문 (법규 §13①9 SQL 원문 의무 대응) |
| `bind_params`      | 실행시점 바인드 파라미터 (JSON/CSV) |
| `sql_id`           | MyBatis ID 또는 SQL 식별자 |
| `search_condition` | WHERE 조건 (누구 데이터를 조회했나) |
| `target_columns`   | 접근한 PII 컬럼 목록 |
| `user_agent`       | 클라이언트/브라우저 정보 |
| `error_message`    | 실패 사유 |

**(4) 증분 수집 — `#{LAST_OFFSET}` 치환자 사용 (필수)**

DLM 이 SELECT 실행 시 마지막으로 수집된 시각을 `#{LAST_OFFSET}` 자리에 자동 주입합니다.
WHERE 절에 반드시 포함해야 중복 수집을 막을 수 있습니다.

**(5) ★ 등록 전 미리보기 (dry-run) — 화면 우측 [SQL 미리보기] 버튼**

작성한 SELECT 를 즉시 한 번 실행해서 다음을 확인:
- ✅ Master / Sidecar 매핑된 alias 목록 (색상 구분)
- ⚠️ 미매핑 컬럼 (alias 가 표준 외 — 적재 안 됨)
- ❌ 필수 누락 (`access_time` 없음 등)
- 샘플 행 1 건 (각 컬럼 값 미리보기)

문제가 있으면 등록하지 않고 SELECT 를 수정 가능. **5 분 기다리지 않고 즉시 검증.**

**(6) Generic Template 활용** — 화면 좌하단 [Generic (솔루션 무관)] 버튼

빈칸 (`<시각컬럼>`, `<사용자ID컬럼>` 등) 만 환경에 맞게 채우면 됩니다. **솔루션 종류 무관.** 이미 솔루션이 정해진 경우 [차크라맥스] / [페트라] / [DBSafer] / [QueryOne] 중 선택.

**예시 — 임의 솔루션 (alias 만 표준화)**:
```sql
SELECT
    log_time          AS access_time,        -- ★ 필수
    db_user           AS user_account,
    user_nm           AS user_name,
    dept_nm           AS department,
    src_ip            AS client_ip,
    cmd_type          AS action_type,
    obj_name          AS target_table,
    obj_owner         AS target_schema,
    CASE WHEN deny='Y' THEN 'DENIED' ELSE 'SUCCESS' END AS result_code,
    -- ↓ Sidecar — 솔루션 audit 테이블에 있으면 그대로 매핑
    sql_text          AS sql_text,
    bind_value        AS bind_params,
    sql_hash          AS sql_id,
    where_clause      AS search_condition,
    accessed_cols     AS target_columns,
    client_pgm        AS user_agent,
    err_msg           AS error_message
  FROM <접근통제솔루션의_AUDIT_테이블>
 WHERE log_time > #{LAST_OFFSET}
 ORDER BY log_time
```

**(7) `시작` 버튼 → status=RUNNING 확인 후 1 주기 뒤 `접속기록 → 로그 조회` 에서 collect_type=DB_DAC 행 적재 검증.**

검증 SQL:
```sql
SELECT a.log_id, a.user_account, a.target_table,
       d.sql_text, d.bind_params, d.sql_id,
       d.search_condition, d.target_columns,
       d.user_agent, d.error_message
  FROM TBL_ACCESS_LOG a
  LEFT JOIN TBL_ACCESS_LOG_DETAIL d ON a.log_id=d.log_id AND a.access_time=d.access_time
 WHERE a.collect_type='DB_DAC'
 ORDER BY a.log_id DESC LIMIT 5;
-- → Sidecar 컬럼이 사용자 SELECT 에 alias 로 있으면 자동 적재됨
```

**문제 해결:**
- `error_msg=ORA-00942: table or view does not exist` → audit 계정에 SELECT 권한 없음
- 적재 0 건 → SELECT 의 `#{LAST_OFFSET}` WHERE 조건 누락 또는 `access_time` alias 오타
- 중복 적재 → `#{LAST_OFFSET}` 치환자 누락 (전체 SELECT 됨)
- Sidecar 비어있음 → SELECT alias 가 `sql_text`/`bind_params` 등 표준명이 아닐 가능성. 미리보기 버튼으로 매핑 확인

> **JB우리캐피탈 환경:** 기존 DAC 솔루션이 있는지 보안팀에 먼저 확인. 있다면 6-A/6-B 보다 6-D 가 적용 부담이 가장 적음 (처리계 0 영향, DB 0 영향).

---

## 7. ★ 전체 동작 검증 (DLM 운영자가 직접)

DLM 서버 자체 smoke test (DB 가 가득 찼는지 확인):

```bash
# 7-1. Agent 경로 — DLM 서버에서 직접 호출 (모의)
curl -s -X POST http://localhost:8080/api/agent/heartbeat \
  -H "Content-Type: application/json" -H "X-Agent-Id: smoke-001" \
  -d '{"agentId":"smoke-001","version":"1.0.0"}'
#  → {"serverTime":...,"status":"OK"}

# 7-2. SDK 경로
curl -s -X POST http://localhost:8080/api/xaudit/events \
  -H "Content-Type: application/json" \
  -d '[{"type":"ACCESS","reqId":"smoke-001","accessTime":"2026-04-26 10:00:00.000","userId":"test","clientIp":"127.0.0.1","serviceName":"SMOKE","menuId":"M0","uri":"/test","httpMethod":"GET","httpStatus":200,"totalDurationMs":1}]'
#  → {"inserted":1,"success":true,"received":1}

# 7-3. DB 적재 확인
mariadb -h 127.0.0.1 -u cotdl -p cotdl -e "
  SELECT collect_type, COUNT(*) FROM TBL_ACCESS_LOG GROUP BY collect_type;"
#  → WAS_AGENT, WAS_SDK 행이 보이면 OK

# 7-4. 해시체인 무결성 (SHA-256 chain)
mariadb -h 127.0.0.1 -u cotdl -p cotdl -e "
  SELECT a.log_id,
         CASE WHEN a.prev_hash <=> b.hash_value THEN 'OK' ELSE 'BROKEN' END AS chain
    FROM TBL_ACCESS_LOG a LEFT JOIN TBL_ACCESS_LOG b ON b.log_id=a.log_id-1
   ORDER BY a.log_id LIMIT 20;"
#  → 첫 행만 BROKEN(GENESIS), 나머지 모두 OK 면 정상
```

---

## 8. 운영 명령 (자주 쓰는 것만)

```bash
cd /app/Datablocks/deploy/jbwoori

# 시작 / 중지 / 재시작
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml up -d
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml down
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml restart dlm

# 로그
docker logs -f dlm-app
docker logs -f dlm-privacy-ai

# 패치 배포 (이미지만 교체)
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml down
docker load < /tmp/patch/dlm-app.tar.gz
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml up -d
```

---

## 9. 문제 발생 1차 대응

| 증상 | 1차 조치 |
|------|---------|
| `dlm-app` 즉시 죽음 | `docker logs --tail 100 dlm-app` 캡처 → 본사 |
| DB 접속 실패 | `mariadb -h 127.0.0.1 -u cotdl -p` 호스트에서 직접 시도, bind-address 확인 |
| 화면 502 | 호스트 방화벽 8080 포트 점검 (`firewall-cmd --add-port=8080/tcp --permanent`) |
| Agent ACTIVE 안됨 | 처리계 → DLM 서버 8080 통신 가능 여부 (`curl http://<DLM서버IP>:8080/api/agent/status`) |
| SDK `[X-Audit] activated` 로그 없음 | 처리계 `application.yml` 의 `xaudit.enabled` 와 `server.url` 점검 |
| **DB_DAC 적재 0 건** | SELECT 문에 `#{LAST_OFFSET}` WHERE 조건 누락 또는 `access_time` alias 오타 (필수) |
| **DB_DAC 중복 적재** | `#{LAST_OFFSET}` 치환자 누락으로 매 수집마다 전체 SELECT 됨 — WHERE 절 수정 |
| 수집은 되는데 화면 비어있음 | `접속기록 → 수집원` 에서 등록 + `is_active=Y` 인지 확인 |
| 알림 안 뜸 | `접속기록 → 알림 규칙` 활성 여부 + Mail 설정 (`MAIL_HOST` env) 확인 |

**현장에서 풀 수 없는 이슈는 `docker logs dlm-app` 전체 + `docker compose ps` 캡처 → 본사 전달**

---

## 10. HTTPS 전환 (선택 — `.env.jbwoori` 와 compose 의 ssl 블록 주석 해제)

```bash
# (1) 인증서 배치
cp <고객사인증서>.p12 certs/dlm-keystore.p12

# (2) .env.jbwoori 의 SPRING_PROFILES_ACTIVE 변경
SPRING_PROFILES_ACTIVE=local,ssl

# (3) docker-compose.jbwoori.yml 에서 8443 ports / volumes:certs 주석 해제

# (4) 재기동
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml up -d
```

상세: [README-JB우리캐피탈.md](README-JB우리캐피탈.md) `HTTPS / SSL 운영 모드` 섹션

---

## 11. 본사 연락

- 1차 (반입 지원): 차민석 (mschae@datablocks.kr)
- 2차 (긴급): Datablocks 운영센터
- Agent 가이드: [dlm-agent/README-Agent설치가이드.md](dlm-agent/README-Agent설치가이드.md)
- SDK 가이드: [xaudit-sdk/README.md](xaudit-sdk/README.md)
- 운영 문서: [docs/operations/](docs/operations/), [docs/sites/JB우리캐피탈/](docs/sites/)

---

**※ JB우리캐피탈 1.0.0 — 2026-04-26 기준.** 후속 패치는 §8 의 "패치 배포" 절차로 진행.
