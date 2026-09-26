# Style Calibration Candidates — 2026-09-25

상태: **candidate — 사용자 승인 전**

## 입력

- Notion: `13. 비주얼 제작 바이블 — 전역 스타일·AI 일관성`
- Style Reference A: `docs/research/visual_reference/user_style_A.png`
- Style Reference B: `docs/research/visual_reference/user_style_B.png`
- 정본 규칙: `docs/VISUAL_DIRECTION.md`, `docs/IMAGE_ASSET_WORKFLOW.md`
- 생성 도구: Codex built-in `image_gen`

Notion 페이지는 브라우저에서 제목만 확인됐고 본문은 로딩 상태에 머물러 직접 추출하지 못했다. 구체 프롬프트는 저장소에 이미 정본화된 A/B 역할과 이미지 자산 규칙을 사용했다.

## 결과

| 파일 | 자산군 | 상태 | 관찰 |
|---|---|---|---|
| `candidates/portrait/archivist_portrait_v1.png` | 인물 초상 | candidate | 안면 초점, 유색 구조선, 콜라주형 배경을 시험한다. |
| `candidates/gameplay_sprites/field_investigator_v1.png` | 게임플레이 스프라이트 | failed candidate | 배경이 불투명해 알파 하드 게이트를 통과하지 못했다. |
| `candidates/gameplay_sprites/field_investigator_v2_background_edit.png` | 게임플레이 스프라이트 | candidate | v1의 배경만 추출한 편집. 실제 알파 채널을 확인했다. |
| `candidates/environment/records_room_v1.png` | 조사 공간 배경 | candidate | 증거 상자, 이동용 문, 분위기용 서류 더미의 3단계 정보 밀도를 시험한다. |

이 파일들은 Gold Standard나 승인 자산이 아니다. 사용자가 실제 이미지를 보고 승인·탈락·수정 방향을 결정한다.
