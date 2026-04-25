# DLM 배포 현행화 프롬프트

> 이 문서를 Claude에게 그대로 전달하면 3개 사이트 배포 패키지를 현행화합니다.
> 마지막 현행화: 2026-04-22

---

## 프롬프트 (아래를 복사하여 Claude에게 전달)

```
DLM 3개 고객사 배포 패키지를 현재 버전으로 현행화해줘.

■ 대상 폴더
  /app/Datablocks/deploy/hanson
  /app/Datablocks/deploy/imcapital
  /app/Datablocks/deploy/jbwoori

■ 현행화 작업 목록 (순서대로)

1. Docker 이미지 갱신
   - docker save datablocks-dlm:latest | gzip → 각 사이트 images/dlm-app.tar.gz
   - docker save datablocks-dlm-privacy-ai:latest | gzip → 각 사이트 images/dlm-privacy-ai.tar.gz
   - /tmp에 한번만 추출 후 3개 사이트에 cp (시간 절약)

2. 공통 폴더 동기화
   - /app/Datablocks/database/ → 각 사이트 database/ (rm -rf 후 cp -r)
   - /app/Datablocks/docs/     → 각 사이트 docs/     (rm -rf 후 cp -r)

3. 공통 파일 동기화
   - /app/Datablocks/mariadb/conf.d/custom-prod.cnf → 각 사이트 루트에 복사

4. 사이트 고유 파일 확인 (건드리지 않음, 존재 여부만 확인)
   - hanson:    docker-compose.hanson.yml, .env.hanson, scripts/deploy.sh, README-한국손사.md
   - imcapital: docker-compose.imcapital.yml, .env.imcapital, scripts/deploy.sh, scripts/install-docker.sh, README-iM캐피탈.md, docker-rpms/, dlm-agent/
   - jbwoori:   docker-compose.jbwoori.yml, .env.jbwoori, scripts/deploy.sh, scripts/install-docker.sh, README-JB우리캐피탈.md, docker-rpms/, dlm-agent/, certs/ (HTTPS 옵션)

5. dlm-agent JAR 갱신 (imcapital, jbwoori)
   - /app/Datablocks/DLM/dlm-agent/build/libs/dlm-agent-*.jar 가 있으면 → 각 사이트 dlm-agent/ 에 복사
   - 없으면 기존 유지

6. README 갱신일 업데이트
   - 3개 README의 "갱신:" 날짜를 오늘로 변경

7. 검증
   - 3개 사이트 images/ 파일 날짜 + 크기 확인
   - database/, docs/ md5 비교 (3개 사이트 동일한지)
   - custom-prod.cnf md5 비교
   - 사이트 고유 파일 존재 확인
   - docker-compose 문법 검증 (docker compose config --quiet)

■ 사이트별 환경 참고
  - hanson:    Ubuntu, MariaDB Docker 컨테이너, 포트 8082, DB hostname=mariadb
  - imcapital: CentOS 7, MariaDB 호스트 설치, 포트 8080, DB hostname=host.docker.internal
  - jbwoori:   Rocky 9, MariaDB 호스트 설치, 포트 8080, DB hostname=host.docker.internal

■ 주의사항
  - 사이트 고유 파일(docker-compose, .env, scripts, README, docker-rpms)은 수정하지 말 것
  - database/ docs/ 는 rm -rf 후 원본에서 새로 복사 (깨끗한 동기화)
  - 이미지 추출은 /tmp에 1회만 수행 후 3개 사이트에 복사 (3회 추출 금지)
  - 작업 완료 후 /tmp 임시 파일 삭제
  - 최종 결과를 표 형태로 보여줘
```

---

## 배포 패키지 구조 (참고)

```
deploy/{사이트}/
├── images/
│   ├── dlm-app.tar.gz                 ← DLM Docker 이미지
│   └── dlm-privacy-ai.tar.gz         ← Privacy-AI Docker 이미지
├── database/                          ← /app/Datablocks/database/ 사본
│   ├── ddl/                           ← DDL 마스터 + 패치
│   ├── init/                          ← 초기 데이터
│   ├── batch-job/                     ← 배치 Job SQL
│   ├── sql-workbook/                  ← 운영 SQL + 백업가이드
│   └── clients/                       ← 고객사별 패치
├── docs/                              ← /app/Datablocks/docs/ 사본
│   ├── architecture/
│   ├── deployment/
│   ├── design/
│   ├── development/
│   ├── guide/
│   ├── operations/
│   └── sites/
├── custom-prod.cnf                    ← MariaDB 설정 (DBA 전달용)
├── docker-compose.{사이트}.yml        ← 사이트 전용 Docker Compose
├── .env.{사이트}                      ← 사이트 전용 환경변수
├── scripts/
│   ├── deploy.sh                      ← 배포 스크립트
│   └── install-docker.sh             ← Docker 설치 (imcapital, jbwoori만)
├── docker-rpms/                       ← Docker RPM (imcapital, jbwoori만)
├── dlm-agent/                         ← Java Agent (BCI) (imcapital, jbwoori만)
│   ├── dlm-agent-*.jar
│   ├── dlm-agent.properties
│   ├── install.sh
│   └── README-Agent설치가이드.md
└── README-{사이트}.md                  ← 배포 가이드
```

---

## HTTPS / SSL 토글 (jbwoori 전용 옵션)

jbwoori 는 `.env.jbwoori` 와 `docker-compose.jbwoori.yml` 의 주석 블록 해제만으로 HTTPS(8443) + 8080→8443 자동 리다이렉트를 활성화할 수 있음. 기본값은 HTTP 8080 그대로.

- 인증서 배치: `deploy/jbwoori/certs/dlm-keystore.p12` (gitignore 처리됨)
- Spring Profile: `SPRING_PROFILES_ACTIVE=local,ssl` 일 때만 `TomcatSslConfig` 빈 활성화
- 구현 클래스: `DLM/src/main/java/datablocks/dlm/config/TomcatSslConfig.java` (`@Profile("ssl")`)
- 상세 절차: `deploy/jbwoori/README-JB우리캐피탈.md` 의 `HTTPS / SSL 운영 모드` 섹션
