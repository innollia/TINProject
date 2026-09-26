# 14 — 독립 제작 작업과 입력 완결성

2026-09-26 사용자 요청: 서브에이전트를 쓰는 경우 이미지까지 격리하고, 명세가 불명확하면 RPG 문서를 먼저 구체화한다. 이 문서는 작업 소유권·입력 전달·결과 보존을 정의한다. OS sandbox나 별도 Git checkout이 생성됐다고 주장하지 않는다.

## 1. 현재 실행 범위

- 이번 문서 감사 작업자는 `docs/reviews/rpg_spec_revision_2026_09_26/spatial/`, `art/`, `content/`에만 쓴다.
- 정본 계획·프로젝트 아트 층·brief 병합은 root 한 명이 한다. 감사자는 정본과 런타임을 수정하지 않는다.
- 감사 작업의 대화 이력은 공유될 수 있다. 실제 이미지 제작자는 새 작업을 시작할 때 필요한 자료만 받는 별도 컨텍스트로 시작한다.
- 아직 생성기 화풍 검증이 통과하지 않았으므로 새 장면 이미지는 생성하지 않는다. 기존 실패 이미지는 입력 후보에서 제외한다.
- 2026-09-26 사용자 결정: 판정을 기다리던 생성형 도구 화풍 시험은 전부 불합격이다. 코드로 그린 그림(아이콘 조합, 도트, SVG/Pillow 절차 그림)은 최종 그림으로 허용되므로 위 생성 금지 줄의 대상이 아니다. 코드 그림 job도 §2 구조를 쓰며, prompt.txt 대신 그림을 만든 스크립트·SVG 원본을 결과 옆에 둔다.
- 기술적인 배치도/카메라 도면은 미술 완성본이 아니다. 생성기 테스트나 레이아웃 전달용 입력으로만 명시한다.

## 2. 제작 job 파일 구조

실제 job이 착수할 때만 해당 디렉터리를 만든다. 아래는 구조 명세이며 빈 폴더를 일괄 생성하지 않는다.

```text
docs/art/projects/top_down_action_rpg/jobs/<job_id>/
  JOB.md
  inputs.json
  prompt.txt
  QA.md
assets/art/top_down_action_rpg/jobs/<job_id>/
  input/
  output/
  preview/
```

- `job_id`: 자산/지역/버전이 드러나는 고유 이름. 예: `h0-arrival-layout-v02`.
- `input/`: 이 job에 명시된 reference의 사본과 구도 가이드. 읽기 전용으로 취급한다.
- `output/`: 해당 job의 실제 생성 결과와 기계 처리 산출물. 다른 job 파일을 덮어쓰지 않는다.
- `preview/`: 재합성·비교·격자/경로 overlay 등 검수용 그림. 생산 이미지와 섞지 않는다.
- 기본 생성 도구가 공용 generated_images 위치에 저장하면 반환된 **정확한 파일 경로**를 job output에 복사하고 출처를 남긴다. 다른 job의 최근 파일을 폴더 날짜순으로 골라 가져오지 않는다.
- 기존 후보 파일의 경로/픽셀은 유지하며 QA에서 `rejected`로 표시한다. 새 job의 input manifest에 넣지 않는다.

## 3. JOB.md 필수 내용

| 필드 | 확정해야 하는 값 |
|---|---|
| 목적 | layout_guide / generator_calibration / environment_master / clean_base / prop / occluder / state_variant 중 하나 |
| 소유권 | 담당 작업자, 쓸 수 있는 정확한 job 폴더, 정본 수정 불가 |
| 자산 identity | region/area/asset ID. 실제 domain ID와 새 미술 설계 ID를 구분 |
| 입력 계약 버전 | 적용 계획·art layer·brief의 버전과 파일 hash |
| 카메라 | 지면 기준 60° 정사영, 고정 방위, ground/height/투영 후 좌표 구분 |
| 입력 이미지 | 절대 경로, SHA-256, 역할, 사용 허용 범위 |
| 필요한 결과 | 개수, 크기, alpha, source density, pivot/origin, layer, 파일명 |
| 내용 고정 | 보여야 하는 물체, 위치, silhouette, 중요도, 상태 |
| 금지 | 내용 복제/불필요 장식/반려 그림/글자 굽기 등 실제 해당 항목 |
| 수정 범위 | 편집 target와 보존 영역, 바꿀 요소 하나 또는 명시된 묶음 |
| 승인 상태 | 원본 입력/approved 기준/candidate/rejected를 서로 구분 |
| 검수 항목 | 구도·화풍·기술·state를 각각 pass/partial/fail/not_run |
| 중단 이유 | 누락 input의 정확한 이름과 그것 없이는 결정할 수 없는 내용 |

`제작자가 알아서`, `기획서 분위기에 맞게`, `예쁘게`는 누락값을 대신하지 않는다. 작업자에게 전체 저장소를 검색해 취향을 추정하라고 보내지 않는다.

## 4. 입력 이미지 규칙

1. style A: 명암 면·형태/재질을 따르는 내부 붓결. 얼굴 없는 환경에도 해당 역할 적용.
2. style B: 유색 구조선의 강약·끊김, silhouette 정리, 밀도 계층·배경 평면 겹침.
3. layout guide: 시점·ground plane·배치·통로만. 색·화풍의 권위로 삼지 않는다.
4. edit target: 실제 바꿀 이미지 한 장. style reference와 구분한다.
5. Gold Standard: 그 자산군에서 사용자가 승인한 경우만. 0개면 없음이라고 명시.
6. 반려된 H0 master/이전 atlas/다른 job의 후보는 style input이 아니다.

A/B의 두 입력이 단지 존재한다고 충분하지 않다. 요청 tool이 각각 style/composition/edit 역할을 실제로 지원하는지 적는다. 전용 강도 제어가 없는 도구에 임의의 weight 숫자를 넣고 적용됐다고 주장하지 않는다. 참조 fidelity 검증은 공통 workflow를 따른다.

사용자가 이번 대화에서 지정한 `docs/research/visual_reference/user_style_A.png`는 유효한 입력이다. 과거 문서의 다른 해시와 비교하여, 실제 화상 차이를 확인하지 않은 채 '원본 불명확'이라고 차단하지 않는다. hash는 읽은 사본 식별과 재현에 쓴다.

## 5. 컨텍스트와 결과 격리

- 실제 생성 worker는 현재 job brief와 고정 입력만 받는다. 다른 worker 출력물을 자동 참조하지 않는다.
- image tool에는 manifest의 명시적 이미지 경로만 전달한다. 최신 대화 이미지 N장 포함 기능을 사용해 다른 후보가 섞이게 하지 않는다.
- 서로 다른 job의 prompts, image bytes, temp masks, preview를 같은 이름/폴더에 덮어쓰지 않는다.
- 생성기가 이전 대화 기억을 학습했다고 가정하지 않는다. 각 요청은 독립적으로 필요한 원본을 전달한다.
- 보고는 job ID, 정확한 파일, 실제 크기/알파, 검수 결과, 실패 이유를 반환한다. 원본 도구 경로도 보존한다.
- 다른 작업자의 결과를 참조해야 할 때는 root가 승인 상태·역할·버전을 명시한 새 input manifest를 만든다. 단순히 '가장 최근 그림을 따라' 하지 않는다.

## 6. 입력 준비와 이미지 승인 구분

| 상태 | 뜻 | 다음 행동 |
|---|---|---|
| spec_incomplete | 필수 위치·identity·state·출처 중 값이 없음 | 문서를 구체화. 생성 금지 |
| spec_ready | 필요한 값과 출처가 명시됨 | 도구/화풍 검증 상태 확인 |
| generator_unqualified | 원본 화풍 재현/보존 증거 없음 또는 실패 | 공통 workflow의 도구 검증. production 생성 금지 |
| ready_for_sample | spec_ready + generator 검증 통과 | 샘플 1개 생성·검수 |
| candidate | 실제 출력이 있으나 미승인 | 기술/화풍/구도/의미 검수 |
| rejected | 명세 또는 화풍 미달 | 파일 보존, 후속 style input 제외 |
| user_review | 검수 증거와 함께 사용자에게 제시 | 사용자 판정 대기, 양산 금지 |
| approved | 사용자가 명시적으로 승인한 범위 | 승인 범위 안에서만 사용/후속 병렬 제작 |

이 상태들은 제작 추적용이며 domain save에 추가하지 않는다. spec_ready를 '게임 구현 준비 전부 완료'로 확대하지 않는다.

## 7. 실제 수정과 아이디어의 출처

- **사용자 결정:** 60° 카메라, 큰 배경과 분리 레이어, A/B 역할, 샘플 선행, 내용/분량 조건.
- **기존 기획 사실:** 지역·NPC·event·state ID와 기능. 정본 경로/절을 적는다.
- **작성자 설계:** 지금 구체화한 재질·배치·치수·레이어 경계. 사용자에게서 나온 값처럼 쓰지 않는다.
- **미해결:** 제작을 바꾸는 값이 아직 없음. 이유와 책임 문서를 적는다.

작성자 설계는 검토 가능한 구체안으로 작성한다. 모든 값을 '추후 결정'으로 남기거나, 반대로 빈칸을 모델이 추측하도록 넘기지 않는다. 사용자 취향을 바꾸는 선택과 routine 제작 치수 선택을 구분한다.

## 8. 전달 전 확인

- 입력 경로가 실제로 열리는가.
- 필요한 A/B의 역할과 파일이 일치하는가.
- 60°를 90° 수직으로 바꾼 과거 prompt가 섞이지 않았는가.
- 구도와 camera/footprint/높이 기준이 함께 있는가.
- 제거 물체 뒤의 clean base와 shadow 소유자가 정해졌는가.
- state token·event/prop ID와 그림 변화가 연결됐는가.
- 출력의 alpha/피벗/캔버스와 source pixel 크기가 명시됐는가.
- generatedImage 출력 또는 복사한 파일만 있는지, 실제 검수까지 한 것인지 구분했는가.
- 사용자 검토 전 병렬 양산이나 승인 승격을 하지 않았는가.

## 9. 변경된 명세의 전달

문서 개정 중 다른 worker가 이전 버전을 구현하고 있을 수 있다. root는 변경된 계약과 필요한 후속 확인을 정본에 기록한다. 이 문서 변경 자체를 기존 runtime/content가 자동으로 따랐다고 보고하지 않는다. 별도 사용자 소유 대화에 메시지를 보내는 것은 추가 권한 없이 수행하지 않는다.
