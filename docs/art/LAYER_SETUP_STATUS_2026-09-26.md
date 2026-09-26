# Layer 설정 진행 상태

## 최신 사용자 수정 — A만 사용, 새 컨텍스트의 내장 imagegen

- B 및 B 크롭을 새 생성 입력에서 제외했다. 05 Seedream A는 사용자 화풍 불일치 판정으로 기준 승격 불가.
- A 캐릭터 누끼를 생성(0.1 CU). 서명과 일부 배경 조각이 남아 있어 참조 전처리의 한계로 기록했다.
- 서브에이전트 요청의 취지를 오해하여 기존 컨텍스트를 상속한 Layer GPT Image 2 작업이 먼저 실행됨(실제 5.94 CU). 사용자에게 알리고 별도 이력으로 보존했다.
- 올바른 경로는 fork_turns=none으로 시작한 새 에이전트의 내장 imagegen. A와 필수 인물 내용만 제공하고 부모의 과거 프롬프트/화풍 해석을 전달하지 않았다. 결과 대기 중.

## 최신 — 피드백 대기 없는 자율 실험 04~07

- 사용자 요청으로 후보마다 멈추지 않고 가설·자체 검토·기계 보정을 수행했다. 각 생성 결과 URL을 즉시 공유했다.
- 이번 11.2 CU, 현재 잔액 280.607 CU. 새 네 장은 진단용 보존. 내용 기준 임시 후보는 기존 Nano 02의 좌우반전·여백 보정본이며 스타일 승인 자산은 아니다.
- Seedream A+B에서 B의 잎 장식 누출, 프롬프트 압축 중 바닥 조건 누락, Nano의 과대한 머리/붕대 변형을 기록했다. 자세 누락을 모델만의 실패로 분류하지 않는다.
- [실험 기록](projects/empty_axiom/asset_briefs/mira_model_experiment_2026-09-26.md)에 결과·지출·다음 가설을 남겼다. 새 결제 없음.

## 현재 기준 — Qwen 제외, 두 모델 비교

- 사용자 결정으로 Qwen 계열은 추가 시험·제작에서 제외. 기존 출력도 참조 불가.
- [미라 비교 실험 계획과 결과](projects/empty_axiom/asset_briefs/mira_model_experiment_2026-09-26.md)에 따라 Nano Banana Pro/Seedream 4.5 한 장씩 생성·배경 분리 완료. 이번 5.802 CU, 현재 잔액 291.807 CU. 사용자 품질 평가 대기.
- 두 후보는 실제 알파가 있으나 여백 미달. Nano는 방향 반대, Seedream은 바닥 그림자 잔존. 게임 납품 완료가 아니다.
- 아래 내용은 실행 시점의 이력이다. 과거의 사용자 평가 대기 표기는 현재 승인 상태가 아니다.

## 미라 투명 인물 후보 01 완료

- Qwen Image Edit 2511에 원본 A/B만 입력, 832×1248 한 장 생성 후 BiRefNet v2로 배경 제거 완료.
- 실제 비용: 생성 0.891 CU + 배경 제거 0.1 CU = 0.991 CU. 이전 FLUX 포함 누적 2.391 CU. 추가 구매 없음.
- 결과 `assets/art/empty_axiom/candidates/investigation_characters/mira_stage01_qwen01_cutout.png`; 중간 원본도 같은 폴더에 보존.
- [실행 기록](projects/empty_axiom/asset_briefs/mira_ben_stage01_run_01.json)에 프롬프트·원본 ID·모델·요청 설정·출력·차감액 기록.
- 품질은 사용자 평가 대기. 화면 오른쪽 요청과 달리 왼쪽을 향하며 핀·칼라의 세부 조건도 검토 필요. 최종 게임 자산이나 승인 기준이 아니다. 추가 재생성 없음.

## 사용자 피드백 반영 — Golden Idol 실제 인물로 전환

- 첫 FLUX 결과는 사용자 판정으로 사진풍 화풍 실패. 생성 작업 완료와 품질 승인을 구분하며, 이 출력은 다음 참조로 사용하지 않는다.
- [Stage 1 미라 합성용 명세](projects/empty_axiom/asset_briefs/mira_ben_stage01_cutout.md)를 작성했다. 기존 캐릭터판은 과거 검토용으로 보존한다.
- 실제 투명 PNG, 사건 후 앉은 자세, A/B 역할별 적용·제외, 소품·전경 분리를 명시했다.
- 사용자 결정으로 렌즈집은 미라가 손에 든다. 13E와 인물 명세의 위치 충돌을 해소했다. 카메라·배치 크기와 새 생성 경로는 준비 중. 추가 CU 사용 없음.

## 첫 생성 완료 — 사용자 품질 평가 대기

- 사용자 A/B 원본 업로드 완료. A file_id `b13c3913-552c-43f4-a6d1-adfe0b96cfec`, B file_id `efb33a18-433d-4c17-91bc-80923207934f`. 이번 입력은 A만 사용했다.
- FLUX.1 dev, IP-Adapter 0.45, 1024×1024, medium, batch 1, seed 260926 실행 완료. steps/CFG/sampler는 직접 지정하지 않았다.
- 사전 견적 0.6 CU와 달리 참조를 포함한 실행 견적 및 최종 차감은 1.4 CU. 사용자에게 즉시 알렸다. 생성 시간 약 3분 27초.
- 결과: `assets/art/style_master/candidates/layer_flux_A_2026-09-26.png`. 실행 메타데이터: [LAYER_A_ONLY_2026-09-26.json](style_master/LAYER_A_ONLY_2026-09-26.json).
- inference_id `750a7cb9-ca05-41c8-8748-07984ac94466`, session_id `abbc4e93-dcaf-4540-a4cf-a63f0ce436bf`.
- 품질은 사용자 평가 대기. 승인·Gold Standard 승격·추가 생성 없음. 이번 실행으로 계산한 잔액 298.6 CU.
- 기본 생성→원본 다운로드 경로는 성공했다. 다량 제작의 품질 일관성, 프로젝트 귀속, 고정 설정의 장기 재현성은 아직 완료 판정하지 않는다.

## 최신 재개 — MCP 호출 성공, 원본 업로드 대기

- MCP workspace 조회와 모델 상세 조회 성공. workspace_id: `d1d3c25e-e590-46cb-a6db-2a6eb4673a71`.
- Krea 2 Turbo의 현재 MCP capabilities에는 참조 이미지 입력이 없다. 커뮤니티 스타일 LoRA 구성을 여기서 재현 가능하다고 판단하지 않는다.
- 첫 비교 후보: `flux` (FLUX.1 dev), 원본 A를 `ip_adapter`로 전달, weight 0.45, 1024×1024, quality medium, batch 1. 아직 실행하지 않았다.
- [커뮤니티 직접 비교](https://www.reddit.com/r/StableDiffusion/comments/1f1exbb/flux_ipadapter_img2img_style_transfer_tests_how/)의 IPA 0.5 미만 제안을 초기값 근거로 사용한다. 해당 실험은 ControlNet/Img2Img도 병용했으므로 이번 단독 IPA 시도가 동일한 워크플로 재현은 아니다. 최적값·품질 보장으로 해석하지 않는다. Layer의 adapter 버전도 아직 미확인이다.
- 1024 정사각은 앞서 조사한 2026 커뮤니티 비교와 맞추는 시험 규격이다. medium은 해당 해상도의 비용 제한을 위한 선택, batch 1은 사용자 요청이다. steps/CFG/sampler는 검증되지 않은 값을 임의로 넣지 않는다.
- `estimate_forge_price`: 0.6 CU, 잔액 300 CU, 예상 잔액 299.4 CU, parameters_adjusted=false. 이 MCP 견적 도구는 guidance_files를 인자로 받지 않으므로 실제 참조 처리 성공을 검증한 것은 아니다.
- 업로드 URL 발급 성공 후 공식 안내대로 POST했으나 `MalformedSecurityHeader`로 실패: `x-goog-content-length-range` 헤더 누락. 문서상 64 MiB 상한을 이용한 보완도 `SignatureDoesNotMatch`로 실패했다. 업로드 완료로 취급하지 않는다. 발급 file_id `92c7a63d-c53c-4d01-9f4b-bdd6b708fd2e`는 생성에 사용하지 않는다.
- 브라우저 라이브러리 직접 이동은 성공. 프로젝트 0 items 확인. 사용자에게 `docs/research/visual_reference/user_style_A.png`를 Upload로 업로드하도록 요청했다.
- 생성 0건, 생성 CU 사용 0. 사용자 업로드 후 실제 파일을 확인하고 실행한다.

## 최신 상태 — USD 10 구매 이후

이 절이 아래 과거 진행 기록보다 우선한다.

- 사용자 USD 10 구매 완료 통보. 현재 Layer 화면 잔액 300 CU 확인.
- 추가 구매는 사용자에게 요청한다. 아직 이미지 생성 0건이며 이번 에이전트 작업에서 소비한 생성 CU는 0이다.
- 사용자는 모델과 세부 설정을 커뮤니티 근거로 선정하도록 요구했다. 이전 Gemini 기본 선택은 선정 완료로 취급하지 않는다.
- Codex 전역 MCP `layer`를 `https://mcp.app.layer.ai/mcp`에 등록했고 OAuth 명령은 `Successfully logged in.`으로 종료됐다. 현재 대화의 callable tools에는 Layer가 아직 없다. 인증 성공과 실제 MCP 호출 성공은 별개다.
- 브라우저 모델 목록 클릭이 시간 초과됐고, 화면에 존재하는 목록 URL 직접 이동도 30초 시간 초과로 제어 세션이 초기화됐다. 실제 모델 설정·참조 복구·생성은 미완료다.

### 설정 근거와 적용 제한

- [커뮤니티 직접 비교](https://www.reddit.com/r/comfyui/comments/1wfdyqv/style_transfer_capabilities_of_different/): 1024×1024, 짧은 대상 묘사, 일부 best-of-3–5 결과다. 결과를 첫 시도 성공률로 해석하지 않는다. Krea 2의 좋은 사례는 별도 스타일 참조 LoRA를 붙인 구성이다.
- [LoRA 제작자 명세](https://huggingface.co/ostris/krea2_turbo_style_reference): Krea 2 Turbo 기반, 1–2 참조 이미지, 전용 ComfyUI 노드 또는 커스텀 Diffusers 파이프라인이 필요하다. 별도 trigger word는 없다. Layer의 기본 Krea 2를 이 구성과 동일시하지 않는다.
- [Layer Krea 2 Turbo 명세](https://layer.ai/docs/models/krea-krea-2-turbo): 실제 작업공간에서 참조·LoRA 지원 여부와 노출된 설정을 추가 확인해야 한다. 미확인 CFG·sampler·steps 값을 임의로 채우지 않는다.
- [Layer MCP 안내](https://layer.ai/docs/mcp/setup): 도구 로드 후 모델 상세와 작업 지침을 읽고 예상 CU를 조회한 다음 실행한다.
- 초기 비교는 원본 A 한 장으로 인물 한 장만 만든다. 이는 기존 프로젝트 비교 계획 및 비용 제한에 따른 선택이며, 커뮤니티가 입증한 최적값이라고 주장하지 않는다. 이미지 품질 판정은 사용자에게 맡긴다.

### 재개 지점

Codex의 MCP 도구 로드를 복구한 뒤 Layer 지침 → 작업공간/모델 목록 → 지원 참조 기능/설정 → 비용 견적 순서로 확인한다. 모델이 선정되기 전 Gemini 초안을 제출하지 않는다. 기존 생성물은 참조로 재사용하지 않는다.

## 사용자 조건

- 총 예산 50,000원. 무료 범위를 먼저 사용한다.
- 결제가 필요하면 사용자에게 금액과 용도를 알리고 기다린다.
- 작은 문제도 즉시 알린다.
- 이미지 품질은 사용자만 평가한다.

## 완료

- 프로젝트: TIN Art Production
- URL: https://layer.ai/innollia?project=c3bc5f4b-050b-426b-bd9c-9c22dc96b923
- 잘못 입력된 이름 끝 문자를 수정하고 Project updated 알림 확인.
- 사용자 탭의 Agent 입력에 user_style_A.png 첨부 확인.
- 이미지 모드 기본값: Gemini 3.1 Flash Image / 1:1 / 1K / batch 1 / 예상 2 CU.

## 비용 및 제약

- 화면상 잔액 0 CU. 이번 작업 결제 0원, 생성 실행 없음.
- Earn Free Units 화면은 보상 수령에 최소 1회 units 구매가 필요하다고 명시한다.
- 독립적인 무료 생성 경로 존재 여부는 아직 미확인.
- 파일 선택창은 사용자가 처리한다.
- 브라우저 클릭·DOM 입력·상태 조회에서 반복 시간 초과. 마지막 조회는 30초 후 세션 초기화.
- 마지막 텍스트 입력은 실패로 반환됐으며 실제 반영 여부 미확인. 제출하지 않았다.

## 다음 작업

브라우저 연결 복구 후 사용자 탭에서 첨부를 유지한다. 아래 요청의 입력 여부를 확인한 뒤 무료 준비만 실행한다. 결제·학습·유료 생성은 실행하지 않는다. 품질 판정 전 후보를 승인 상태로 바꾸지 않는다.

### 준비 요청 초안

Prepare a reusable image-generation draft in this project using attached user_style_A.png as a STYLE reference only. First test: one new adult woman, shoulder-length black hair, plain muted ochre work jacket and light neutral inner shirt, waist-up three-quarter view, one hand visible, quiet expression, simple background planes. Preserve the reference painting treatment without copying its character, outfit, pose, hearts or stars. Create only setup/drafts that cost 0 CU. Do not generate images, train, run paid tools, purchase units, or start subscriptions. Tell me whether any genuine free generation is available at a 0 CU balance without a purchase; otherwise report the minimum cost and leave the draft ready. The user alone evaluates image quality.

## 미완료

참조를 사용한 생성, 결과 다운로드, 반복 제작 설정은 아직 실행·확인하지 못했다. 프로젝트 생성과 첨부만으로 실제 제작 준비 완료라고 선언하지 않는다.

## 재개 결과

- A 원본이 Image 모드 @Reference1에 지정된 상태를 확인했다.
- 비교 프롬프트 입력 성공. Gemini 3.1 Flash Image / 3:4 / 1K / 1장 / 예상 2 CU.
- 잔액 0 CU로 Forge 비활성. 생성은 실행하지 않았다.
- 최소 일회성 구매: 300 CU / USD 10 / workspace당 1회 / 자동 갱신 없음. 세금·환전·카드 수수료 미확인. 구매하지 않았다.
- 페이지 이동 시 미제출 프롬프트와 참조 선택이 초기화됐다. 프롬프트는 다시 입력했으나 참조 재선택 미완료.
- 라이브러리 초기 필터에서 0건 표시. 필터 해제 중 브라우저 제어가 다시 시간 초과되어 원본의 라이브러리 보존 여부 미확인.
- 결제 0원, 이미지 생성 0건. 비용 승인 또는 다른 무료 서비스 경로 선택 전 유료 실행하지 않는다.
