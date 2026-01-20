# llama.cpp (CPU) Docker Compose 운영 노트
# 운영 서버 (기존 Docker 서비스 공존 환경) 기준

## 전제
- GPU 없음 (CPU only)
- 기존 Docker 컨테이너 다수 운영 중
- 시스템 패키지 / conda / systemd 사용 안 함
- Dockerfile + docker-compose + deploy.sh 패턴 사용

---

## 1. 작업 디렉토리

cd /home/opc
mkdir -p llm/models
cd llm

---

## 2. 모델 다운로드 (HuggingFace, GGUF)

cd /home/opc/llm/models

# HuggingFace 토큰 (세션 한정)
export HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxxxxxx

# Qwen2.5 Coder 7B Q4_K_M GGUF
wget --header="Authorization: Bearer $HF_TOKEN" \
  -O qwen2.5-coder-7b-instruct-q4_k_m.gguf \
  https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_k_m.gguf

# 확인
ls -lh
# qwen2.5-coder-7b-instruct-q4_k_m.gguf

---

## 3. 디렉토리 구조

/home/opc/llm
- Dockerfile
- docker-compose.yml
- deploy.sh
- models/
  - qwen2.5-coder-7b-instruct-q4_k_m.gguf

---

## 4. Dockerfile (CPU 전용 llama.cpp 빌드)

# /home/opc/llm/Dockerfile

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/ggerganov/llama.cpp.git

WORKDIR /opt/llama.cpp
RUN cmake -B build \
    -DLLAMA_CUDA=OFF \
    -DLLAMA_OPENBLAS=ON \
 && cmake --build build -j$(nproc)

WORKDIR /app

ENTRYPOINT ["/opt/llama.cpp/build/bin/llama-server"]

---

## 5. docker-compose.yml

# /home/opc/llm/docker-compose.yml

version: "3.9"

services:
  llama:
    build: .
    container_name: llama_cpp_server
    restart: unless-stopped

    ports:
      - "11972:8080"

    volumes:
      - ./models:/models:ro

    command:
      - "-m"
      - "/models/qwen2.5-coder-7b-instruct-q4_k_m.gguf"
      - "--host"
      - "0.0.0.0"
      - "--port"
      - "8080"
      - "--threads"
      - "6"
      - "--ctx-size"
      - "4096"

    deploy:
      resources:
        limits:
          cpus: "6.0"
          memory: 24G

---

## 6. deploy.sh (기존 운영 패턴 유지)

# /home/opc/llm/deploy.sh

#!/bin/bash
set -e

echo "== LLM container redeploy =="

docker stop llama_cpp_server || true
docker rm llama_cpp_server || true

docker compose build
docker compose up -d

docker ps | grep llama

# 권한
chmod +x deploy.sh

---

## 7. 실행

cd /home/opc/llm
./deploy.sh

---

## 8. 로그 확인

docker logs -f llama_cpp_server

정상 로그 예시:
llama server listening at http://0.0.0.0:8080

---

## 9. 헬스 체크

curl http://localhost:11972/health

---

## 10. API 테스트 (completion)

curl -X POST http://localhost:11972/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "키가 170 이상이고 몸무게가 80 미만",
    "temperature": 0.1,
    "n_predict": 128
  }'

---

## 11. React 연동

POST http://<SERVER_IP>:11972/completion

프론트엔드 코드 수정 없음 (IP만 변경)

---

## 12. 재배포 / 중단

# 중단
docker stop llama_cpp_server
docker rm llama_cpp_server

# 재배포
cd /home/opc/llm
./deploy.sh

---

## 13. 주의 사항

- ghcr.io/ggerganov/llama.cpp:* 태그 의존하지 않음
- server-cuda-* 이미지 사용 금지 (GPU 전용)
- CPU 서버에서는 Dockerfile 직접 빌드가 정석
- 모델은 반드시 GGUF 형식

---

## 요약

- CPU 기반 llama.cpp는 Dockerfile 빌드로 운영
- docker-compose + deploy.sh 패턴 유지
- 기존 Docker 서비스 무간섭
- 모델 교체 시 models/ 아래 파일만 변경
- 포트 11972 고정
