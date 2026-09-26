# 《빈 공리》 이미지 후보 — 2026-09-26

상태: **candidate — 사용자 승인 전**

## 입력 정본

- 사용자가 붙여넣은 《빈 공리》 프로젝트 비주얼 정본
- 사용자가 붙여넣은 Stage 1~3 캐릭터 외형 정본
- `docs/research/visual_reference/user_style_A.png`
- `docs/research/visual_reference/user_style_B.png`
- 생성 도구: Codex built-in `image_gen`

`assets/art/style_calibration/`의 이전 생성물은 프롬프트, 이미지 입력, 비교 기준으로 사용하지 않았다.

## 이번 제작 범위

Stage 사건·공간 정본이 이번 입력에 포함되지 않았으므로 사건 장면을 임의로 만들지 않았다. 제공된 텍스트만으로 정의 가능한 Stage 1 인물 식별용 A등급 Character plate 세 장을 제작했다.

| 파일 | 인물 | 1차 감사 |
|---|---|---|
| `candidates/character_plates/stage_01/mira_ben_character_plate_v1.png` | 미라 벤 | **rejected** — 인물 정보는 일부 맞지만 A/B의 선·면·붓질 문법이 일반적인 애니 콘셉트 아트로 희석됐다. |
| `candidates/character_plates/stage_01/thomas_grell_character_plate_v1.png` | 토머스 그렐 | **rejected** — 인물 정보는 일부 맞지만 A/B의 선·면·붓질 문법이 일반적인 애니 콘셉트 아트로 희석됐다. |
| `candidates/character_plates/stage_01/ed_farrow_character_plate_v1.png` | 에드 파로 | **rejected** — 인물 정보는 일부 맞지만 A/B의 선·면·붓질 문법이 일반적인 애니 콘셉트 아트로 희석됐다. |
| `candidates/character_plates/stage_01/mira_ben_character_plate_v2_style_lock.png` | 미라 벤 | **candidate** — 거친 내부 채움, 각진 명암면, 굵기 변화가 있는 구조선, 평면 콜라주 배경을 강화했다. 보브·은핀 2개·잎녹 니트·흰 가운·카드 손동작이 보인다. |
| `candidates/character_plates/stage_01/thomas_grell_character_plate_v2_style_lock.png` | 토머스 그렐 | **candidate** — 전신 실루엣과 콜라주 구성을 확보했다. 긴 얼굴·얇은 안경·남색 조끼·평행한 펜 3개·문서 정렬 손동작이 보인다. |
| `candidates/character_plates/stage_01/ed_farrow_character_plate_v2_style_lock_failed_keys.png` | 에드 파로 | **failed candidate** — 화풍은 강화됐지만 손에 든 키링과 허리 키링이 중복 생성돼 오브젝트 연속성 규칙을 위반한다. 국소 편집은 이미지 생성 사용량 한도로 실행되지 않았다. |

세 장 모두 Gold Standard나 승인 자산이 아니다. 다음 편집·재생성은 사용자의 실제 이미지 판정 뒤 수행한다.
