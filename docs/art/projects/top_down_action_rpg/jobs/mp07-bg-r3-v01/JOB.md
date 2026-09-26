# mp07-bg-r3-v01 — R3 Bellhouse Hospice 배경과 사물

상태: **준비만 함.** COMMON.md 맨 위 "준비만 할 것" 줄 때문에 도구 복사·레시피·build는 아직 안 했다. assets 쪽 job 폴더도 아직 만들지 않았다(14 §2: 실제로 착수할 때 만든다). 14 §6 기준 `spec_incomplete`(분위기·색 기준만 대기). 사용자 지시대로 R2(`mp07-bg-r2-v01`)를 끝낸 다음 시작한다. 결과는 만들어도 전부 candidate이고 승인은 사용자만 한다.

| 필드 | 값 |
|---|---|
| 목적 | environment_master + clean_base + prop + occluder + state_variant (R3 지역 한 묶음) |
| 소유권 | 세션 07. 쓰기: `assets/art/top_down_action_rpg/jobs/mp07-bg-r3-v01/`, `docs/art/projects/top_down_action_rpg/jobs/mp07-bg-r3-v01/`. 게임 코드·씬·content·규칙 문서 수정 없음, 게임 연결 없음, git 커밋·푸시 없음 |
| 자산 identity | 지역 `region_r3_bellhouse_hospice` / art key `art_world_r3_bellhouse_hospice`. 사물 4개는 content ID. 구역 ID·출구 그림 ID·foreground 이름은 작성자 설계 (BRIEF §3·§6) |
| 입력 계약 버전 | `inputs.json` (해시 2026-09-27 04:02 KST) |
| 카메라 | 지면 기준 60° 정사영, 방위 고정. 바닥 가로 180 px/m, 깊이 ×0.866, 높이는 플레이어 키 기준 1 m ≈ 110 px (R2 BRIEF §2와 같음) |
| 입력 이미지 | 픽셀 입력 없음. 모양 재료 `addons/at-icons/node2d` SVG. 시험 작업 그림은 눈으로 보는 화풍 기준(candidate) |
| 필요한 결과 | BRIEF §12: 그림 29장 + 그림자·검수 파일 |
| 내용 고정 | BRIEF §3~§7 |
| 금지 | BRIEF §10 |
| 수정 범위 | 위 두 job 폴더 안의 새 파일만 |
| 승인 상태 | 원본 입력 = content JSON·기획 문서. 화풍 기준 = 시험 작업(candidate). Gold Standard 0개. 이 job 결과 = candidate |
| 검수 항목 | BRIEF §13. 시작 후 `QA.md`에 pass/partial/fail/not_run으로 적음 |
| 중단 이유 | COMMON.md 준비 전용 줄: 분위기 기준(톤앤매너)과 캐릭터 스프라이트 형식을 다시 정하는 중. 사용자 2026-09-27 "톤앤매너가 배달오고있어", "작업 준비까지만 해둬". 이것 없이는 `palette_r3.json` 색 값, 조명 세기, 분위기 밀도를 정할 수 없음 |

## 체크리스트

준비 (끝남)
- [x] 자료 읽기: region·props·recovery JSON, 02 §1·§7.4·§8.4, 03 지역 표, 09 §3.1·§5.1·§12, 13, 14, IMAGE_ASSET_WORKFLOW, VISUAL_DIRECTION, PROJECT_ART_LAYER, H0 brief(형식 참고), 시험 작업 JOB·QA·배경 레시피(참고)
- [x] 만들 대상 목록 (BRIEF §12)
- [x] BRIEF.md
- [x] JOB.md 계획

시작 (R2가 끝난 뒤)
- [ ] COMMON.md 다시 읽기. 새 톤앤매너·화풍 기준을 `inputs.json`에 추가하고 BRIEF §8·§14의 `대기` 칸 채우기
- [ ] assets job 폴더 만들기, 기준 작업의 `tool/`(`__pycache__` 제외)과 `palette_h0.json` 복사, `tool/iconkit/icons.py` `prefetch()` `workers` 8 → 2. 바꾼 점은 여기 적기
- [ ] `recipes/palette_r3.json` (H0에서 바꾼 점을 여기 적기)
- [ ] 구역 A: base_clean → 사물 `profile` 2장 → 출구 E03·E17 4장 → foreground → master → preview_reassembled → 미리보기 → 모아 보기 시트
- [ ] 구역 B: base_clean → `bell` 2장, `vow` 2장 → 출구 E06·E10 4장 → foreground → master → preview_reassembled → 미리보기 → 모아 보기 시트
- [ ] 구역 C: base_clean → `valve` 2장 → 출구 E11 2장, 내부 길 2장 → foreground → master → preview_reassembled → 미리보기 → 모아 보기 시트
- [ ] 계단 연결 확인 (A↔B, A↔C)
- [ ] `QA.md`, `__pycache__` 지우기

만드는 방식: 자산 하나씩 레시피 → build → 직접 보고 확인 → 고치기(자산당 최대 2번). 배경은 한 번에 한 장씩.

## 작성자 설계 (문서에 없던 값)

- 층마다 한 화면(1층 접수 회랑, 2층 종탑·병동, 지하 보일러실·자비 기관)과 계단 위치, 모든 좌표 (BRIEF §3·§4).
- 자비 기관을 지하 화면 안의 높은 단 위에 두고, 내부 길 `boiler_undercroft_lift`를 그 단으로 오르는 승강기로 그림.
- 재질과 색의 관계 (BRIEF §8), 종교 상징 없이 장치로만 faith를 보여 주기.
- 사물 모양과 상태별 차이 (BRIEF §5), 출구·내부 길 그림 ID와 closed/open 모양 (BRIEF §6).
