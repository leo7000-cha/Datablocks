# DLM 이상행위 알림 소명 워크플로우 설계

## 1. 개요

이상행위 탐지 후 대상자에게 소명을 요청하고, 관리자가 승인/재소명하는 워크플로우.
금융권 접속기록관리 규정(개인정보보호법 제8조, 전자금융감독규정) 준수.

### 벤치마크
- **INFOSAFER** (피앤피시큐어): 접속기록관리 전용 솔루션, 소명 관리가 핵심 기능
- 금융권 사실상 표준: `탐지 → 소명요청 → 대상자 사유입력 → 관리자 승인`

---

## 2. 상태 머신

```
NEW ─── 이메일 발송 ──→ NOTIFIED ─── 대상자 소명 ──→ JUSTIFIED ─── 관리자 승인 ──→ RESOLVED
 │                          │                            │
 └→ DISMISSED(오탐)    OVERDUE(SLA초과)            RE_JUSTIFY(재소명요청)
                            │                            │
                       ESCALATED(상위보고)          → JUSTIFIED로 복귀
```

| 상태 | 설명 | 전이 조건 |
|------|------|-----------|
| NEW | 탐지 직후 | 시스템 자동 생성 |
| NOTIFIED | 대상자에 이메일 발송 완료 | 관리자가 "소명요청" 클릭 |
| JUSTIFIED | 대상자가 소명 제출 | 대상자가 토큰 링크로 사유 입력 |
| RESOLVED | 관리자 승인 완료 | 관리자가 "승인" 클릭 |
| RE_JUSTIFY | 재소명 요청 | 관리자가 "재소명" 클릭 |
| DISMISSED | 오탐/무시 | 관리자가 "무시" 클릭 |
| OVERDUE | SLA 초과 (미소명) | 스케줄러 자동 전환 (48시간) |
| ESCALATED | 상위 보고 | 스케줄러 자동 전환 (OVERDUE 후 24시간) |

---

## 3. 핵심 기능: 토큰 기반 소명 페이지

### 로그인 불필요
- UUID 토큰이 인증 역할 → 대상자가 DLM 계정 없어도 소명 가능
- 토큰 만료시간 설정 (기본 72시간)
- 1회 사용 후 재사용 불가 (RE_JUSTIFY 시 새 토큰 발급)

### 소명 페이지 URL
```
GET /accesslog/justify/{token}
```
- SecurityConfig: `/accesslog/justify/**` permitAll
- CSRF 면제: `/accesslog/justify/**`

---

## 4. DB 확장

### TBL_ACCESS_LOG_ALERT 컬럼 추가

```sql
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN notification_sent_at DATETIME NULL;
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN notification_token VARCHAR(64) NULL;
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN token_expires_at DATETIME NULL;
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN justification TEXT NULL;
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN justified_at DATETIME NULL;
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN justified_by VARCHAR(100) NULL;
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN approver_id VARCHAR(50) NULL;
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN approval_comment TEXT NULL;
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN approved_at DATETIME NULL;
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN sla_deadline DATETIME NULL;
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN escalation_level INT DEFAULT 0;
ALTER TABLE TBL_ACCESS_LOG_ALERT ADD COLUMN target_user_email VARCHAR(200) NULL;
```

---

## 5. API 설계

### 대상자용 (토큰 기반, 로그인 불필요)
| Method | URL | 설명 |
|--------|-----|------|
| GET | `/accesslog/justify/{token}` | 소명 입력 페이지 |
| POST | `/accesslog/justify/{token}/submit` | 소명 제출 |

### 관리자용 (인증 필요)
| Method | URL | 설명 |
|--------|-----|------|
| POST | `/accesslog/api/alert/{id}/notify` | 소명 요청 이메일 발송 |
| POST | `/accesslog/api/alert/{id}/approve` | 승인 |
| POST | `/accesslog/api/alert/{id}/reject` | 재소명 요청 |
| GET | `/accesslog/api/alert/{id}/detail` | 상세 (소명내용+이력) |

---

## 6. 이메일 템플릿

### 소명 요청 메일
```
Subject: [DLM] 이상행위 소명 요청 - {alert_title}

{target_user_name}님,

접속기록 모니터링 시스템에서 아래 이상행위가 탐지되었습니다.

  규칙: {rule_name}
  심각도: {severity}
  탐지시간: {detected_time}
  상세: {alert_detail}

아래 링크를 클릭하여 소명(사유)을 입력해 주십시오.
→ {base_url}/accesslog/justify/{token}

※ 이 링크는 {expire_hours}시간 후 만료됩니다.
※ {sla_hours}시간 내 소명하지 않을 경우 상위 관리자에게 보고됩니다.
```

---

## 7. 구현 단계

| Phase | 기능 | 파일 |
|-------|------|------|
| 1 | DB DDL 확장 | DDL SQL |
| 2 | Domain/Mapper/Service 확장 | AccessLogAlertVO, AccessLogMapper, AccessLogService |
| 3 | SecurityConfig + 소명 페이지 | SecurityConfig, justify.jsp, JustifyController |
| 4 | 관리자 승인/재소명 UI | alerts.jsp 확장 |
| 5 | 이메일 발송 확장 | AccessLogEmailService |
| 6 | SLA 스케줄러 | AccessLogScheduler |
