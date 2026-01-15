# AI 시스템 실험 로그 (AI Systems Experiment Log)

이 저장소는 개인적으로 진행해온 **AI 시스템 실험 기록**을 정리한 공간입니다.  
모델 성능이나 데모 구현이 아니라, **AI를 실제 시스템에 적용했을 때 어디까지 자동화가 가능하고, 어디서 반드시 통제와 사람이 개입해야 하는지**를 기록하는 것을 목표로 합니다.

AI를 하나의 지능이 아니라,  
**보안·운영·책임이 필요한 시스템 구성 요소**로 다루며 얻은 판단과 한계를 남기는 기술 실험 로그에 가깝습니다.

---

## 이 저장소의 관점

- AI 모델을 맹신하지 않습니다  
- LLM은 결정을 대신하는 존재가 아니라 **사고를 보조하는 도구**입니다  
- 결과보다 **과정, 실패 지점, 판단 근거**를 더 중요하게 봅니다  
- “된다”보다 **“어디서 깨지는가”**를 먼저 기록합니다  
- AI는 독립적인 지능이 아니라 **통제되어야 할 시스템 컴포넌트**라고 봅니다  

---

## 다루는 영역 (Scope)

이 저장소의 실험은 **AI 시스템 전반을 보안·운영 관점에서 다루는 것**에 초점을 둡니다.

### Foundation Models  
AI 시스템의 기반 모델 계층  
- LLMs / Multimodal Models  
- Inference Isolation  

### Retrieval  
지식과 AI를 연결하는 구조  
- RAG  
- Vector Search  
- Subset / Context Extraction  

### Reasoning  
AI의 사고와 추론 메커니즘  
- Chain-of-Thought  
- Tool-based Reasoning  

### Agentic AI  
자율적으로 행동하는 AI 구조  
- Agents & Actions  
- Secure Execution Pod  

### Infrastructure  
AI 시스템 운영 인프라  
- Kubernetes  
- Ephemeral / One-shot Pod  
- GPU Scheduling  

### Security  
AI 사용을 위한 보안 체계  
- Encryption  
- Network / Context Isolation  
- Zero Trust Architecture  

### Evaluation & Governance  
AI 성능과 신뢰성, 책임 구조  
- Evals & Reproducibility  
- Execution Proof  
- Auditability & Accountability  

---

## 실험 기록 방식

각 실험은 보통 다음을 포함합니다.

- 실험을 하게 된 실제 문제 상황  
- 선택한 구조나 도구의 이유  
- 시스템에 어떻게 연결했는지  
- 예상과 달랐던 결과, 한계  
- 모델이 처리하지 못해 사람이 개입해야 했던 지점  

코드의 양이나 완성도보다는,  
**왜 이런 판단을 했고 어디서 문제가 발생했는지**가 드러나는 기록을 남기는 데 집중합니다.

---

## 참고 사항

- 본 저장소는 개인적인 기술 실험 기록입니다.  
- 재직 중인 회사나 기관의 프로젝트, 소스 코드, 데이터와는 무관합니다.  
- 실험 내용은 진행 과정에 따라 수정·추가될 수 있습니다.
