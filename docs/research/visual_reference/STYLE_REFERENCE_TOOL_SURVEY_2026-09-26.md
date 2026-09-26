# Style Reference Tool Survey — 2026-09-26

상태: **active — current ChatGPT/OpenAI path failed direct style-fidelity test**

목적: TIN의 A/B 원본 그림체를 새 피사체에서도 실제로 유지할 수 있는 생성기를 찾는다. Style Master/Gold Standard는 이 문제를 해결하는 수단으로 사용하지 않는다. 먼저 생성기 자체가 원본 reference fidelity를 증명해야 한다.

## 현재 판정

### ChatGPT / current OpenAI image generation path

실측:
- A-only, B-only, A+B fresh generation 모두 원본 화풍을 충분히 따라하지 못했다.
- 결과가 일반적인 고품질 애니/콘셉트 아트 prior로 수렴했다.

결론:
- 현 상태에서는 style-critical production 생성기로 사용하지 않는다.
- 추가 Style Master나 Gold Standard를 같은 생성기로 만들어도 fidelity 해결 근거가 없으므로 중지한다.
- reference-preserving edit 진단은 별도 기록으로만 남긴다.

## 다음 검증 순서

### 1. Flux Kontext — 현재 ChatGPT 안에서 바로 시험 가능

현재 연결된 Higgsfield 모델 카탈로그에서:
- 모델: `flux_kontext`
- 제공자: Black Forest Labs
- 설명: `Context-aware editing and style transfer`
- 이미지 reference 입력 지원
- 1:1 / 4:3 / 3:4 / 16:9 / 9:16 지원

선정 이유:
- 현재 환경에서 바로 사용할 수 있고
- 모델 자체가 style transfer를 명시적으로 기능 범위에 포함한다.
- 먼저 A/B 각각에 대해 동일한 중립 피사체 style-transfer와 source-preserving edit를 시험한다.

통과 기준:
- A/B의 렌더링 과정이 원본과 같은 계열로 보일 것.
- 단순한 색/무드 유사성만으로 통과시키지 않는다.

### 2. Midjourney Style Reference

공식 기능:
- 업로드 이미지를 전용 Style Reference로 지정 가능
- `--sw`로 style reference 영향도를 0–1000 범위에서 조절
- `--sv`로 style-reference 해석 버전을 바꿔 비교 가능
- 여러 Style Reference에 개별 weight 지정 가능
- 공식 문서는 text prompt를 단순하게 유지하고 style words 충돌을 피하라고 권함
- Edit Model과 Style Reference를 함께 사용할 수 있음

출처:
- https://docs.midjourney.com/hc/en-us/articles/32180011136653-Style-Reference
- https://docs.midjourney.com/hc/en-us/articles/48495453462797-Edit-Model

TIN 시험:
- A-only: 낮은 text 개입, `--sw` sweep
- B-only: 동일
- A+B: reference별 weight를 분리해 sweep
- `--sv`도 별도 비교
- 최소한의 subject prompt만 사용

현재 OpenAI 경로와 달리 **style influence를 직접 조절할 수 있다는 점**을 검증 가치로 본다.

### 3. Ideogram Custom Style

공식 기능:
- 최대 3개의 reference image로 reusable custom style 생성
- 공식 팁은 Magic Prompt를 끄고 짧고 집중된 프롬프트 사용
- Style Reference와 Character Reference를 결합 가능
- Remix weight로 원본 composition과 style 영향 사이를 조절 가능

출처:
- https://docs.ideogram.ai/using-ideogram/features-and-tools/reference-features/style-reference

TIN 시험:
- A 하나만으로 custom style
- B 하나만으로 custom style
- A+B 두 장으로 custom style
- Magic Prompt off
- 동일 중립 피사체로 비교

### 4. Adobe Firefly Style Reference

공식 기능:
- 업로드 이미지를 Style Reference로 지정
- Style Reference의 **Strength slider**로 reference adherence를 직접 조절
- Composition Reference에도 별도 Strength가 있어 스타일과 구도를 분리할 수 있음

출처:
- https://helpx.adobe.com/firefly/web/work-with-images/generate-images/set-styles-for-image-generation.html
- https://helpx.adobe.com/firefly/web/work-with-images/generate-images/match-image-composition-to-reference-image.html

TIN 시험:
- Style strength를 높은 쪽부터 sweep
- composition reference는 끈 상태와 분리해서 검증
- content prompt는 중립 피사체만 기술

## 공통 테스트 프로토콜

모든 생성기에 같은 세 테스트를 사용한다.

1. **A-transfer** — A를 style reference, 동일 중립 피사체
2. **B-transfer** — B를 style reference, 동일 중립 피사체
3. **edit-preserve** — 원본에서 색 하나만 바꾸고 나머지 렌더링 보존

A/B 둘을 한 번에 섞는 것은 각 단독 fidelity가 확인된 뒤에만 한다.

## 공통 판정 축

- facial plane construction
- structural-line pressure/weight/breaks
- brush scale and direction
- hair-mass rendering
- foreground/background density hierarchy
- source motif leakage
- generic-anime prior regression

각 항목은 `pass / partial / fail`과 한 줄 관찰만 기록한다.

## 중단 규칙

두 번의 설정 sweep 안에서 단독 A 또는 B조차 충분히 따라하지 못하면:
- 그 도구에서 prompt engineering을 더 길게 하지 않는다.
- Style Master/Gold Standard를 만들지 않는다.
- 다음 도구로 넘어간다.

## Style Master / Gold Standard 재개 조건

도구 하나가 최소:
- A-transfer 또는 B-transfer에서 원본 화풍 fidelity 통과
- edit-preserve에서도 통과

를 만족해야 한다.

그 뒤에만:
- A/B 결합 실험
- 선택적 Style Master
- 자산군 Gold Standard
- production asset

순으로 진행한다.
