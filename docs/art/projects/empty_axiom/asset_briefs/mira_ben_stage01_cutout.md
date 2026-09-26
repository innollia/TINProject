# Stage 1 미라 벤 — 조사 화면 합성용 인물

자산 ID: `mira_ben_stage01_injured_cutout`
자산군: `investigation_characters`
상태: **실제 자산 용도의 모델 비교 후보 제작 — 사용자 화풍 평가 대기**
목적: 《빈 공리》 Stage 1 지역 A의 실험대 아래 인물에 사용할 투명 PNG. 새 도구의 최초 출력도 이 실제 자산 용도에서 사용자에게 평가받는다. 아직 게임 사용 승인이나 화풍 게이트 통과가 아니다.

## 정본과 발견한 문제

- `docs/golden_idol_story/`의 01 「눈을 고친 사람」: 지역 A 쿼터뷰, 실험대 아래 반쯤 기대어 앉은 미라, 양눈 붕대, 녹색 소매의 소독약 자국. 지역 설명은 렌즈집을 한 손에 든다고 적는다.
- 같은 export의 13A-1: 26세, 마른 체형·좁은 어깨, 짧은 갈색 보브, 왼귀 뒤 평행 은핀 두 개, 잎녹 니트·크림 칼라·낡은 백색 가운·낮은 검은 끈구두.
- 13A-4: 사건 후 붕대 범위 및 오른손 소독도구 접촉 상태의 연속성 유지.
- 2026-09-26 사용자 결정: 렌즈집은 미라가 손에 든다. 13E의 바닥 배치를 이 결정으로 수정했다. 소독도구는 기존 정본대로 오른손이 닿는 쪽에 둔다. 렌즈집을 쥐는 좌우 손은 사용자 확정값이 아니며 오른손 접촉 상태와 함께 포즈에서 정한다.
- 이전 검토판의 사건 전·불투명 배경·확대 컷은 이 자산의 입력이 아니다.
- 프로젝트 화풍은 [프로젝트 아트 층](../PROJECT_ART_LAYER.md)과 [개인 코어](../../../PERSONAL_STYLE_CORE.md) 0.2를 따른다.

## 납품 계약

| 항목 | 요구 |
|---|---|
| 내용 | 미라 1명, 부상 후 앉은 자세, 머리부터 양 신발까지 누락 없는 단일 실루엣 |
| 배경 | 실제 투명 알파. 실험대·벽·바닥·콜라주·낙하 그림자 없음 |
| 포맷 | PNG RGBA, sRGB, 단일 인물 레이어 |
| 제작 캔버스 | 모델 비교 약 1MP 세로 규격: Gemini 848×1264, Seedream 832×1248. 최종 게임 배치 크기는 미승인 |
| 여백 | 머리·발·손·핀을 자르지 않으며 사방 최소 5% 제안 |
| 피벗 | 앉은 몸의 바닥 접촉 중심. 정확한 픽셀 좌표는 승인 포즈 후 기록 |
| 가림 | 책상은 별도 전경 레이어로 가린다. 인물에 책상 조각을 그리지 않는다 |
| 렌즈집·소독도구 | 첫 인물 후보에는 왼손의 렌즈집을 함께 그려 접촉을 맞춘다. 별도 조사 확대 자산은 추후 같은 디자인을 따른다. 소독도구는 오른손이 닿는 쪽의 별도 장면 물건이며 이번 출력에는 포함하지 않는다 |
| 실제 표시 크기 | 지역 A 레이아웃에서 정할 값; 현재 미확정. 720p/FHD/QHD에서 인물 식별·붕대·손 상태 판독 필요 |
| 출력 처리 | 네이티브 알파 지원 시 직접 투명 출력. 미지원이면 균일 단색 원본과 기계적 배경 제거를 별도 기록. 불투명 원본은 납품이 아님 |

## 원본별 화풍 적용

**최신 결정:** B는 완전 제외. 아래 B행과 기존 A/B 프롬프트는 이전 실행 이력이다. 현재는 A 원본/캐릭터 누끼만 사용하며 실행 08 이후의 새 계약을 따른다. 05에 대한 사용자 평가는 “후보 자체는 괜찮지만 A 화풍과 관련 없음”이며 화풍 승인이 아니다.

| 원본 | 가져올 부분 | 가져오지 않을 부분 | 이번에 적용하지 않는 부분 |
|---|---|---|---|
| A `user_style_A.png` | 보이는 코·볼·턱의 중앙 구조선과 큰 명암 면, 피부·천 내부의 방향 있는 붓면, 큰 머리 명암 덩어리 | 금발·트윈테일·얼굴 정체성·드레스·하트·별·포즈·정확한 팔레트 | 붕대 아래 가려진 눈을 화풍 증명 목적으로 드러내지 않음; 배경 전체 |
| B `user_style_B.png` | 짙은 유색선의 굵기·압력·끊김, 칼라·소매·가운 겹침선, 실루엣의 굵고 가는 경계 | 외눈·다중 눈·녹색 머리·식물·꽃·고딕 의상·손포즈·정확한 팔레트 | 배경 콜라주성: 투명 인물에는 적용하지 않음 |

Layer 원본 파일 ID: A `b13c3913-552c-43f4-a6d1-adfe0b96cfec`, B `efb33a18-433d-4c17-91bc-80923207934f`.
A만 사용한다. 사진풍으로 판정된 FLUX 및 이전 미승인 생성물은 입력·수정 원본·기준 이미지에서 제외한다.

## 과거 생성 계약 — 첫 후보 (현행 입력으로 사용 금지)

> Create one hand-drawn 2D cutout of Mira Ben for the Stage 1 investigation scene, entire seated figure visible, both eyes covered by emergency bandages. Slim adult researcher, short dark-brown bob, exactly two parallel silver pins behind her left ear, muted leaf-green knit, cream collar, worn off-white lab coat, low black lace-up shoes. Image A supplies broad facial planes on the exposed lower face, directional painted fills and broad hair shading masses. Image B supplies irregular dark colored line weight and garment overlap construction. Keep her adult stylized proportions and 2–3 distinct shading masses; no photographic skin, individual hair-strand rendering or smooth photographic shading. Transparent background; no furniture, room, collage, contact shadow, labels or inset views. Do not copy either reference's character, costume, symbols or palette.

제작 선택: 약간 높은 카메라에서 왼쪽 얼굴이 보이는 3/4 시점, 인물은 화면 오른쪽을 향한다. 바닥에 앉아 무릎을 굽히고 상체를 뒤로 기울인다. 왼손은 무릎 위에 작은 깨진 렌즈집을 쥐고 오른손은 오른쪽 바닥으로 내려 둔다. 장면 가구의 정확한 가림과 최종 표시 크기는 장면 합성 때 확정한다. 이는 원작에서 확인한 각도나 사용자 승인 포즈라고 기록하지 않는다.

현재 실행은 [모델 비교 실험 계획](mira_model_experiment_2026-09-26.md)을 따른다. Qwen 계열은 사용자 결정으로 제외했다. A 원본 또는 A 캐릭터 누끼만 참조하고 균일 단색 중간 출력 후 BiRefNet v2로 배경을 제거한다. 역할 분리 성공은 사용자 평가 대상이다. 이전 실패 생성물은 입력하지 않는다.

## 재개에 필요한 결정

1. **확정:** 지역 A의 렌즈집은 손에 든다. Stage·13E를 같은 상태로 맞췄다. 생성 계약에 렌즈집을 잡는 손 모양과 소품의 가림 관계를 포함한다.
2. 첫 후보 포즈는 위 제작 선택을 따른다. 최종 게임 배치 때 지역 A의 표시 크기·가림·피벗을 확정한다. 해당 미완료를 화풍 비교 후보 생성과 혼동하지 않는다.
3. A 또는 A 캐릭터 누끼만 입력한다. B·Qwen 시험 및 실패한 FLUX 설정 반복은 금지한다.

품질은 사용자가 평가한다. 승인 전 Gold Standard로 승격하지 않는다. 투명 알파·캔버스·피벗 검사는 화풍 승인을 대신하지 않는다.

