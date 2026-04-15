# Docker 배포 설정 가이드

## 1. docker run으로 실행하는 경우

```bash
docker run -d \
  --name tomcat-app \
  --cpus="4" \
  --memory="4g" \
  -e JAVA_OPTS="-XX:+UseContainerSupport -XX:ActiveProcessorCount=4" \
  -v /dlmlog:/dlmlog \
  -p 8080:8080 \
  tomcat:9
```

### 옵션 설명

#### CPU 설정
```bash
--cpus="4"
```
Docker 컨테이너가 CPU 4개 사용 가능

#### JVM 옵션
```bash
-e JAVA_OPTS="-XX:ActiveProcessorCount=4"
```
Tomcat 실행 시 JVM 옵션 전달

#### 로그 폴더 연결
```bash
-v /dlmlog:/dlmlog
```

| 왼쪽 (서버 OS) | 오른쪽 (Docker 내부) |
|---------------|-------------------|
| /dlmlog       | /dlmlog           |

컨테이너 로그가 서버 /dlmlog에 저장됨

---

## 2. docker-compose 사용하는 경우 (운영 추천)

파일: `docker-compose.yml`

```yaml
version: '3'

services:
  tomcat:
    image: tomcat:9
    container_name: tomcat-app
    ports:
      - "8080:8080"
    deploy:
      resources:
        limits:
          cpus: '4'
    environment:
      - JAVA_OPTS=-XX:+UseContainerSupport -XX:ActiveProcessorCount=4
    volumes:
      - /dlmlog:/dlmlog
```

실행:
```bash
docker-compose up -d
```

---

## 3. 사전 작업 (필수)

서버(OS)에 로그 폴더 생성:
```bash
mkdir -p /dlmlog
chmod 777 /dlmlog
```

이거 안 하면:
- 로그 안 써짐
- permission 오류
- thread 실행 시 WAIT 발생 가능

---

## 4. 적용 확인 방법

### CPU 확인
```bash
docker exec -it tomcat-app bash
java -XshowSettings:system -version | grep CPU
```
4 나오면 정상

### 로그 확인
```bash
ls /dlmlog
```
파일 생기면 OK

---

## 5. 핵심 정리

| 설정 | 레벨 | 역할 |
|------|------|------|
| --cpus="4" | Docker 리소스 | 컨테이너 CPU 제한 |
| -e JAVA_OPTS=... | JVM 동작 | JVM이 CPU 개수 인식 |
| -v /dlmlog:/dlmlog | 파일 시스템 | 로그 외부 연결 |

이 3가지는 각각 다른 레벨의 설정이며, thread pool이 정상 동작하려면 모두 적용해야 함.
