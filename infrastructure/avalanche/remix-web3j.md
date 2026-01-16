# 🛠️ Avalanche AvChain 스마트 컨트랙트 배포 및 서버 연동 가이드

이 문서는 Avalanche Subnet(AvChain) 재설치 이후, 스마트 컨트랙트 배포부터 자바 서버 라이브러리(Web3j) 생성 및 연동 과정에서 발생한 이슈와 해결책을 기록합니다.

---

## 1. 스마트 컨트랙트 배포 (Remix & MetaMask)
MetaMask를 AvChain 서브넷에 연결하고, Remix IDE를 통해 관리자(Admin) 계정으로 주요 컨트랙트 4종을 배포 완료하였습니다.

### 배포된 컨트랙트 주소
* **StudyContract**: 0x5DB9A7629912EBF95876228C24A848de0bfB43A9
* **cbrainDAO**: 0x5aa01B3b5877255cE50cc55e8986a7a5fe29C70e
* **did_registrar**: 0x17aB05351fC94a1a67Bf3f56DdbB941aE6c63E25
* **signature_log**: 0x52C84043CD9c865236f11d9Fc9F56aa003c1f922

---

## 2. Web3j Wrapper 클래스 생성 (Java 연동)
스마트 컨트랙트와 자바 서버 간의 통신을 위해 Web3j 라이브러리를 사용하여 Java Wrapper 코드를 생성하였습니다.

### 환경 설정 및 버전업
* **JDK 버전 변경**: Avalanche 최신 버전과의 호환성을 위해 JDK 11 → 17로 업그레이드
* **과정**: Solidity 컴파일(.abi, .bin 생성) → Web3j CLI를 통한 자바 코드 생성

### 클래스 생성 명령어
web3j generate solidity -a CbrainDAO.abi -b CbrainDAO.bin -o ./src/main/java -p org.snubi.crypto.brain.blockchain
web3j generate solidity -a CbrainStudy.abi -b CbrainStudy.bin -o ./src/main/java -p org.snubi.crypto.brain.blockchain
web3j generate solidity -a DidRegistrar.abi -b DidRegistrar.bin -o ./src/main/java -p org.snubi.did.resolver.blockchain
web3j generate solidity -a SignatureLog.abi -b SignatureLog.bin -o ./src/main/java -p org.snubi.did.resolver.blockchain

---

## 3. 서버 엔진 적용 및 테스트 결과
주요 블록체인 관련 서버 7종 중 핵심 서버(1, 4, 5번)를 우선 타겟으로 테스트를 진행하였습니다.

---

## 4. 주요 이슈 및 트러블슈팅 (Critical Issues)

### ⚠️ 이슈 1: Solidity 매핑 데이터 접근 오류
* **현상**: 기존 public mapping 변수가 자동 생성된 Java Wrapper에서 문법 오류 발생.
* **원인**: mapping(address => Document[]) private documents; 구조에서 배열 형태의 값을 외부에서 직접 호출할 때 발생하는 제약.
* **해결**: .sol 파일 수정. 직접 호출 대신 인덱스를 사용하는 Getter 함수(function getDocument(address _owner, uint _index))를 추가하여 재배포.

### ⚠️ 이슈 2: 계정 권한 및 합의 알고리즘 설정
* **현상**: 사용자 계정의 블록체인 쓰기 권한 이슈 발생.
* **원인**: Genesis 파일의 POA(Proof of Authority) vs POS(Proof of Stake) 설정 및 계정 권한 할당 불일치.
* **해결**: Genesis 설정을 다시 확인하고 블록체인을 초기화(Clear) 후 재세팅.

### ⚠️ 이슈 3: 서버 디스크 용량 및 노드 최적화
* **현상**: 서버 용량 부족 경고 (/dev/sda1 70% 점유).
* **해결**: 불필요한 로그 및 캐시 삭제. 시스템 안정성을 위해 기존 5개 노드 구성을 2개 노드로 최적화하여 리소스 확보.

---
