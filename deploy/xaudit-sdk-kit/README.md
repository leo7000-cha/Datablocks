# X-Audit SDK Kit

처리계(WAS) 접속기록·SQL 실행기록을 AOP 기반으로 수집하여 DLM 서버로 송신하는 2-side 배포 키트.

```
xaudit-sdk-kit/
├── customer/       ← 고객사 처리계 개발·운영팀에 전달
│   ├── lib/        SDK JAR (47 KB)
│   ├── snippets/   pom / build.gradle / application.yml / application.properties 병합용 조각
│   ├── scripts/    smoke-test.sh
│   └── README.md   고객사 적용 가이드
└── dlm-server/     ← DLM 운영팀 내부 전용
    ├── database/   COTDL 스키마 DDL
    └── README.md   DLM 서버 설치 가이드
```

> **snippets/ 폴더의 파일들은 모두 "병합용 조각" 입니다.** 단독 실행 불가 — 고객사 기존 파일(pom.xml / build.gradle / application.yml / application.properties) 에 복붙해서 병합합니다. 자세한 사용법은 [`customer/snippets/README.md`](customer/snippets/README.md) 참조.

## 누가 무엇을

| 역할 | 디렉토리 | 작업 |
|------|---------|------|
| **DLM 운영팀** (우리) | [`dlm-server/`](dlm-server/README.md) | DDL 1회 실행 |
| **고객사 처리계** (B은행 등) | [`customer/`](customer/README.md) | SDK JAR + application.yml + 재기동 |

## 배포 순서

1. 먼저 **DLM 서버**에서 `dlm-server/database/XAUDIT_SCHEMA_20260420.sql` 을 COTDL 에 실행
2. 그 다음 **`customer/` 디렉토리 전체**를 tar/zip 으로 압축해서 고객사에 전달
3. 고객사 수행: `customer/README.md` Step 1~3
4. 확인: `customer/scripts/smoke-test.sh` + DLM UI `/xaudit/dashboard`

**처리계 DB 스키마는 건드리지 않습니다.** 처리계는 SDK 를 통해 DLM 서버로 HTTP POST 만 수행.
