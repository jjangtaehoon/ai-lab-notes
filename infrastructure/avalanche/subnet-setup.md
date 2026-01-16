# 🚀 Avalanche (AvChain) 네트워크 재설정 및 개발 환경 구축 보고서

## 📌 목표
Ubuntu 서버 재설정 → Avalanche 네트워크 재구동 → RPC 연결 확인 → MetaMask 연동 → Remix 배포 환경 구축

---

## 1. Ubuntu 환경 정리 및 업데이트
* 인스턴스 정보: Oracle Cloud (Public IP: *.*.*.*, Region: ap-chuncheon-1)
* OS 유지보수: 
    - Ubuntu OS 업그레이드 및 SSH 재접속 이슈 해결 (Atom3 접속 오류 등)
* 보안 설정:
    - ufw 방화벽 재설정 및 Avalanche 필수 포트 오픈 (9650, 9651, 37841 등)
* 필수 패키지 설치: curl, git, lsof, nc 등 재설치 완료

---

## 2. Avalanche CLI 및 네트워크 환경 복원
* 작업 디렉토리 통일: /home/ubuntu/.avalanche-cli 기준으로 폴더 정리
* 버전 확인: avalanche-cli 최신 버전 (v1.13.5) 확인
* 네트워크 초기화 및 생성:
    - 기존 run directory 정리 후 새 로컬 네트워크 생성
    - avalanche network start 또는 avalanche blockchain deploy avchain --local 실행
* avchain 서브넷 정보:
    - ChainID: 1234567003
    - RPC Port: 37841
    - VM ID: jvYm5w8Jo4vvr2UVziBvCcfVp1tiUUFMqCrghqLoisPDvvGJi
    - 기본 계정: 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC

---

## 3. Config 정비 및 외부 연결 설정
* 설정 파일 수정 (~/.avalanche-cli/local/.../NodeID-GZ9.../config.json):
    - http-host: "0.0.0.0"
    - public-ip: "*.*.*.*"
    - http-allowed-hosts: "*"
    - http-allowed-origins: "*"
* 상태 점검:
    - 프로세스 확인: ps -ef | grep node
    - 포트 리스닝 확인: sudo lsof -i:37841
* 접근 테스트:
    - 내부(127.0.0.1) 및 외부(*.*.*.*) 정상 응답 확인

---

## 4. RPC 통신 및 MetaMask 연동
* JSON-RPC 테스트: eth_blockNumber, eth_chainId 정상 응답 확인
* Chain ID 확인: 0x4995ff5b → 십진수 변환 시 1234546267
* MetaMask 네트워크 설정:
    - Network Name: avchain
    - New RPC URL: http://*.*.*.*:37841/ext/bc/thttMuFWr7FJx4wyiqtxdhh3nCEeAmqxsEy4mKjR4habNuShv/rpc
    - Chain ID: 1234546267
    - Currency Symbol: AvC

---

## 5. Remix 개발 환경 재구성
* 접속 및 인증: https://remix.ethereum.org 접속 및 GitHub (avchain-inc 계정) 연동
* 컴파일: AvchainTest.sol 생성 및 Solidity 컴파일 완료
* 배포 설정:
    - Environment: Injected Provider - MetaMask 선택
    - 네트워크 확인: avchain (ChainID: 1234546267) 연동 확인
* 배포 테스트: MetaMask 서명 후 컨트랙트 배포 완료 및 eth_getCode 통신 확인



