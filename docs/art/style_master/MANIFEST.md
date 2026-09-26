# TINProject Style Master Manifest

상태: **paused — current generator failed Style-Fidelity Gate; 승인된 Style Master 없음**

## 목적

이 manifest는 Generator Style-Fidelity Gate를 통과한 뒤에만 사용할 선택적 전역 Style Master를 관리한다.

Style Master는:
- production 캐릭터가 아니다.
- 특정 Kit의 세계관이나 의상을 소유하지 않는다.
- A/B 원본을 폐기하지 않는다.
- 프로젝트/자산군 Gold Standard를 대체하지 않는다.

## 원본 Style Reference

- A: `docs/research/visual_reference/user_style_A.png`
- B: `docs/research/visual_reference/user_style_B.png`
- 역할과 현재 원본 기록: `docs/research/visual_reference/STYLE_AND_CAMERA_REFERENCE.md`

## 승인 상태

- approved Style Master: **없음**
- 승인 전 후보는 `assets/art/style_master/candidates/`에 둔다.
- 사용자 명시 승인 뒤 승인본을 `assets/art/style_master/approved/`로 옮기고 이 문서에 파일명, 해시, 승인 결정, 적용 범위를 기록한다.

## 생성 전제

`docs/IMAGE_ASSET_WORKFLOW.md` 4절을 따른다.

현재 ChatGPT/OpenAI 이미지 생성 경로는 Round 1에서 원본 A/B 화풍 fidelity를 충분히 재현하지 못했다. 따라서 이 생성기로 Style Master를 만드는 작업은 중지한다. Style Master는 다른 생성기/모델이 원본 A/B Style-Fidelity Gate를 통과한 뒤에만 다시 연다.


## 실행 기록

- Round 1 계획: `docs/art/style_master/CALIBRATION_PLAN_2026-09-26.md`
- Round 1 결과: `docs/art/style_master/CALIBRATION_RESULTS_ROUND_1_2026-09-26.md`
- Round 2 편집 체인: `docs/art/style_master/CALIBRATION_ROUND_2_EDIT_CHAIN_2026-09-26.md` — Style Master 제작이 아니라 현재 생성기의 edit fidelity 진단 기록으로만 유지
- 현재 작업: `docs/research/visual_reference/STYLE_REFERENCE_TOOL_SURVEY_2026-09-26.md`
