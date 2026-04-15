# DLM Agent 설치 가이드 — iM캐피탈

> 대상: iM캐피탈 처리계 WAS 서버
> 작성일: 2026-04-14

---

## 개요

DLM Agent는 WAS에 설치되는 경량 Java Agent입니다.
WAS에서 실행되는 모든 SQL 중 **감사 대상 테이블에 접근하는 SQL만** 감지하여 DLM 서버로 전송합니다.

```
처리계 WAS                              DLM 서버
============                           ============
[Agent 설치]                            
  ↓ JDBC 가로채기                       
  ↓ 감사 대상 테이블 SQL만 필터링         
  ↓ 배치 전송 (3초/500건)               [접속기록 수신]
  → HTTP POST ─────────────────────→   [이상행위 탐지]
                                       [대시보드 표시]
```

---

## 사전 준비

### 1. DLM 서버에서 수집 소스 등록

DLM 웹 > **접속기록 > 수집 관리 > 수집 소스 등록** 에서:

1. 수집 방식: **WAS 접근 감사** 선택
2. 대상 DB: 처리계 DB 선택
3. 사용자 식별: 세션 속성명 입력 (아래 참고)
4. **등록** 클릭

### 2. 감사 대상 테이블 등록

DLM 웹 > **접속기록 > 감사 대상 테이블 관리** 에서:

- Agent가 감시할 테이블을 등록합니다
- **미등록 시 Agent가 아무 SQL도 수집하지 않습니다** (안전장치)

### 3. 세션 속성명 확인

처리계 WAS 개발 담당자에게 확인이 필요합니다:

> "로그인 후 사용자 ID를 세션에 어떤 이름으로 저장하나요?"

| WAS 프레임워크 | 일반적인 값 | 설명 |
|---------------|-----------|------|
| 전자정부/DevOn | `loginVO.id` | 세션에 VO 객체 저장 → `.getId()` 자동 호출 |
| 자체 프레임워크 | `userId` | 세션에 문자열 직접 저장 |
| Spring Security | (비워두기) | Agent가 자동 탐지 |
| SSO 환경 | 인증 방식을 "SSO" 선택 후 헤더명 입력 | `SM_USER`, `iv-user` 등 |

**지금 모르면 비워두고 설치하세요.** Agent 설치 후 접속기록에서 사용자가 `UNKNOWN`으로 나오면 그때 확인하여 설정 파일에서 수정합니다.

---

## 설치

### 파일 구성

```
dlm-agent/
├── dlm-agent-1.0.0.jar          ← Agent JAR (4.5MB)
├── dlm-agent.properties         ← 설정 파일 (★ 환경에 맞게 수정)
├── install.sh                   ← 자동 설치 스크립트
└── README-Agent설치가이드.md      ← 이 문서
```

### 방법 1: 자동 설치 (권장)

```bash
# 1. 파일을 WAS 서버에 복사 (USB, SCP 등)
scp -r dlm-agent/ wasuser@처리계서버:/tmp/

# 2. 설정 파일 수정
vi /tmp/dlm-agent/dlm-agent.properties
#    dlm.server.url=http://DLM서버IP:8080    ← DLM 서버 주소
#    dlm.agent.id=IMCAP_WAS1                 ← 이 WAS 식별자
#    dlm.user.session-attr=loginVO.id        ← 세션 속성명 (확인 후)

# 3. 설치 실행
sudo bash /tmp/dlm-agent/install.sh
```

### 방법 2: 수동 설치

```bash
# 1. 설치 디렉토리 생성
sudo mkdir -p /opt/dlm-agent/failover

# 2. 파일 복사
sudo cp dlm-agent-1.0.0.jar /opt/dlm-agent/
sudo cp dlm-agent.properties /opt/dlm-agent/

# 3. 설정 파일 수정
sudo vi /opt/dlm-agent/dlm-agent.properties
```

---

## WAS JVM 옵션 추가

설치 후 WAS의 JVM 옵션에 아래 인자를 추가합니다:

```
-javaagent:/opt/dlm-agent/dlm-agent-1.0.0.jar=/opt/dlm-agent/dlm-agent.properties
```

### Tomcat

```bash
# setenv.sh 생성/수정
vi $CATALINA_HOME/bin/setenv.sh

# 아래 내용 추가
CATALINA_OPTS="$CATALINA_OPTS -javaagent:/opt/dlm-agent/dlm-agent-1.0.0.jar=/opt/dlm-agent/dlm-agent.properties"
```

### WebLogic

```
관리콘솔 로그인
  → 환경 > 서버 > [대상 서버] > 구성 > 서버 시작
  → 인수 필드에 추가:
    -javaagent:/opt/dlm-agent/dlm-agent-1.0.0.jar=/opt/dlm-agent/dlm-agent.properties
  → 저장 후 서버 재시작
```

### JEUS

```bash
# domain.xml 또는 WebAdmin에서 JVM 옵션 추가
vi $JEUS_HOME/domains/도메인/config/domain.xml

# <jvm-option> 섹션에 추가:
# -javaagent:/opt/dlm-agent/dlm-agent-1.0.0.jar=/opt/dlm-agent/dlm-agent.properties

# 또는 WebAdmin > 서버 > JVM 옵션 > 추가
```

---

## WAS 재시작 후 확인

### 1. WAS 로그 확인

WAS 재시작 후 표준 출력(stdout) 또는 로그 파일에서 아래 메시지를 확인합니다:

```
[XAudit-Agent] ========================================
[XAudit-Agent] DLM Access Log Agent v1.0.0 starting...
[XAudit-Agent] ========================================
[XAudit-Agent] Config loaded: serverUrl=http://192.168.1.100:8080, agentId=IMCAP_WAS1
[XAudit-Agent] Policy synced: 5 target tables, 12 PII columns
[XAudit-Agent] LogShipper started: batchSize=500, flushInterval=3000ms
[XAudit-Agent] ByteBuddy instrumentation installed (JDBC + FilterChain).
[XAudit-Agent] Agent successfully installed.
[XAudit-Agent] ========================================
```

**확인 포인트:**
- `Policy synced: N target tables` → N이 0이면 감사 대상 테이블이 미등록 (DLM에서 등록 필요)
- `Agent successfully installed.` → 정상 설치 완료

### 2. DLM 웹에서 확인

- **접속기록 > 수집 관리**: 해당 소스 카드에 `Heartbeat: 정상` 표시 (약 1분 소요)
- **접속기록 > 대시보드**: 수집 건수 증가 확인
- **접속기록 > 조회**: 실제 접속기록 데이터 확인
  - `user_account`가 `UNKNOWN`이면 → 세션 속성명 설정 필요

### 3. 사용자 UNKNOWN 시 조치

접속기록의 사용자가 `UNKNOWN`으로 기록되는 경우:

```bash
# 1. 세션 속성명을 WAS 담당자에게 확인

# 2. Agent 설정 파일 수정
sudo vi /opt/dlm-agent/dlm-agent.properties
# dlm.user.session-attr=loginVO.id   ← 주석 해제 후 속성명 입력

# 3. WAS 재시작
```

---

## 설정 파일 상세

| 항목 | 기본값 | 설명 |
|------|--------|------|
| `dlm.server.url` | `http://192.168.1.100:8080` | DLM 서버 주소 |
| `dlm.agent.id` | `IMCAP_WAS1` | 이 Agent 식별자 (소스 등록 시 Agent ID와 일치) |
| `dlm.agent.secret` | (비어있음) | DLM에 AGENT_API_SECRET 설정 시 동일값 입력 |
| `dlm.user.session-attr` | (비어있음) | 세션 속성명 (`loginVO.id`, `userId` 등) |
| `dlm.user.header` | (비어있음) | SSO 헤더명 (`SM_USER` 등) |
| `dlm.buffer.capacity` | `10000` | 메모리 버퍼 최대 건수 |
| `dlm.shipper.batch-size` | `500` | 한 번에 전송하는 최대 건수 |
| `dlm.shipper.flush-interval-ms` | `3000` | 전송 주기 (3초) |
| `dlm.policy.sync-interval-ms` | `300000` | 정책 동기화 주기 (5분) |
| `dlm.exclude.sql-patterns` | `SELECT 1,...` | 수집 제외 SQL (쉼표 구분) |
| `dlm.exclude.users` | `SYS,SYSTEM` | 수집 제외 DB 계정 |
| `dlm.failover.dir` | `/opt/dlm-agent/failover` | 전송 실패 시 임시 저장 경로 |

---

## WAS 다중 인스턴스

WAS가 여러 인스턴스(서버)인 경우, **각 인스턴스마다 별도 Agent ID**를 사용합니다:

```bash
# WAS1
dlm.agent.id=IMCAP_WAS1

# WAS2
dlm.agent.id=IMCAP_WAS2
```

DLM에서도 각각 수집 소스를 등록합니다.

---

## 제거

```bash
# 1. WAS JVM 옵션에서 -javaagent 인자 제거
# 2. WAS 재시작
# 3. 파일 삭제
sudo rm -rf /opt/dlm-agent
```

---

## 문제 해결

| 증상 | 원인 | 조치 |
|------|------|------|
| WAS 로그에 `[XAudit-Agent]` 없음 | JVM 옵션 미적용 | `-javaagent` 인자 확인 후 WAS 재시작 |
| `Policy sync failed: HTTP 401` | Agent Secret 불일치 | `dlm.agent.secret` 값 확인 |
| `Policy synced: 0 target tables` | 감사 대상 미등록 | DLM > 감사 대상 테이블 관리에서 등록 |
| `Log send failed: HTTP 연결 거부` | DLM 서버 접속 불가 | `dlm.server.url` 확인, 방화벽 확인 |
| `Heartbeat: 미연결` | Agent 미설치 또는 통신 실패 | WAS 로그 확인, 네트워크 확인 |
| 사용자 = `UNKNOWN` | 세션 속성명 미설정/불일치 | 속성명 확인 후 properties 수정 |
| 사용자 = `LoginVO@3a7b1c2d` | 객체 toString 문제 | `loginVO.id` 형식(점 표기법)으로 변경 |
| 접속기록 건수 0 | 감사 대상 테이블에 해당하는 SQL 없음 | 대상 테이블 확인, WAS 접속 발생 여부 확인 |
