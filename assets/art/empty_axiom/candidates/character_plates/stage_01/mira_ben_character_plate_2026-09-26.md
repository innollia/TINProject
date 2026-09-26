# 미라 벤 인물판 후보 — 2026-09-26

상태: `candidate` — 사용자 시각 피드백 대기. Gold Standard나 게임 사용 승인 자산이 아니다.

## 파일과 출처

- 이미지: `mira_ben_character_plate_2026-09-26.png`
- SHA-256: `A8356D6512E14013D8CD09A03A4A6D26D6709CFB7126366E161972BE9F56EA58`
- 생성 도구: Codex built-in `image_gen`
- 출력: PNG, 1024×1536, RGB 불투명, 단일 레이어
- 입력 정본: `docs/art/PERSONAL_STYLE_CORE.md` v0.1, `docs/art/projects/empty_axiom/PROJECT_ART_LAYER.md`, `docs/art/projects/empty_axiom/asset_briefs/mira_ben_character_plate.md`, Golden Idol 13 바이블·13A-1·13A-4·Stage 1
- 스타일 입력 A: `docs/research/visual_reference/user_style_A.png` (`90EFF9F62C60CDBC223D3E2A4527286DA35745D93B454CBEC1C0A97078EFB22C`)
- 스타일 입력 B: `docs/research/visual_reference/user_style_B.png` (`BAD6779A40DD1D6A007FAC4C51719FEED8EE12FACAB17710254BF136691D9EC7`)
- 활성 Gold Standard: 없음
- 이전 생성 이미지: 입력·편집 원본·비교 기준으로 사용하지 않음
- 후처리: 없음. 생성된 픽셀을 그대로 복사함.

## 사용한 생성 프롬프트

```text
Use case: stylized-concept. Create ONE new vertical 1024x1536 character identity plate for the fictional game project Empty Axiom, subject Mira Ben only. The two input images are STYLE REFERENCES ONLY, not edit targets and not character identity references. Image A (blonde girl) supplies only painterly facial planes, restrained brush texture inside skin and large color masses, and hair-mass lighting. Image B (green-haired girl) supplies only variable-weight dark colored structural lines, readable garment construction, silhouette control, foreground/background density separation, and loosely collaged background masses. DO NOT copy either reference character's face shape, hairstyle, outfit, pose, ornaments, colors, botanical motifs, eye motif, hearts, stars, or signatures.
Subject canon: Mira Ben, a 26-year-old adult visual-perception researcher, slender about 164 cm with narrow shoulders and slightly forward-leaning posture. Oval face tapering to a slightly pointed chin, relatively small horizontally elongated eyes, right eyebrow subtly higher, faint blue-gray shadow under lower eyelids, light neutral skin, minimal makeup. Short rounded dark-brown bob ending below the ears; bangs part slightly toward her right and do not fully cover the center of her forehead. EXACTLY TWO parallel silver hairpins tucked behind HER LEFT EAR, clearly visible, with no extra pins. Muted leaf-green knitted sweater (#66735A relationship), cream shirt collar, worn off-white straight lab coat with small graphite and machine-oil marks only at sleeve ends, dark trousers and low black lace-up shoes. One small blank rectangular note card held close to the body; her thumb unconsciously traces/presses the card edge. Concentrated restrained expression; gaze slightly misses the card. This is PRE-INJURY baseline: both eyes intact, no bandage, no blood, no fresh wound. No glasses.
Composition: one full-body adult figure from head to shoes on left two-thirds, and two small inset details on right: face/left ear showing precisely two hairpins, and hand/thumb on blank card edge. Clearly the same individual across insets. Simple anonymous analog laboratory shapes in low-contrast backdrop, no new story clues, no readable labels or documents. One directional light; face and hand highest clarity. Painterly uneven interior fill, three broad facial value planes, dark colored structural ink with purposeful weight changes, cloth fold direction and matte skin. Project palette: desaturated olive, aged ivory, charcoal-brown, very small silver point. No glossy anime rendering, no generic fashion pose, no decorative collage symbols, no flowers, no leaves, no text, no caption, no signature, no watermark. Single coherent character plate, not an animation sheet. Keep hands anatomically plausible, all figure parts within canvas with safe margin.
```

## 1차 판정

- 파일 형식, 크기, 불투명 배경, 단일 이미지 조건 충족.
- 전신, 얼굴·왼귀 확대, 카드 손동작 확대가 한 장에 있음.
- 본컷과 얼굴 확대에 은핀 두 개가 보임. 보브, 잎녹 니트, 낡은 연구가운, 검은 끈구두, 사건 전 무상처 상태가 보임.
- 읽을 수 있는 글자·서명·워터마크가 보이지 않음.
- 얼굴과 손의 중요도가 배경보다 높음.
- 사용자 시각 판정과 실제 게임 화면 3종 해상도 검수는 아직 수행하지 않음.

## 2026-09-26 스타일 파이프라인 감사

이 후보는 내용 조건을 꽤 많이 충족했어도 **Style Master bootstrap 이전의 production-first 시도**로 취급한다. 다음 production 생성의 스타일 기준으로 승격하지 않는다.

### 프롬프트에서 과적재된 것

한 번의 생성 요청에 동시에 들어간 요구가 너무 많았다.

- A/B 두 레퍼런스의 선택적 역할 분해와 재합성
- 미라의 얼굴형·눈·눈썹·머리·핀 개수
- 의상과 오염 위치
- 카드와 손 습관
- 사건 전 상태
- 전신 + 확대 인셋 2개
- 배경 정보 제한
- 팔레트
- 해부·안전 여백·문자 금지 같은 기술 조건

이 상태에서는 모델이 **검증하기 쉬운 identity/구성 조건을 맞추고, 스타일 조건은 일반적인 애니 콘셉트 아트 prior로 평균내도** 프롬프트의 많은 항목을 충족할 수 있다.

### 특히 약했던 스타일 표현

아래 표현은 현재 `PERSONAL_STYLE_CORE.md` v0.2의 시각 불변식에 비해 너무 일반적이었다.

- `painterly facial planes`
- `restrained brush texture`
- `variable-weight dark colored structural lines`
- `three broad facial value planes`
- `purposeful weight changes`

이 단어만으로는 A의 얼굴 중앙 구조선/명암 분할이나 B의 선 압력·끊김을 반드시 재현하게 만들지 못한다.

### 다음 시도 조건

미라를 다시 생성하기 전에 `docs/IMAGE_ASSET_WORKFLOW.md` 4절의 Style Master bootstrap을 먼저 수행한다.

Style Master 승인 뒤 미라는:
1. Style Master + 최소한의 실루엣/색 관계로 **style lock**
2. 핀 정확히 두 개, 얼굴 특징, 카드 손동작 등은 **identity correction**
3. 파일 규격과 기술 조건은 **technical correction**

순서로 조인다.

현재 프롬프트는 회귀 비교용 기록으로 보존하며, 다음 생성 요청의 템플릿으로 재사용하지 않는다.
