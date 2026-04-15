===============================================================
  DLM 한국손해사정 배포 가이드
  작성일: 2026-03-19
  최종수정: 2026-03-20
===============================================================

[전체 흐름]
  현재서버(Rocky Linux) → 패키징 → USB전달 → 고객사(Ubuntu) → 배포

===============================================================
  목차
===============================================================

  1. 스크립트 전체 목록
  2. 가져갈 파일 목록
  3. [현재서버] 패키징 (01_pack_source_server.sh)
  4. [고객사] USB 전달 및 준비
  5. [고객사] MariaDB 배포 (02_deploy_mariadb.sh)  ★ DB 먼저
  6. [고객사] Tomcat 배포 (03_deploy_tomcat.sh)
  7. [고객사] 서비스 시작 및 접속 확인
  8. [고객사] 서비스 관리 (04_dlm_service.sh)
  9. 배포 후 체크리스트
  10. 고객사 디렉토리 구조
  11. systemd 서비스 상세
  12. 운영 스크립트 (Xone 계열)
  13. 트러블슈팅
  14. 서비스 삭제 (필요시)

===============================================================
1. 스크립트 전체 목록
===============================================================

  ┌──────────────────────────────┬─────────────────────────────────┐
  │ 스크립트                      │ 용도                             │
  ├──────────────────────────────┼─────────────────────────────────┤
  │ 01_pack_source_server.sh     │ 현재서버에서 패키징 (tar.gz)     │
  │ 02_deploy_mariadb.sh         │ 고객사 MariaDB 설정 + DB 복구    │
  │ 03_deploy_tomcat.sh          │ 고객사 Java/Tomcat/서비스 설치   │
  │ 04_dlm_service.sh            │ Tomcat 간편 관리 (시작/중지/상태)│
  ├──────────────────────────────┼─────────────────────────────────┤
  │ Xone_first_deploy.sh         │ 운영: 최초 WAR 배포 (SSL 포함)   │
  │ Xone_deploy.sh               │ 운영: WAR 업데이트 배포           │
  │ Xone_backup.sh               │ 운영: DB 백업 (일일 자동화용)     │
  │ Xone_logs_clean.sh           │ 운영: 7일 초과 로그 삭제          │
  └──────────────────────────────┴─────────────────────────────────┘

  ※ 초기 배포 순서: 01 → (USB전달) → 02 → 03 → 서비스시작
  ※ 이후 WAR 업데이트: Xone_deploy.sh

===============================================================
2. 가져갈 파일 목록
===============================================================

  ┌─────────────────────────────────────────────────────────────┐
  │ 구분       │ 내용                          │ 비고           │
  ├─────────────────────────────────────────────────────────────┤
  │ DB 덤프    │ cotdl_dump.sql                │ 자동 생성      │
  │ DB 계정    │ cotdl_users.sql               │ 자동/수동      │
  │ Tomcat     │ /opt/tomcat 폴더 전체          │ WAR 포함       │
  │            │  ├ apache-tomcat-9.0.87/       │                │
  │            │  └ latest (symlink)            │                │
  │ Java       │ Amazon Corretto 11 JDK        │ /usr/lib/jvm/  │
  │ 스크립트   │ 02_deploy_mariadb.sh          │ DB 배포        │
  │            │ 03_deploy_tomcat.sh            │ WAS 배포       │
  │            │ 04_dlm_service.sh             │ 서비스 관리    │
  └─────────────────────────────────────────────────────────────┘

  ※ 01_pack_source_server.sh 실행하면 위 파일들이 자동으로
     /backup/dlm_deploy_YYYYMMDD.tar.gz 로 패키징됩니다.

===============================================================
3. [현재서버] 패키징 (01_pack_source_server.sh)
===============================================================

  ■ 실행 환경: 현재 서버 (Rocky Linux)
  ■ 권한: root

  ① 스크립트 상단 경로 확인 및 수정

     vi 01_pack_source_server.sh

     TOMCAT_LATEST="/opt/tomcat/latest"                      ← Tomcat symlink
     JAVA_HOME_DIR="/usr/lib/jvm/java-11-amazon-corretto"    ← Java 경로

  ② 실행

     sudo bash 01_pack_source_server.sh

     ※ MariaDB root 비밀번호를 2번 입력합니다
        - 1번째: DB 덤프 (STEP 1/6)
        - 2번째: 계정 GRANT 추출 (STEP 2/6)

  ③ 수행되는 6단계

     STEP 1/6  MariaDB cotdl DB 덤프 (mysqldump)
     STEP 2/6  cotdl 사용자 계정 GRANT 추출
     STEP 3/6  /opt/tomcat 폴더 전체 복사 (logs/temp/work 제외)
     STEP 4/6  Amazon Corretto 11 JDK 복사
     STEP 5/6  systemd tomcat.service 백업 (참고용)
     STEP 6/6  배포 스크립트(02~04) 복사

  ④ 결과 확인

     ls -lh /backup/dlm_deploy_YYYYMMDD.tar.gz

  ⑤ 비밀번호 확인 (중요!)

     cat /backup/dlm_deploy_YYYYMMDD/db/cotdl_users.sql

     ※ IDENTIFIED BY 뒤에 비밀번호가 정확히 들어갔는지 확인
     ※ 안 들어갔으면 cotdl_users_template.sql에 수동 입력:
        vi /backup/dlm_deploy_YYYYMMDD/db/cotdl_users_template.sql
        → [비밀번호] 부분을 실제 비밀번호로 교체

  ⑥ 패키징 결과 구조

     dlm_deploy_YYYYMMDD/
     ├── db/
     │   ├── cotdl_dump.sql              DB 전체 덤프
     │   ├── cotdl_users.sql             사용자 계정/권한 (자동추출)
     │   └── cotdl_users_template.sql    사용자 계정/권한 (수동 템플릿)
     ├── tomcat/
     │   ├── apache-tomcat-9.0.87/       Tomcat 본체 + WAR
     │   └── latest -> apache-tomcat-... symlink
     ├── java/
     │   └── amazon-corretto-11/         Amazon Corretto JDK 11
     └── scripts/
         ├── 02_deploy_mariadb.sh        DB 배포 스크립트
         ├── 03_deploy_tomcat.sh         Tomcat 배포 스크립트
         ├── 04_dlm_service.sh           서비스 관리 스크립트
         └── tomcat.service.bak          현재 서버 서비스 파일 (참고용)

===============================================================
4. [고객사] USB 전달 및 준비
===============================================================

  ■ 실행 환경: 고객사 서버 (Ubuntu)
  ■ 사전조건: Ubuntu 설치 완료, MariaDB 설치 완료

  ① USB에 아래 파일들을 복사

     /backup/dlm_deploy_YYYYMMDD.tar.gz    (약 500MB)

  ② 고객사 서버에 USB 마운트 후 복사

     # USB 마운트 (자동 마운트 안 되면)
     sudo mkdir -p /mnt/usb
     sudo mount /dev/sdb1 /mnt/usb

     # 파일 복사
     cp /mnt/usb/dlm_deploy_YYYYMMDD.tar.gz /tmp/

     # USB 해제
     sudo umount /mnt/usb

  ③ 스크립트 꺼내기 (tar.gz 안에 scripts/ 폴더에 포함)

     cd /tmp
     tar xzf dlm_deploy_YYYYMMDD.tar.gz
     ls /tmp/dlm_deploy_YYYYMMDD/scripts/
     → 02_deploy_mariadb.sh, 03_deploy_tomcat.sh, 04_dlm_service.sh

===============================================================
5. [고객사] MariaDB 배포 (02_deploy_mariadb.sh) ★ DB 먼저!
===============================================================

  ■ 실행 환경: 고객사 서버 (Ubuntu)
  ■ 권한: root
  ■ 사전조건: MariaDB가 설치되어 있고 root 비밀번호를 알고 있어야 함

  ★ 중요: Tomcat보다 DB를 먼저 배포해야 합니다!
     (Tomcat 시작 시 DB 연결이 필요)

  ① 실행

     sudo bash /tmp/dlm_deploy_YYYYMMDD/scripts/02_deploy_mariadb.sh \
       /tmp/dlm_deploy_YYYYMMDD.tar.gz

     또는 이미 해제된 디렉토리를 직접 지정:

     sudo bash /tmp/dlm_deploy_YYYYMMDD/scripts/02_deploy_mariadb.sh \
       /tmp/dlm_deploy_YYYYMMDD

  ② MariaDB root 비밀번호 입력

     ※ 총 3~5번 비밀번호를 입력해야 합니다 (각 STEP별 mysql 명령)
        - STEP 1: 글로벌 설정 적용
        - STEP 2: DB 덤프 import
        - STEP 3: 사용자 계정 복구
        - STEP 4: 검증 (2~3회)

  ③ 수행되는 4단계 상세

     ┌─────────┬───────────────────────────────────────────────────┐
     │ 단계     │ 내용                                              │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 1/4│ MariaDB 글로벌 설정                                │
     │         │ - innodb_file_format = Barracuda                   │
     │         │ - innodb_large_prefix = ON                         │
     │         │ - innodb_default_row_format = DYNAMIC              │
     │         │ - innodb_strict_mode = OFF                         │
     │         │ - character_set_server = utf8mb4                   │
     │         │ → /etc/mysql/mariadb.conf.d/99-dlm.cnf 영구 저장  │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 2/4│ cotdl DB 복구                                      │
     │         │ - varchar(1024) → text 자동 변환                    │
     │         │ - ROW_FORMAT=DYNAMIC 자동 적용                      │
     │         │ - cotdl_dump.sql import                             │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 3/4│ 사용자 계정 복구                                    │
     │         │ - cotdl_users.sql 자동 적용                         │
     │         │ ※ 파일 없으면 템플릿 수동 편집 안내 출력             │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 4/4│ 검증                                               │
     │         │ - 테이블 수 확인                                    │
     │         │ - 계정 4개 존재 확인                                 │
     │         │ - 각 계정별 GRANT 권한 확인                          │
     └─────────┴───────────────────────────────────────────────────┘

  ④ cotdl_users.sql 없을 때 수동 처리

     ※ STEP 3에서 "자동 추출 파일 없음" 경고가 나오면:

     vi /tmp/dlm_deploy_YYYYMMDD/db/cotdl_users_template.sql

     → [비밀번호] 부분을 실제 비밀번호로 모두 교체 후:

     mysql -u root -p < /tmp/dlm_deploy_YYYYMMDD/db/cotdl_users_template.sql

  ⑤ DB 배포 완료 후 검증

     # cotdl 계정으로 접속 테스트
     mysql -u cotdl -p cotdl -e 'SHOW TABLES;'

     # 테이블 수 확인
     mysql -u cotdl -p cotdl -e \
       "SELECT COUNT(*) AS table_count FROM information_schema.tables WHERE table_schema='cotdl';"

     # 계정 확인
     mysql -u root -p -e "SELECT User, Host FROM mysql.user WHERE User IN ('cotdl','cotdlbk');"

     ※ 예상 계정 4개:
        cotdl@%         (ALL PRIVILEGES)
        cotdl@localhost  (ALL PRIVILEGES)
        cotdl@127.0.0.1  (ALL PRIVILEGES)
        cotdlbk@%        (SELECT 또는 ALL)

===============================================================
6. [고객사] Tomcat 배포 (03_deploy_tomcat.sh)
===============================================================

  ■ 실행 환경: 고객사 서버 (Ubuntu)
  ■ 권한: root
  ■ 사전조건: MariaDB 배포(02) 완료

  ① 실행

     sudo bash /tmp/dlm_deploy_YYYYMMDD/scripts/03_deploy_tomcat.sh \
       /tmp/dlm_deploy_YYYYMMDD.tar.gz

  ② 수행되는 9단계 상세

     ┌─────────┬───────────────────────────────────────────────────┐
     │ 단계     │ 내용                                              │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 0/9│ 아카이브 해제                                      │
     │         │ → /tmp/dlm_deploy_work/ 에 압축 풀기               │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 1/9│ tomcat 시스템 사용자 생성                           │
     │         │ useradd -m -U -d /opt/tomcat -s /bin/false tomcat  │
     │         │ ※ 이미 존재하면 건너뜀                              │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 2/9│ Amazon Corretto 11 JDK 설치                        │
     │         │ → /usr/lib/jvm/java-11-amazon-corretto             │
     │         │ → /etc/profile.d/dlm_java.sh (JAVA_HOME 설정)      │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 3/9│ Tomcat 설치                                        │
     │         │ → /opt/tomcat/apache-tomcat-9.0.87                 │
     │         │ → /opt/tomcat/latest (symlink)                     │
     │         │ → logs, temp, work 디렉토리 생성                    │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 4/9│ Tomcat 실행 권한                                    │
     │         │ chmod 755 bin/*, chmod +x bin/*.sh                 │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 5/9│ 로그 디렉토리 + 소유권                              │
     │         │ /dlmlogs → tomcat:tomcat                           │
     │         │ /dlmapilogs → tomcat:tomcat                        │
     │         │ /opt/tomcat → tomcat:tomcat (전체)                  │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 6/9│ sudoers 설정                                       │
     │         │ → /etc/sudoers.d/tomcat                            │
     │         │ tomcat ALL=(ALL) NOPASSWD: ALL                     │
     │         │ ※ visudo 문법 검증 후 적용                          │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 7/9│ systemd tomcat.service 등록                        │
     │         │ → /etc/systemd/system/tomcat.service               │
     │         │ → systemctl daemon-reload + enable                 │
     │         │ - JVM: -Xms4096M -Xmx22464M                       │
     │         │ - Profile: prod                                    │
     │         │ - PID: /opt/tomcat/latest/temp/tomcat.pid          │
     │         │ - Restart: on-failure (10초 후 재시작)               │
     ├─────────┼───────────────────────────────────────────────────┤
     │ STEP 8/9│ 방화벽 (UFW)                                       │
     │         │ ufw allow 8080/tcp                                 │
     │         │ ※ MariaDB 3306은 localhost 접속이므로 불필요         │
     └─────────┴───────────────────────────────────────────────────┘

  ③ 완료 후 자동 검증 항목

     - Java 버전 출력
     - Tomcat symlink 확인
     - WAR 파일 존재 확인
     - /opt/tomcat, /dlmlogs, /dlmapilogs 소유권 확인
     - sudoers 설정 확인

  ④ 서버 메모리 확인 (중요!)

     free -h

     ※ JVM -Xmx22464M (약 22G) 설정이므로 최소 32GB RAM 필요
     ※ 메모리 부족하면 서비스 파일 수정:

     sudo vi /etc/systemd/system/tomcat.service

     → CATALINA_OPTS 에서 -Xms, -Xmx 값을 서버에 맞게 조정
     예) RAM 16G인 경우: -Xms2048M -Xmx12288M

     수정 후:
     sudo systemctl daemon-reload

===============================================================
7. [고객사] 서비스 시작 및 접속 확인
===============================================================

  ① Tomcat 시작

     sudo systemctl start tomcat

  ② 시작 로그 확인 (실시간)

     tail -f /opt/tomcat/latest/logs/catalina.out

     ※ "Server startup in XXXXX milliseconds" 메시지가 나오면 정상 기동
     ※ 기동에 1~3분 소요될 수 있음
     ※ Ctrl+C로 로그 모니터링 종료

  ③ 포트 확인

     ss -tlnp | grep 8080

     ※ LISTEN 상태이면 정상

  ④ 웹 접속 확인

     http://<서버IP>:8080

  ⑤ 문제 발생 시

     # systemd 서비스 상태
     sudo systemctl status tomcat

     # 전체 서비스 로그
     sudo journalctl -u tomcat --no-pager -n 50

     # catalina 에러 로그
     grep -i "error\|exception" /opt/tomcat/latest/logs/catalina.out | tail -20

===============================================================
8. [고객사] 서비스 관리 (04_dlm_service.sh)
===============================================================

  ■ 배포 후 운영 시 간편 관리용
  ■ 적절한 위치에 복사해두고 사용

  # 스크립트 복사 (예: /opt/tomcat/)
  sudo cp /tmp/dlm_deploy_YYYYMMDD/scripts/04_dlm_service.sh /opt/tomcat/
  sudo chmod +x /opt/tomcat/04_dlm_service.sh

  ┌────────────────────────────────────────────────────────────────┐
  │ 명령어                                  │ 설명                  │
  ├────────────────────────────────────────────────────────────────┤
  │ sudo bash 04_dlm_service.sh start       │ Tomcat 시작           │
  │                                         │ → 3초 후 상태 표시     │
  ├────────────────────────────────────────────────────────────────┤
  │ sudo bash 04_dlm_service.sh stop        │ Tomcat 중지           │
  ├────────────────────────────────────────────────────────────────┤
  │ sudo bash 04_dlm_service.sh restart     │ Tomcat 재시작         │
  │                                         │ → 3초 후 상태 표시     │
  ├────────────────────────────────────────────────────────────────┤
  │ sudo bash 04_dlm_service.sh status      │ 종합 상태 확인         │
  │                                         │ → 서비스/포트/PID/로그 │
  ├────────────────────────────────────────────────────────────────┤
  │ sudo bash 04_dlm_service.sh log         │ catalina.out 실시간    │
  │                                         │ → Ctrl+C로 종료       │
  ├────────────────────────────────────────────────────────────────┤
  │ sudo bash 04_dlm_service.sh check       │ 전체 환경 점검         │
  │                                         │ → Java, Tomcat, DB,   │
  │                                         │   디스크, 소유권       │
  └────────────────────────────────────────────────────────────────┘

  ※ systemctl 직접 사용도 가능:
     sudo systemctl start tomcat
     sudo systemctl stop tomcat
     sudo systemctl restart tomcat
     sudo systemctl status tomcat
     sudo journalctl -u tomcat -f

===============================================================
9. 배포 후 체크리스트
===============================================================

  □ WAR 파일 확인
    ls -la /opt/tomcat/latest/webapps/DLM.war

  □ application.properties DB 접속정보
    - Jasypt 암호화 키가 현재서버와 동일해야 함
    - DB 접속 URL이 localhost:3306/cotdl 인지 확인

  □ logback 로그 경로 확인
    - spring.profiles.active=prod (systemd에 설정됨)
    - logback-prod.xml 에서 로그 경로 → /dlmlogs, /dlmapilogs

  □ 서버 메모리 충분한가?
    free -h
    - JVM 22G 설정 → 최소 32G RAM 권장
    - 부족시: /etc/systemd/system/tomcat.service CATALINA_OPTS 수정

  □ MariaDB 3306 포트
    - localhost 접속이므로 방화벽 불필요
    - ss -tlnp | grep 3306 으로 Listen 확인

  □ Tomcat 8080 포트 외부 접근 가능
    - sudo ufw status 로 8080 허용 확인
    - 외부에서 telnet <서버IP> 8080 테스트

  □ cotdl 계정 4개 확인
    mysql -u root -p -e "SELECT User,Host FROM mysql.user WHERE User IN ('cotdl','cotdlbk');"
    - cotdl@%         (ALL PRIVILEGES)
    - cotdl@localhost  (ALL PRIVILEGES)
    - cotdl@127.0.0.1  (ALL PRIVILEGES)
    - cotdlbk@%        (SELECT 또는 ALL)

  □ cotdlbk 권한 레벨 확인
    mysql -u root -p -e "SHOW GRANTS FOR 'cotdlbk'@'%';"
    - SELECT만 필요한지, ALL이 필요한지 확인

  □ 자동시작 설정 확인
    systemctl is-enabled tomcat
    → "enabled" 이면 서버 재부팅 시 자동 시작

===============================================================
10. 고객사 서버 디렉토리 구조 (배포 후)
===============================================================

  /opt/tomcat/
  ├── apache-tomcat-9.0.87/     ← Tomcat 본체
  │   ├── bin/
  │   │   ├── catalina.sh
  │   │   └── ...
  │   ├── conf/
  │   ├── lib/
  │   ├── logs/
  │   ├── temp/
  │   │   └── tomcat.pid
  │   ├── webapps/
  │   │   └── DLM.war           ← DLM 애플리케이션
  │   └── work/
  └── latest -> apache-tomcat-9.0.87  ← symlink

  /usr/lib/jvm/java-11-amazon-corretto/  ← JDK
  /dlmlogs/                               ← DLM 로그
  /dlmapilogs/                            ← API 로그
  /etc/systemd/system/tomcat.service      ← systemd 서비스
  /etc/sudoers.d/tomcat                   ← sudoers
  /etc/profile.d/dlm_java.sh             ← JAVA_HOME
  /etc/mysql/mariadb.conf.d/99-dlm.cnf   ← MariaDB 설정

===============================================================
11. systemd 서비스 상세 (tomcat.service)
===============================================================

  [Unit]
  Description=X-One Apache Tomcat Service
  After=network.target mariadb.service
  Wants=mariadb.service              ← MariaDB가 먼저 올라와야 함

  [Service]
  Type=forking
  User=tomcat
  Group=tomcat

  Environment=JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto
  Environment=CATALINA_HOME=/opt/tomcat/latest
  Environment=CATALINA_BASE=/opt/tomcat/latest
  Environment=CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid

  CATALINA_OPTS:
    -Xms4096M                     초기 힙 4G
    -Xmx22464M                    최대 힙 약 22G
    -server                       서버 모드
    -XX:+UseParallelGC            병렬 GC

  JAVA_OPTS:
    -Djava.awt.headless=true
    -Djava.security.egd=file:/dev/./urandom
    -Dspring.profiles.active=prod  ← 프로덕션 프로필

  ExecStart=catalina.sh start
  ExecStop=catalina.sh stop
  Restart=on-failure
  RestartSec=10                    ← 실패 시 10초 후 재시작

===============================================================
12. 운영 스크립트 (Xone 계열)
===============================================================

  초기 배포 후 운영 단계에서 사용하는 스크립트입니다.

  ★ 모든 스크립트가 위치 독립적으로 동작합니다:
    - /datablocks/ 에서도, deploy/ 폴더에서도 실행 가능
    - WAR/JKS 파일은 스크립트 위치 → /datablocks/ 순서로 자동 탐색
    - 인자로 경로를 직접 지정할 수도 있음

  ────────────────────────────────────────────────────────
  12-1. Xone_first_deploy.sh (최초 WAR 배포)
  ────────────────────────────────────────────────────────

  ■ 용도: 초기 배포 후 최초로 WAR를 배포할 때 사용
  ■ 실행:
     sudo bash Xone_first_deploy.sh                    ← 자동 탐색
     sudo bash Xone_first_deploy.sh /path/to/DLM.war   ← WAR 직접 지정

  ■ DLM.war 탐색 순서:
     1) 인자로 지정한 경로
     2) 스크립트와 같은 디렉토리 (예: deploy/DLM.war)
     3) /datablocks/DLM.war (기존 경로)

  ■ harmonix_kr.jks 탐색 순서:
     1) 스크립트와 같은 디렉토리
     2) /datablocks/harmonix_kr.jks
     ※ 없으면 SSL 설정을 건너뜀 (경고 출력)

  ■ Tomcat 버전: /opt/tomcat/latest symlink에서 자동 감지
     (기존처럼 버전을 하드코딩하지 않음)

  수행 작업 (9단계):
    [1] SSL 디렉토리 생성 (/opt/tomcat/latest/conf/ssl/)
    [2] keystore 파일 복사 (harmonix_kr.jks) — 없으면 건너뜀
    [3] upload 디렉토리 생성
    [4] 기존 DLM.war, DLM/ 삭제
    [5] DLM 디렉토리 생성
    [6] DLM.war 파일 복사
    [7] jar xf 압축 해제 → WAR 파일 삭제
    [8] logback-local.xml, application.properties 권한 설정 (776)
    [9] /opt/tomcat 전체 소유자 변경 (tomcat)

  ■ 완료 후:
     vi /opt/tomcat/latest/webapps/DLM/WEB-INF/classes/application.properties
     sudo systemctl start tomcat

  ────────────────────────────────────────────────────────
  12-2. Xone_deploy.sh (WAR 업데이트)
  ────────────────────────────────────────────────────────

  ■ 용도: 운영 중 WAR 파일 업데이트 배포
  ■ 실행:
     sudo bash Xone_deploy.sh                    ← 자동 탐색
     sudo bash Xone_deploy.sh /path/to/DLM.war   ← WAR 직접 지정

  ■ DLM.war 탐색 순서:
     1) 인자로 지정한 경로
     2) 스크립트와 같은 디렉토리
     3) /datablocks/DLM.war

  수행 작업 (7단계):
    [1] Tomcat 서비스 중지
    [2] 설정 파일 백업 (application.properties, logback-local.xml)
    [3] 기존 resources/, WEB-INF/, META-INF/ 삭제
    [4] 새 DLM.war 복사 + jar xf 해제 + WAR 삭제
    [5] 소유자/권한 재설정 (tomcat, 776)
    [6] 설정 파일 복원 ← application.properties, logback-local.xml 자동 복원
    [7] Tomcat 서비스 시작

  ※ application.properties와 logback-local.xml은
     자동 백업/복원되므로 고객사 설정이 유지됩니다.

  ────────────────────────────────────────────────────────
  12-3. Xone_backup.sh (DB 백업)
  ────────────────────────────────────────────────────────

  ■ 용도: cotdl DB 일일 백업
  ■ 실행:
     sudo bash Xone_backup.sh                       ← 자동
     sudo bash Xone_backup.sh /path/to/backup_dir   ← 백업 디렉토리 지정

  ■ 백업 디렉토리 결정 순서:
     1) 인자로 지정한 경로
     2) /datablocks/backup (기존 경로, /datablocks 존재 시)
     3) 스크립트와 같은 디렉토리/backup (예: deploy/backup/)

  ■ DB 접속 방식 (.my.cnf 자동 탐색):
     1) 스크립트와 같은 디렉토리의 .my.cnf
     2) /datablocks/.my.cnf
     3) ~/.my.cnf (MariaDB 기본)
     4) 위 모두 없으면 → 비밀번호 직접 입력 (mysql -p)

  ■ .my.cnf 파일 만들기 (비밀번호 직접 입력 대신 자동화할 때):

     cat > /datablocks/.my.cnf << 'EOF'
     [mysqldump]
     user=root
     password=비밀번호
     EOF
     chmod 600 /datablocks/.my.cnf

     또는 스크립트 디렉토리에:
     cat > /opt/tomcat/.my.cnf << 'EOF'
     [mysqldump]
     user=root
     password=비밀번호
     EOF
     chmod 600 /opt/tomcat/.my.cnf

  수행 작업:
    1) 백업 디렉토리 확인/생성
    2) mysqldump (--single-transaction, routines, triggers, utf8mb4)
    3) gzip 압축 → db_backup_YYYYMMDD.sql.gz
    4) 3일 초과 백업 파일 자동 삭제
    5) 현재 백업 목록 출력

  ────────────────────────────────────────────────────────
  12-4. Xone_logs_clean.sh (로그 정리)
  ────────────────────────────────────────────────────────

  ■ 용도: N일 초과된 로그 파일 삭제
  ■ 실행:
     sudo bash Xone_logs_clean.sh        ← 기본 7일
     sudo bash Xone_logs_clean.sh 14     ← 14일로 변경

  대상 디렉토리:
    /opt/tomcat/latest/logs/
    /opt/tomcat/latestapi/logs/
    /dlmapilogs/
    /dlmlogs/
    ※ 존재하지 않는 디렉토리는 자동 건너뜀

  ────────────────────────────────────────────────────────
  crontab 종합 예시
  ────────────────────────────────────────────────────────

     sudo crontab -e

     # DLM DB 백업 (매일 02:00)
     0 2 * * * /opt/tomcat/Xone_backup.sh >> /var/log/dlm_backup.log 2>&1

     # DLM 로그 정리 (매일 03:00)
     0 3 * * * /opt/tomcat/Xone_logs_clean.sh >> /var/log/dlm_logclean.log 2>&1

===============================================================
13. 트러블슈팅
===============================================================

  ────────────────────────────────────────────────────────
  Q. DB 복구 시 인코딩 오류?
  ────────────────────────────────────────────────────────
  A. 덤프 파일 인코딩 변환:
     iconv -f UTF-16 -t UTF-8 cotdl_dump.sql > cotdl_dump_utf8.sql

  ────────────────────────────────────────────────────────
  Q. Row size too large 오류?
  ────────────────────────────────────────────────────────
  A. 02_deploy_mariadb.sh가 자동 처리합니다:
     - varchar(1024) → text 변환
     - ROW_FORMAT=DYNAMIC 적용
     수동 확인: SHOW TABLE STATUS FROM cotdl WHERE Row_format != 'Dynamic';

  ────────────────────────────────────────────────────────
  Q. Tomcat 시작 후 접속 안됨?
  ────────────────────────────────────────────────────────
  A. 순서대로 확인:
     1) 로그 확인
        tail -f /opt/tomcat/latest/logs/catalina.out
        → ERROR, Exception 메시지 확인

     2) 포트 확인
        ss -tlnp | grep 8080
        → LISTEN 없으면 Tomcat이 아직 기동 중이거나 실패

     3) 방화벽 확인
        sudo ufw status
        → 8080/tcp ALLOW 확인

     4) DB 연결 확인
        mysql -u cotdl -p cotdl -e "SELECT 1;"
        → 실패하면 DB 계정/권한 문제

  ────────────────────────────────────────────────────────
  Q. Jasypt 복호화 실패?
  ────────────────────────────────────────────────────────
  A. application.properties 내 ENC() 값의 암호화 키가
     현재서버와 고객사에서 동일하게 세팅되었는지 확인.
     키가 다르면 DB 접속정보 복호화 실패 → 연결 오류.

  ────────────────────────────────────────────────────────
  Q. Permission denied 오류?
  ────────────────────────────────────────────────────────
  A. 소유권 재설정:
     sudo chown -R tomcat:tomcat /opt/tomcat /dlmlogs /dlmapilogs

  ────────────────────────────────────────────────────────
  Q. java: command not found?
  ────────────────────────────────────────────────────────
  A. JAVA_HOME 설정 확인:
     source /etc/profile.d/dlm_java.sh
     echo $JAVA_HOME
     $JAVA_HOME/bin/java -version

  ────────────────────────────────────────────────────────
  Q. Tomcat 기동 시 Out of Memory?
  ────────────────────────────────────────────────────────
  A. 서버 메모리 부족. JVM 설정 조정:
     sudo vi /etc/systemd/system/tomcat.service
     → CATALINA_OPTS 에서 -Xms, -Xmx 줄이기
     sudo systemctl daemon-reload
     sudo systemctl restart tomcat

  ────────────────────────────────────────────────────────
  Q. MariaDB 서비스가 안 올라옴?
  ────────────────────────────────────────────────────────
  A. MariaDB 상태 확인:
     sudo systemctl status mariadb
     sudo journalctl -u mariadb --no-pager -n 30

     99-dlm.cnf 설정 문제일 수 있음:
     sudo mv /etc/mysql/mariadb.conf.d/99-dlm.cnf /tmp/
     sudo systemctl restart mariadb

  ────────────────────────────────────────────────────────
  Q. Tomcat이 자꾸 재시작됨?
  ────────────────────────────────────────────────────────
  A. systemd Restart=on-failure 설정 때문.
     로그에서 원인 확인:
     sudo journalctl -u tomcat --since "1 hour ago" --no-pager

  ────────────────────────────────────────────────────────
  Q. WAR 배포 후 404 오류?
  ────────────────────────────────────────────────────────
  A. WAR가 exploded 되었는지 확인:
     ls /opt/tomcat/latest/webapps/DLM/WEB-INF/
     없으면 WAR가 해제되지 않은 것.
     Tomcat 재시작 또는 Xone_deploy.sh 재실행.

===============================================================
14. 서비스 삭제 (필요시)
===============================================================

  # 서비스 중지 및 해제
  sudo systemctl stop tomcat
  sudo systemctl disable tomcat
  sudo rm /etc/systemd/system/tomcat.service
  sudo systemctl daemon-reload

  # 사용자 및 디렉토리 삭제
  sudo userdel -r tomcat         ← /opt/tomcat 및 관련 파일 모두 삭제
  sudo groupdel tomcat           ← userdel -r 이후 그룹 남아있으면

  # 기타 파일 삭제
  sudo rm -rf /dlmlogs /dlmapilogs
  sudo rm -f /etc/profile.d/dlm_java.sh
  sudo rm -f /etc/sudoers.d/tomcat
  sudo rm -f /etc/mysql/mariadb.conf.d/99-dlm.cnf

  # DB 삭제 (주의!)
  mysql -u root -p -e "DROP DATABASE cotdl;"
  mysql -u root -p -e "DROP USER 'cotdl'@'%', 'cotdl'@'localhost', 'cotdl'@'127.0.0.1', 'cotdlbk'@'%';"

===============================================================
  끝.
===============================================================
