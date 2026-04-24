# 문제 해결 가이드

## 목차
1. [컨테이너 시작 실패](#1-컨테이너-시작-실패)
2. [DLM Spring Boot 기동 오류](#2-dlm-spring-boot-기동-오류)
3. [MariaDB 관련 문제](#3-mariadb-관련-문제)
4. [컨테이너 간 네트워크 문제](#4-컨테이너-간-네트워크-문제)
5. [볼륨 데이터 지속성 문제](#5-볼륨-데이터-지속성-문제)
6. [Docker 디스크 공간 정리](#6-docker-디스크-공간-정리)
7. [성능 튜닝 팁](#7-성능-튜닝-팁)

---

## 1. 컨테이너 시작 실패

### 1.1 포트 충돌 (Bind address already in use)

**증상**:
```
Error starting userland proxy: listen tcp 0.0.0.0:8080: bind: address already in use
```

**진단**:
```bash
# 충돌 중인 포트 확인
ss -tlnp | grep -E '8080|8000|3306|9000'
# 또는
lsof -i :8080
lsof -i :3306
```

**해결**:
```bash
# 해당 포트를 사용 중인 프로세스 확인
ss -tlnp | grep 8080

# 기존 DLM 컨테이너가 남아있는 경우
docker ps -a | grep dlm
docker rm -f dlm-app dlm-mariadb dlm-privacy-ai dlm-portainer

# 다른 프로세스가 포트를 점유한 경우 (PID 확인 후 중지)
sudo kill -9 $(lsof -t -i:8080)

# 재시작
docker compose up -d
```

### 1.2 메모리 부족

**증상**:
```
Error response from daemon: Cannot start container: OOM killer killed container
```
또는 컨테이너가 시작 직후 `exited (137)` 로 종료되는 경우.

**진단**:
```bash
# 호스트 메모리 확인
free -h

# 현재 컨테이너 메모리 합산 확인
docker stats --no-stream --format "{{.MemUsage}}" | \
  awk -F'/' '{sum+=$1} END {print "사용 중 합계:", sum, "단위 미정"}'

# Docker 이벤트에서 OOM 기록 확인
docker events --since=1h --filter event=oom
```

**해결**:
```bash
# 불필요한 컨테이너/이미지 정리
docker system prune -f

# 각 서비스 메모리 제한 임시 완화 (docker-compose.yml 수정)
# deploy.resources.limits.memory 값을 낮추거나
# 한 번에 하나씩 서비스 시작
docker compose up -d mariadb
# MariaDB healthy 확인 후
docker compose up -d dlm
# 안정화 후
docker compose up -d dlm-privacy-ai
```

### 1.3 권한 문제

**증상**:
```
Error: mkdir /app/logs: permission denied
```
또는 볼륨 마운트 디렉토리 접근 거부.

**진단**:
```bash
# 볼륨 마운트 경로 권한 확인
docker exec dlm-app ls -la /app/
docker exec dlm-app id    # 실행 중인 사용자 확인 (dlm:dlm 이어야 함)
```

**해결**:
```bash
# Dockerfile에서 권한 설정을 확인
# DLM: RUN mkdir -p /app/logs /app/upload && chown -R dlm:dlm /app
# 이 명령이 없다면 이미지 재빌드 필요

docker compose build --no-cache dlm
docker compose up -d dlm

# 볼륨 권한 수동 수정 (임시 방편)
docker exec -u root dlm-app chown -R dlm:dlm /app/logs
```

### 1.4 Dockerfile 또는 소스 빌드 오류

**증상**:
```
error building image: failed to execute dockerfile
```

**진단**:
```bash
# 빌드 로그 상세 확인
docker compose build --progress=plain dlm 2>&1 | tail -50
```

**해결**:
```bash
# Gradle 빌드 오류 (DLM)
# - build.gradle, settings.gradle 구문 오류 확인
# - libs/ 디렉토리에 의존성 jar 파일 존재 여부 확인
ls /app/Datablocks/DLM/libs/

# Python 패키지 오류 (DLM-Privacy-AI)
# - requirements.txt 형식 확인
cat /app/Datablocks/DLM-Privacy-AI/requirements.txt

# 캐시 없이 재빌드
docker compose build --no-cache dlm
docker compose build --no-cache dlm-privacy-ai
```

---

## 2. DLM Spring Boot 기동 오류

### 2.1 Logback 로그 경로 오류

**증상**:
```
ERROR in ch.qos.logback - Failed to create parent directories for [/app/logs/xxx.log]
```
또는 DLM이 시작되지 않고 로그에 Logback 관련 오류.

**원인**: DLM의 Logback 설정이 `/app/logs` 경로를 참조하는데, 해당 디렉토리가 없거나 권한이 없음.

**진단**:
```bash
# 컨테이너 내 /app/logs 존재 여부
docker exec dlm-app ls -la /app/logs/
```

**해결**:
```bash
# Dockerfile에 /app/logs 생성이 포함되어 있는지 확인
grep -n "logs" /app/Datablocks/DLM/Dockerfile
# 결과: RUN mkdir -p /app/logs /app/upload && chown -R dlm:dlm /app

# 없다면 Dockerfile 수정 후 재빌드
docker compose build --no-cache dlm
docker compose up -d dlm

# 임시 방편 (재시작 시 사라짐)
docker exec -u root dlm-app mkdir -p /app/logs
docker exec -u root dlm-app chown dlm:dlm /app/logs
docker compose restart dlm
```

### 2.2 DB 연결 실패

**증상**:
```
com.mysql.jdbc.exceptions.jdbc4.CommunicationsException: Communications link failure
Unable to acquire JDBC Connection
```

**원인**: MariaDB가 아직 준비되지 않았거나, 연결 설정 오류.

**진단**:
```bash
# MariaDB 상태 확인
docker compose ps mariadb
# STATUS가 "Up (healthy)"인지 확인

# DLM이 사용하는 DB URL 확인
docker exec dlm-app env | grep -i "datasource\|db"

# 네트워크 내에서 MariaDB 접근 가능 여부
docker exec dlm-app sh -c "nc -zv dlm-mariadb 3306 && echo OK || echo FAIL"
# nc가 없는 경우
docker exec dlm-app sh -c "timeout 3 bash -c 'cat < /dev/null > /dev/tcp/dlm-mariadb/3306' && echo OK || echo FAIL"
```

**해결**:
```bash
# MariaDB 먼저 healthy 상태로 만들기
docker compose up -d mariadb
watch docker compose ps mariadb
# "Up (healthy)" 확인 후

docker compose up -d dlm

# .env 파일 DB URL 확인
grep SPRING_DATASOURCE_URL /app/Datablocks/.env
# jdbc:mariadb://dlm-mariadb:3306/cotdl?... 형식이어야 함
# 호스트명이 "dlm-mariadb" (컨테이너명)인지 확인
```

### 2.3 Jasypt 복호화 오류

**증상**:
```
com.ulisesbocchio.jasyptspringboot.exception.DecryptionException
Failed to decrypt property
EncryptionOperationNotPossibleException
```

**원인**: Jasypt 암호화 키가 잘못 설정됨. `application.properties`의 `ENC(...)` 값을 복호화하지 못함.

**진단**:
```bash
# 현재 설정된 Jasypt 키 확인
docker exec dlm-app env | grep JASYPT
grep JASYPT_ENCRYPTOR_PASSWORD /app/Datablocks/.env
```

**해결**:
```bash
# .env 파일에서 JASYPT 키 확인 및 수정
vi /app/Datablocks/.env
# JASYPT_ENCRYPTOR_PASSWORD=datablocks  ← 이 값이 정확해야 함

# 수정 후 재시작 (재빌드 불필요, 환경변수만 변경됨)
docker compose up -d dlm
```

> **참고**: Jasypt 키 `datablocks`로 암호화된 값만 복호화됩니다. `application.properties`에 `ENC(xxx)` 형태로 저장된 패스워드들은 이 키로 복호화됩니다.

### 2.4 Spring Boot 메모리 부족 (OutOfMemoryError)

**증상**:
```
java.lang.OutOfMemoryError: Java heap space
Container exited with code 137 (OOMKilled)
```

**진단**:
```bash
# 힙 덤프 파일 생성 여부 확인
docker exec dlm-app ls -lh /app/logs/*.hprof 2>/dev/null

# 현재 메모리 사용량
docker stats --no-stream dlm-app
```

**해결**:
```bash
# docker-compose.yml에서 메모리 제한 확인
grep -A 5 "memory" /app/Datablocks/docker-compose.yml

# JAVA_OPTS 힙 크기 줄이기 (예: 개발 환경에서 메모리 부족 시)
# docker-compose.yml 또는 .env에서 수정
# -Xms2g -Xmx8g → -Xms1g -Xmx4g

# 힙 덤프 분석 (Eclipse Memory Analyzer 등 활용)
docker cp dlm-app:/app/logs/heapdump.hprof /tmp/heapdump.hprof
```

### 2.5 WAR 파일 미생성

**증상**:
```
COPY failed: file not found in build context: build/libs/*.war
```

**원인**: Gradle 빌드가 실패하여 WAR 파일이 생성되지 않음.

**진단**:
```bash
# 빌드 상세 로그 확인
docker compose build --progress=plain dlm 2>&1 | grep -A 10 "FAILED\|error"
```

**해결**:
```bash
# 로컬에서 직접 빌드 테스트
cd /app/Datablocks/DLM
./gradlew bootWar --no-daemon 2>&1 | tail -30

# libs 디렉토리 확인 (외부 의존성)
ls /app/Datablocks/DLM/libs/

# 테스트 제외하고 빌드 (테스트 오류 시)
./gradlew bootWar --no-daemon -x test
```

---

## 3. MariaDB 관련 문제

### 3.1 타임존 오류

**증상**:
```
Unknown or incorrect time zone: 'Asia/Seoul'
```

**원인**: MariaDB 타임존 테이블이 로드되지 않음.

**진단**:
```bash
# 타임존 테이블 확인
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SELECT COUNT(*) FROM mysql.time_zone_name;"
# 0이면 타임존 데이터 미로드

# 현재 타임존 설정
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SELECT @@global.time_zone, @@session.time_zone;"
```

**해결**:
```bash
# 타임존 데이터 수동 로드
docker exec -it dlm-mariadb bash -c \
  "mysql_tzinfo_to_sql /usr/share/zoneinfo | mariadb -u root -p'root_비밀번호' mysql"

# MariaDB 재시작
docker compose restart mariadb

# 확인
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SELECT @@global.time_zone;"
# 'Asia/Seoul' 출력되어야 함
```

> **참고**: `00-load-timezone.sh` 초기화 스크립트가 정상 실행되었다면 이 문제는 발생하지 않습니다. 볼륨을 재생성한 경우 `docker compose down -v && docker compose up -d` 로 완전 초기화하세요.

### 3.2 init 스크립트 미실행

**증상**: MariaDB가 시작됐지만 `cotdl` 데이터베이스 또는 사용자가 없음.

**원인**: `docker-entrypoint-initdb.d/` 스크립트는 볼륨이 **비어있을 때만** 실행됩니다.

**진단**:
```bash
# cotdl DB 존재 여부 확인
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SHOW DATABASES;"

# init 스크립트 실행 로그 확인
docker compose logs mariadb 2>&1 | grep "\[init\]"
```

**해결**:
```bash
# 방법 1: 볼륨 초기화 후 재시작 (모든 데이터 삭제 주의!)
docker compose down -v
docker compose up -d

# 방법 2: 수동으로 스크립트 실행 (데이터 유지)
# 타임존 로드
docker exec -it dlm-mariadb bash -c \
  "mysql_tzinfo_to_sql /usr/share/zoneinfo | mariadb -u root -p'root_비밀번호' mysql"

# 덤프 복원
docker exec -it dlm-mariadb bash -c \
  "sed -e 's/\`question\` varchar(1024)/\`question\` text/g' \
       -e 's/ENGINE=InnoDB/ENGINE=InnoDB ROW_FORMAT=DYNAMIC/g' \
   /docker-entrypoint-initdb.d/cotdl_dump.sql.data | \
   mariadb -u root -p'root_비밀번호' -f"

# 사용자 생성
docker exec -it dlm-mariadb bash -c \
  "mariadb -u root -p'root_비밀번호' < /docker-entrypoint-initdb.d/cotdl_users.sql.data"
```

### 3.3 ANSI_QUOTES 관련 SQL 오류

**증상**: DLM에서 SQL 실행 시 다음과 같은 오류 발생:
```
You have an error in your SQL syntax; check the manual...
```
특히 큰따옴표(`"`)로 감싼 식별자 관련 오류.

**원인**: DLM의 MyBatis 쿼리가 큰따옴표(`"`)를 컬럼/테이블 식별자로 사용하므로, MariaDB에 `ANSI_QUOTES` SQL 모드가 필요합니다.

**진단**:
```bash
# 현재 SQL 모드 확인
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SELECT @@sql_mode;"
# ANSI_QUOTES가 포함되어 있어야 함
```

**해결**:
```bash
# custom.cnf 확인
grep "sql_mode" /app/Datablocks/mariadb/conf.d/custom.cnf
# sql_mode = "ANSI_QUOTES,..." 포함 여부 확인

# 설정이 적용되었는지 확인
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SHOW VARIABLES LIKE 'sql_mode';"

# 적용되지 않은 경우 MariaDB 재시작
docker compose restart mariadb
```

### 3.4 MariaDB 비밀번호 오류

**증상**:
```
Access denied for user 'cotdl'@'%' (using password: YES)
```

**진단**:
```bash
# cotdl 사용자 존재 여부 확인
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SELECT User, Host FROM mysql.user WHERE User='cotdl';"

# cotdl 사용자 권한 확인
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SHOW GRANTS FOR 'cotdl'@'%';"
```

**해결**:
```bash
# cotdl 비밀번호 재설정
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' -e "
ALTER USER 'cotdl'@'%' IDENTIFIED BY '새_비밀번호';
FLUSH PRIVILEGES;
"

# .env 파일도 동일하게 수정
vi /app/Datablocks/.env
# PRIVACY_AI_DB_PASSWORD=새_비밀번호

# 서비스 재시작
docker compose up -d dlm dlm-privacy-ai
```

### 3.5 lower_case_table_names 오류

**증상**: 테이블 조회 시 `Table 'cotdl.TABLENAME' doesn't exist` 오류 (대소문자 불일치).

**원인**: `lower_case_table_names=1` 설정이 없어 테이블명 대소문자를 구분함.

**진단**:
```bash
docker exec -it dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SHOW VARIABLES LIKE 'lower_case_table_names';"
# 1이어야 함
```

**해결**:
```bash
# custom.cnf 확인
grep "lower_case" /app/Datablocks/mariadb/conf.d/custom.cnf

# 설정 적용 위해 재시작 (이미 설정된 경우 재시작으로 해결)
docker compose restart mariadb

# 주의: lower_case_table_names 값은 MariaDB 최초 초기화 시 결정됨
# 이미 데이터가 있는 경우 변경하려면 완전 초기화 필요 (데이터 손실)
```

---

## 4. 컨테이너 간 네트워크 문제

### 4.1 컨테이너명으로 통신 불가

**증상**: DLM에서 `dlm-mariadb:3306` 접속 실패.

**진단**:
```bash
# 동일 네트워크에 있는지 확인
docker network inspect dlm-network

# DLM 컨테이너에서 MariaDB 접근 테스트
docker exec dlm-app sh -c \
  "timeout 3 bash -c 'cat < /dev/null > /dev/tcp/dlm-mariadb/3306' && echo OK || echo FAIL"

# DNS 해석 확인
docker exec dlm-app nslookup dlm-mariadb 2>/dev/null || \
docker exec dlm-app getent hosts dlm-mariadb
```

**해결**:
```bash
# 네트워크 확인 및 재생성
docker network ls | grep dlm
docker network inspect dlm-network

# 컨테이너가 dlm-network에 연결되어 있는지 확인
docker inspect dlm-app | grep -A 5 '"Networks"'

# 네트워크 재생성 (모든 서비스 재시작 필요)
docker compose down
docker network rm dlm-network 2>/dev/null || true
docker compose up -d
```

### 4.2 DLM-Privacy-AI에서 DLM API 호출 실패

**증상**: AI 서비스에서 DLM API 호출 시 연결 거부.

**진단**:
```bash
# DLM-Privacy-AI에서 DLM 접근 테스트
docker exec dlm-privacy-ai sh -c \
  "curl -s -o /dev/null -w '%{http_code}' http://dlm-app:8080/ || echo FAIL"

# 환경변수 확인
docker exec dlm-privacy-ai env | grep PRIVACY_AI_DLM
```

**해결**:
```bash
# .env 파일에서 DLM URL 확인
grep PRIVACY_AI_DLM_API_URL /app/Datablocks/.env
# http://dlm-app:8080 이어야 함 (컨테이너명 사용)

# DLM이 정상 실행 중인지 확인
docker compose ps dlm
curl http://localhost:8080/    # 호스트에서 접근 확인

# 서비스 재시작
docker compose restart dlm-privacy-ai
```

---

## 5. 볼륨 데이터 지속성 문제

### 5.1 재시작 후 DB 데이터 손실

**증상**: `docker compose down && docker compose up` 후 DB 데이터 없음.

**원인**: `docker compose down -v` 옵션 사용 시 볼륨이 삭제됨.

**진단**:
```bash
# 볼륨 목록 확인
docker volume ls | grep dlm

# 볼륨 상세 확인
docker volume inspect dlm-mariadb-data
```

**해결**:
```bash
# 볼륨 유지하며 중지/시작
docker compose down        # -v 옵션 없이 사용
docker compose up -d

# 볼륨이 삭제된 경우 DB 재초기화 필요
docker compose down -v     # 완전 초기화
docker compose up -d       # 볼륨 재생성 + init 스크립트 재실행
```

> **주의**: `docker compose down -v`, `docker volume rm dlm-mariadb-data` 명령은 모든 DB 데이터를 삭제합니다. 운영 환경에서는 절대 사용하지 마세요.

### 5.2 업로드 파일 누락

**증상**: DLM 재시작 후 업로드된 파일이 없어짐.

**진단**:
```bash
# 업로드 볼륨 확인
docker volume inspect dlm-app-upload
docker exec dlm-app ls -la /app/upload/
```

**해결**:
```bash
# 볼륨이 올바르게 마운트되어 있는지 확인
docker inspect dlm-app | python3 -c "
import json, sys
data = json.load(sys.stdin)
mounts = data[0]['Mounts']
for m in mounts:
    print(m['Name'] if 'Name' in m else m['Source'], '->', m['Destination'])
"
# dlm-app-upload -> /app/upload 가 있어야 함
```

---

## 6. Docker 디스크 공간 정리

### 6.1 디스크 사용량 확인

```bash
# Docker 전체 사용량
docker system df

# 상세 사용량 (이미지별, 컨테이너별)
docker system df -v

# Docker 데이터 디렉토리 크기
sudo du -sh /var/lib/docker/
```

### 6.2 안전한 정리 (실행 중인 리소스 유지)

```bash
# 중지된 컨테이너, 미사용 네트워크, 댕글링 이미지, 빌드 캐시 삭제
docker system prune -f

# 예상 확보 용량 미리 확인 (삭제 없이)
docker system prune --dry-run
```

### 6.3 빌드 캐시 정리

```bash
# 빌드 캐시만 정리 (이미지/컨테이너 유지)
docker builder prune -f

# 특정 기간 이전 캐시 삭제
docker builder prune --filter until=24h -f
```

### 6.4 미사용 이미지 정리

```bash
# 사용되지 않는 이미지 확인
docker images -f "dangling=true"

# 댕글링 이미지만 삭제
docker image prune -f

# 사용 중이지 않은 모든 이미지 삭제 (주의: DLM 이미지도 삭제될 수 있음)
docker image prune -a -f

# DLM 관련 이미지 보존하면서 정리
docker images | grep -v "datablocks\|mariadb\|portainer" | \
  awk 'NR>1 {print $3}' | xargs docker rmi -f 2>/dev/null || true
```

### 6.5 볼륨 정리

```bash
# 미사용 볼륨 확인
docker volume ls -f dangling=true

# 미사용 볼륨 삭제 (DLM 볼륨은 삭제되지 않음 - 사용 중이면 안전)
docker volume prune -f
```

### 6.6 MariaDB 바이너리 로그 정리

```bash
# 바이너리 로그 현황
docker exec dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SHOW BINARY LOGS;" 2>/dev/null

# 7일 이전 바이너리 로그 삭제
docker exec dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);" 2>/dev/null
```

### 6.7 긴급 공간 확보

```bash
# 실행 중인 서비스는 유지하면서 최대한 정리
docker system prune -af --volumes 2>/dev/null || docker system prune -af

# 주의: --volumes 옵션은 미사용 볼륨도 삭제함
# DLM 서비스가 실행 중이라면 DLM 볼륨은 안전 (사용 중으로 인식)
```

---

## 7. 성능 튜닝 팁

### 7.1 Spring Boot 시작 속도 개선

```bash
# 불필요한 자동 설정 제외 확인
# application.properties에 추가 가능:
# spring.jmx.enabled=false
# spring.autoconfigure.exclude=...

# JVM 힙 초기화 크기 조정 (Xms를 너무 크게 설정하면 시작 시간 증가)
# 개발: -Xms512m -Xmx8g
# 운영: -Xms4g -Xmx16g
```

### 7.2 MariaDB 연결 풀 최적화

```bash
# 현재 연결 수 모니터링
docker exec dlm-mariadb mariadb -u root -p'root_비밀번호' \
  -e "SHOW STATUS WHERE Variable_name IN ('Threads_connected', 'Max_used_connections');"

# max_connections 500 대비 실제 사용량 확인
# 실제 사용량이 100 미만이면 max_connections를 줄여 메모리 절약 가능
```

### 7.3 Docker 빌드 속도 개선

```bash
# Gradle 의존성 캐시 활용 확인 (Dockerfile에 이미 구현됨)
# COPY gradlew settings.gradle build.gradle ./
# RUN ./gradlew dependencies  ← 의존성만 먼저 다운로드 (레이어 캐시)

# pip 패키지 캐시 활용 (DLM-Privacy-AI Dockerfile에 구현됨)
# COPY requirements.txt .
# RUN pip install ...  ← requirements.txt 변경 없으면 캐시 재사용
```

### 7.4 컨테이너 시작 시간 단축

```bash
# MariaDB healthy 대기 시간 최적화
# docker-compose.yml healthcheck 설정:
# start_period: 30s  (MariaDB 초기화 완료 후 헬스체크 시작)
# interval: 15s      (헬스체크 간격)
# retries: 5         (재시도 횟수)

# DLM depends_on mariadb healthy → MariaDB가 빠를수록 DLM도 빨리 시작
```

### 7.5 로그 성능 영향 최소화

```bash
# 로그 레벨 조정 (운영 환경)
# application-prod.properties:
# logging.level.root=WARN
# logging.level.com.datablocks=INFO

# PRIVACY_AI_DEBUG=false 확인
grep PRIVACY_AI_DEBUG /app/Datablocks/.env
```

### 7.6 DLM-Privacy-AI 워커 수 최적화

```bash
# Dockerfile에서 uvicorn workers 수 확인
grep workers /app/Datablocks/DLM-Privacy-AI/Dockerfile
# --workers 4  ← CPU 코어 수에 따라 조정
# 일반적으로 CPU 코어 수 x 2 + 1이 최적

# 운영 환경 CPU 2코어 할당 시
# --workers 5 (2 * 2 + 1)
```
