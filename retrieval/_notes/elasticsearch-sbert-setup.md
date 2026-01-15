# Sentence-BERT + Elasticsearch 설치 및 기본 설정 노트

본 문서는  
Sentence-BERT(SBERT)와 Elasticsearch를 결합한  
의미 기반 검색 실험을 위해 실제로 수행한  
설치 및 초기 설정 과정을 기록한 노트이다.

튜토리얼 목적이 아니라,  
**나중에 동일한 환경을 다시 구성하기 위한 재현용 기록**이다.

---

## 개요

- SBERT: 문장 간 의미 유사도를 측정하는 NLP 모델
- Elasticsearch: 대량 데이터 검색 및 분석에 특화된 검색 엔진

두 기술을 결합하여  
의미 기반 문서 검색 및 분석 시스템 구축을 실험하였다.

---

## 1. Anaconda 설치 및 Python 환경 구성

Anaconda 설치 스크립트 다운로드:

wget https://repo.anaconda.com/archive/Anaconda3-latest-Linux-x86_64.sh

설치 실행:

bash Anaconda3-latest-Linux-x86_64.sh  
source ~/.bashrc

버전 확인:

conda --version  
→ conda 24.5.0

python --version  
→ Python 3.12.4

---

### Anaconda 환경 관리 참고 명령

새 환경 생성:

conda create --name myenv python=3.12.4

환경 활성화:

conda activate myenv

환경 비활성화:

conda deactivate

환경 목록 확인:

conda env list

환경 삭제:

conda remove --name myenv --all

---

## 2. Python 패키지 설치

### transformers

- Hugging Face에서 제공하는 NLP 라이브러리
- BERT, GPT, T5 등 다양한 사전학습 모델 사용 가능

### sentence-transformers

- Sentence-BERT 모델 제공
- 문장을 고정 길이 벡터로 변환하여 유사도 계산에 사용

### mysql-connector-python

- Oracle에서 제공하는 MySQL 공식 Python 드라이버
- 데이터 저장 및 조회용

패키지 설치:

pip install transformers sentence-transformers  
pip install mysql-connector-python

---

## 3. Elasticsearch 저장소 추가

GPG 키 가져오기:

sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

Elasticsearch 리포지토리 설정 파일 생성:

sudo vi /etc/yum.repos.d/elastic.repo

리포지토리 설정 내용:

[elasticsearch-8.x]  
name=Elasticsearch repository for 8.x packages  
baseurl=https://artifacts.elastic.co/packages/8.x/yum  
gpgcheck=1  
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch  
enabled=1  
autorefresh=1  
type=rpm-md  

---

## 4. Elasticsearch 설치 및 실행

환경 설정 파일 생성 및 수정:

sudo vi /etc/elasticsearch/elasticsearch.yml

Elasticsearch 설치:

sudo yum install elasticsearch

Elasticsearch 재시작:

sudo systemctl restart elasticsearch

상태 확인:

sudo systemctl status elasticsearch

로그 확인:

sudo cat /var/log/elasticsearch/elasticsearch.log

9200 포트 확인:

sudo ss -tuln | grep 9200

---

## 5. Elasticsearch 기본 설정 내용

elasticsearch.yml 주요 설정:

network.host: 0.0.0.0  
http.port: 9200  

보안 기능 비활성화 (실험 목적):

xpack.security.enabled: false  
xpack.security.enrollment.enabled: true  

HTTP SSL 비활성화:

xpack.security.http.ssl.enabled: false  

Transport SSL 비활성화:

xpack.security.transport.ssl.enabled: false  

단일 노드 클러스터 설정:

cluster.initial_master_nodes: ["snu"]

---

## 6. Elasticsearch 접속 확인

서버 접속 URL:

http://<서버_IP>:9200

정상 동작 시 아래와 같은 JSON 정보 출력됨:

- node name
- cluster name
- Elasticsearch 버전 (예: 8.15.1)
- Lucene 버전

---

## 7. 기본 검색 테스트

기본 검색 요청 URL:

http://<서버_IP>:9200/<인덱스명>/_search

curl 기반 검색 테스트 예시:

curl -X GET "http://<서버_IP>:9200/<인덱스명>/_search"  
-H "Content-Type: application/json"  
-d '{  
  "query": {  
    "match": {  
      "<필드명>": "<검색어>"  
    }  
  }  
}'

---

## 메모

- Elasticsearch 설치 및 실행 자체는 큰 문제 없이 완료
- 실제 난이도는 이후 임베딩 생성 및 벡터 인덱싱 단계에서 증가
- 본 단계는 검색 인프라 준비 단계에 해당
- 다음 실험 단계에서 SBERT 임베딩 및 chunking 전략을 적용
