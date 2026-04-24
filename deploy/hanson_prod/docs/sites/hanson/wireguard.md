# WireGuard VPN - 한국손사 접속

## 개요
한국손사 내부 네트워크 접속을 위한 WireGuard VPN 설정.
담당자: 최병문 (choibm75@gmail.com)

## 설치
- 다운로드: https://www.wireguard.com/install/
- Windows 설치 후 `mscha.conf` 파일 임포트

## 설정 파일 (mscha.conf)

```ini
[Interface]
PrivateKey = (생략)
Address = 10.8.234.5/24
DNS = 203.248.252.2

[Peer]
PublicKey = (생략)
# AllowedIPs = 0.0.0.0/0        # 원본 - 모든 트래픽 VPN (인터넷 안됨!)
AllowedIPs = 10.8.234.0/24      # 한국손사 내부만 VPN (split tunnel)
Endpoint = 106.242.169.2:51921
PresharedKey = (생략)
```

## 핵심 설정: AllowedIPs

| 설정 | 동작 | 내부망 | 인터넷 |
|------|------|--------|--------|
| `0.0.0.0/0` | 모든 트래픽 VPN 경유 | O | X (안됨) |
| `10.8.234.0/24` | 한국손사만 VPN | O | O (정상) |

> **주의**: `0.0.0.0/0`으로 설정하면 회사 내부망/인터넷 모두 VPN으로 빠져서 네트워크 장애 발생.
> 반드시 split tunnel(`10.8.234.0/24`)로 변경 후 사용할 것.
> 한국손사 내부 서버가 다른 대역에도 있으면 최병문님에게 확인.

## 한국손사 접속 정보

| 환경 | URL |
|------|-----|
| 운영계 | http://211.48.20.227:8082 |
| 개발계 | http://192.168.0.16:8082 |

> **참고**: 개발계(192.168.0.x)는 VPN 필수. 운영계(211.48.20.x)는 공인IP라 VPN 없이도 접속 가능할 수 있음.
> split tunnel 사용 시 AllowedIPs에 두 대역 모두 포함 필요:
> `AllowedIPs = 10.8.234.0/24, 192.168.0.0/24, 211.48.20.0/24`

## 사용법

### 켜기
1. WireGuard 앱 실행
2. 터널 `mscha` 선택 → **Activate**

### 끄기
1. 시스템 트레이(우측 하단 `^`) → WireGuard 아이콘 클릭
2. 터널 `mscha` 선택 → **Deactivate**
3. 완전 종료: File → Exit

### 강제 종료
- `Win + R` → `services.msc` → **WireGuard Tunnel: mscha** → 중지

## VPN 연결 시 접속 가능 (한국손사 측 포트 오픈 전제)
- SSH (22)
- FTP/SFTP (21/22)
- Web (80/443)

## 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| VPN 켜면 인터넷 안됨 | `AllowedIPs = 0.0.0.0/0` | `10.8.234.0/24`로 변경 |
| VPN 끄기 안됨 | 트레이에 숨어있음 | 트레이 아이콘에서 Deactivate |
| 부팅시 자동 연결 | 자동 시작 설정됨 | 터널 편집에서 체크 해제 |

## 참고
- `.conf` 파일은 `#`으로 코멘트 가능
- 키 정보는 절대 외부 공유 금지
