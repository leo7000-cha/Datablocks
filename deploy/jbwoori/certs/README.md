# HTTPS 인증서 배치 디렉터리

이 폴더에 **`dlm-keystore.p12`** 파일을 배치하면 DLM 컨테이너의 `/etc/ssl/dlm-keystore.p12` 로 마운트됩니다. (`.p12` 확장자의 PKCS12 형식 키스토어)

## 테스트용 자체 서명 인증서 생성

```bash
cd deploy/jbwoori/certs
keytool -genkeypair \
  -alias dlm-keystore \
  -storetype PKCS12 \
  -keyalg RSA -keysize 2048 \
  -validity 3650 \
  -keystore dlm-keystore.p12 \
  -storepass dlmssl \
  -dname "CN=localhost,OU=DLM,O=Datablocks,L=Seoul,S=Seoul,C=KR"
```

생성 후 `.env.jbwoori` 의 `SERVER_SSL_KEY_STORE_PASSWORD` 값이 `storepass` 와 일치하는지 확인하세요.

## 운영용 실 인증서 교체

고객사에서 발급받은 CA 서명 인증서(PEM `crt` + `key` 페어)는 `openssl` 로 PKCS12 로 변환 후 배치:

```bash
openssl pkcs12 -export \
  -in server.crt \
  -inkey server.key \
  -certfile ca-bundle.crt \
  -name dlm-keystore \
  -out dlm-keystore.p12 \
  -passout pass:<원하는_비밀번호>
```

교체 반영:

```bash
docker compose -f docker-compose.jbwoori.yml --env-file .env.jbwoori restart dlm
```

WAR 재빌드 불필요 — 파일만 교체하고 컨테이너 재시작하면 적용됩니다.

## 체크리스트

- [ ] `dlm-keystore.p12` 파일이 이 폴더에 존재
- [ ] 파일 권한 `644` 이하 (키 비밀번호는 `.env.jbwoori` 로만 관리)
- [ ] `.env.jbwoori` 의 `SERVER_SSL_KEY_STORE_PASSWORD` / `SERVER_SSL_KEY_PASSWORD` 값이 실제 키스토어와 일치
- [ ] `SERVER_SSL_KEY_ALIAS` 값이 keystore 내부의 alias 와 일치 (`keytool -list -keystore dlm-keystore.p12` 로 확인)
