# SMTP 테스트 환경 설정 (Mailtrap)

개발계에서 이메일 발송 테스트를 위해 [Mailtrap](https://mailtrap.io) Sandbox를 사용한다.
실제 메일이 발송되지 않고 Mailtrap Inbox에서 확인할 수 있어 안전하다.

## 1. Mailtrap 계정 설정

1. https://mailtrap.io 가입/로그인
2. **HOME > Sandboxes > My Sandbox** 선택
3. **Show Credentials** 클릭 → Host, Port, Username, Password 확인

## 2. .env 설정

```env
# --- Mail (SMTP) ---
MAIL_HOST=sandbox.smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=<Mailtrap Username>
MAIL_PASSWORD=<Mailtrap Password>
```

## 3. 설정 흐름

```
.env
  ↓ docker compose 자동 로드
docker-compose.yml (environment 섹션)
  ↓ 컨테이너 환경변수
application.properties (spring.mail.host=${MAIL_HOST} ...)
  ↓ Spring Boot 자동 구성
JavaMailSender → AccessLogEmailService
```

## 4. DLM DB 설정

TBL_ACCESS_LOG_CONFIG 테이블에서 이메일 기능을 활성화해야 한다.

| configKey | configValue | 설명 |
|-----------|------------|------|
| EMAIL_ENABLED | true | 이메일 발송 활성화 |
| EMAIL_RECIPIENTS | admin@example.com | 관리자 수신 이메일 (쉼표 구분) |

## 5. 적용 및 확인

```bash
# DLM 재빌드
docker compose up -d --build dlm

# 메일 확인
# Mailtrap > Email Testing > Sandboxes > My Sandbox
```

## 6. 운영계 전환 시

`.env` 또는 `.env.hanson`에서 실제 SMTP로 변경한다.

```env
# Gmail 예시
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=실제이메일@gmail.com
MAIL_PASSWORD=앱비밀번호(16자리)
```

> Gmail 앱 비밀번호: Google 계정 > 보안 > 2단계 인증 활성화 > 앱 비밀번호 생성
