# Style Master Calibration Plan — 2026-09-26

상태: **ready — 이미지 생성은 아직 실행하지 않음**

목적: A/B 두 Style Reference가 텍스트 해설 과정에서 일반적인 GPT 애니/콘셉트 아트로 평균화되는 위치를 분리하고, production 전에 사용자 승인 Style Master를 만든다.

## 공통 피사체

모든 비교 branch에서 피사체와 구도를 동일하게 유지한다.

- 완전히 새로 만든 성인 여성 1명
- 어깨까지 오는 검은 머리
- 장식 없는 탁한 황토색 작업 재킷 + 밝은 무채색 이너
- 허리 위 3/4 시점
- 한 손이 자연스럽게 보임
- 무표정에 가까운 낮은 표정 강도
- 캐릭터 고유 장식, 꽃, 잎, 하트, 별, 특수한 눈 없음
- 배경은 구체 장소가 아닌 단순한 평면 덩어리
- 텍스트/서명/워터마크 없음

이 피사체는 Style Master 후보를 만들기 위한 calibration dummy이며 TIN 세계관 캐릭터가 아니다.

## branch 규칙

각 생성은 현재 ChatGPT 대화에서 **서로 다른 conversation branch**로 판다.

각 branch:
- 이 계획 이전의 다른 생성 결과를 이미지 입력으로 받지 않는다.
- 현재 사용자가 다시 첨부한 원본 A/B 중 해당 branch에 필요한 이미지만 쓴다.
- 결과가 나오면 생성 branch 안에서는 수정하지 않는다. 먼저 원본 결과를 비교 표에 남긴다.
- 다음 branch는 다시 공통 피사체에서 시작한다.

## Branch A — A 단독 전달력

이미지 입력: A(금발 원본)만.

생성 계약:

> Draw one new waist-up 3/4 portrait of the neutral calibration subject. Use Image A only as a style reference: make an explicit central facial ridge/line organize the split between large light and shadow planes; keep rough painted fill inside skin and cloth; build the hair from broad light/dark painted masses rather than many clean strands. Do not copy the reference character, pose, outfit, ornaments, symbols, or exact palette.

검증 목적:
- 얼굴 중앙 구조선/명암 분할이 텍스트 과설명 없이 전달되는가
- 피부·머리의 넓은 붓면이 남는가

## Branch B — B 단독 전달력

이미지 입력: B(녹색 머리 원본)만.

생성 계약:

> Draw the same neutral calibration subject and composition. Use Image B only as a style reference: use dark colored structural lines with obvious pressure/weight changes and partial breaks; make garment construction readable through line and overlap; separate the subject from a layered flat-shape collage background by contrast and line density. Do not copy the reference character, pose, outfit, eye motif, botanical motifs, ornaments, or exact palette.

검증 목적:
- 선 굵기·압력·끊김이 실제로 전달되는가
- 의상 구조와 배경 콜라주 밀도 계층이 전달되는가

## Branch AB — Compact Visual Contract

이미지 입력: A + B.

생성 계약:

> Draw the same neutral calibration subject and composition. Image A controls only the central facial structure, large light/shadow planes, rough interior brush fill, and broad hair-mass lighting; Image B controls only variable dark-colored structural lines, garment construction, silhouette cleanup, and layered flat-shape background density. The result must visibly contain both behaviors without copying either reference character, outfit, pose, motifs, or exact palette.

검증 목적:
- 두 레퍼런스를 동시에 넣을 때 각각의 신호가 살아남는가
- 두 스타일 역할 사이 빈칸을 일반적인 클린 애니 렌더가 메우는가

## Branch Control — 장문 직렬화 비교

**A/B/AB 결과만으로 원인이 충분히 갈리면 실행하지 않는다.**

필요할 때만 현재 production 방식처럼 Style Core + 금지 + 구성 조건을 장문으로 직렬화한 control 한 장을 같은 피사체로 만든다.

검증 목적:
- A+B 자체가 문제인지
- 장문 텍스트가 실제 이미지 레퍼런스 신호를 희석하는지

## 비교 축

각 결과는 "예쁨"이 아니라 다음 여섯 축으로만 비교한다.

1. **Face split** — 중앙 능선/구조선이 큰 명암 면을 실제로 조직함
2. **Line behavior** — 굵기·압력·끊김이 균일 클린라인과 구별됨
3. **Interior paint** — 피부/천의 붓질이 전역 텍스처 필터가 아니라 형상을 따름
4. **Hair mass** — 잔가닥보다 큰 밝고 어두운 머리 덩어리가 먼저 읽힘
5. **Density hierarchy** — 얼굴/손 > 의상 > 배경의 대비·선 밀도 차이가 있음
6. **Motif leakage** — A/B의 구체 캐릭터·의상·꽃/잎/하트/별/특수 눈이 새 피사체로 새지 않음

각 축은 `pass / partial / fail`과 한 줄 관찰만 남긴다.

## Style Master 선택

- A-only/B-only는 원인 분리용이고 자동 Style Master가 아니다.
- AB가 두 핵심 문법을 동시에 유지하면 그 결과 또는 그 결과의 **한 번의 표적 수정본**을 Style Master 후보로 삼는다.
- AB가 평균풍으로 무너지면 A와 B를 한 장에서 합성하는 방법을 다시 설계한다. 이때 production 미라를 실험장으로 사용하지 않는다.
- 사용자 명시 승인 전에는 어떤 결과도 Style Master가 아니다.

## 승인 뒤 production

Style Master 승인 후 `mira_ben_character_plate`를 다시 시작한다.

1. Style Master + 미라의 큰 실루엣/색 관계만 넣어 style lock
2. 얼굴·은핀 정확히 두 개·카드 손동작 등 identity correction
3. 출력 크기·안전 여백·배경·기술 조건 correction
4. 실제 게임 화면 검수

기존 미라 장문 프롬프트는 비교용 실패 기록으로만 보존한다.
