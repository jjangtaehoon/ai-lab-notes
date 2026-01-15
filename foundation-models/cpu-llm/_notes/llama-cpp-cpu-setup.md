# CPU 기반 LLM 실험 환경 구축 메모 (llama.cpp)

이 문서는  
GPU 없는 공용 서버 환경에서 CPU 기반 LLM 추론 실험을 진행하며  
실제로 사용했던 설정, 명령어, 운영 규칙을 **잊지 않기 위한 개인 기록용 노트**이다.

공식 가이드나 재현용 문서가 아니며,  
환경에 따라 그대로 적용되지 않을 수 있다.

---

## 개요

- 모델: Qwen2.5-Coder-7B-Instruct (GGUF)
- 실행 엔진: llama.cpp
- 실행 방식:
  - llama-cli (CLI)
  - llama-server (HTTP)
  - Python subprocess

모델만 교체하면  
Qwen / LLaMA / Mistral / Gemma 등으로 확장 가능하며,  
**실행 구조는 동일하게 유지**된다.

---

## 실험 환경 제약

- GPU 없음
- CentOS 7 (공용 서버)
- 시스템 gcc: 4.8.5 (C++17 미지원)
- 전역 gcc 업그레이드 불가
- CPU/메모리 여유:
  - Xeon Gold 6240 ×2
  - RAM 503GB

→ **llama.cpp + GGUF 양자화 모델이 가장 현실적인 선택**

---

## 모델 선택 기준 (고정)

- 포맷: GGUF
- 양자화: Q4
- 크기: 7B
- Instruct 튜닝 모델

| 구분 | 3B | 7B | 13B |
|---|---|---|---|
| CPU 추론 | 빠름 | 적절 | 느림 |
| 메모리 | 4~5GB | 8~10GB | 16~20GB |
| 실험 기준 | ❌ | ⭕ | △ |

→ **7B Q4를 기준 모델로 고정**

---



빌드 전략 (중요)

시스템 gcc 사용 불가

전역 환경 변경 금지

conda 환경 내부에서만 컴파일

conda 기반 빌드 메모
llama 전용 환경
conda create -n llama-cpp python=3.10 -y
conda activate llama-cpp

conda 환경 내 컴파일러 설치
conda install -c conda-forge gcc_linux-64 gxx_linux-64 cmake make -y


gcc 확인:

gcc --version
# x86_64-conda-linux-gnu-gcc

llama.cpp 빌드
cd /data3/jjang/2026/llm
git clone https://github.com/ggerganov/llama.cpp

cd llama.cpp
rm -rf build
mkdir build
cd build

cmake .. \
 -DCMAKE_C_COMPILER=x86_64-conda-linux-gnu-gcc \
 -DCMAKE_CXX_COMPILER=x86_64-conda-linux-gnu-g++

make -j72


빌드 결과 확인:

ls bin
# llama-cli
# llama-server

실행 파일 위치
/data3/jjang/2026/llm/llama.cpp/build/bin/llama-cli
/data3/jjang/2026/llm/llama.cpp/build/bin/llama-server


동작 확인:

llama-cli --help


※ 정상 출력되지 않으면 이후 단계 진행 불가

PATH 설정 (선택)

공용 서버이므로 전역 PATH 설정은 지양
conda 환경에서만 사용 권장

export PATH=/data3/jjang/2026/llm/llama.cpp/build/bin:$PATH

모델 다운로드 메모

모델 저장 위치:

/data3/jjang/2026/llm/models


HuggingFace에서 GGUF 모델 다운로드

토큰은 세션에서만 사용, 문서에 저장하지 않음

export HF_TOKEN=********
wget --header="Authorization: Bearer $HF_TOKEN" \
 -O qwen2.5-coder-7b-instruct-q4_k_m.gguf \
 https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_k_m.gguf

실행 예시
CLI
llama-cli \
 -m /data3/jjang/2026/llm/models/qwen2.5-coder-7b-instruct-q4_k_m.gguf \
 -t 24 --ctx-size 4096 --temp 0.6 \
 -p "너는 한국어로만 답변하는 AI 어시스턴트다."

서버 실행
llama-server \
 -m /data3/jjang/2026/llm/models/qwen2.5-coder-7b-instruct-q4_k_m.gguf \
 --host 0.0.0.0 --port 11972 \
 --ctx-size 4096 --threads 24

운영 메모

LLM은 필요할 때만 실행

실행 중에만 CPU/메모리 점유

종료 시 자원 즉시 반환

프로세스 확인:

ps -ef | grep llama


종료:

kill <PID>
kill -9 <PID>   # 강제 종료

현재 상태 요약

전역 환경 영향 없음

conda 환경 내부에서만 gcc / CMake / llama.cpp 사용

빌드 및 실행 경로 명확

실행/종료 기준 명확

공용 서버에서 안전하게 실험 가능
