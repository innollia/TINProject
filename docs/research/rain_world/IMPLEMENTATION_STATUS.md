# Kit 06 `sideview_ecosystem` — 구현 현황

> 이 파일은 사실 기록이다. 테스트를 돌리지 않은 것을 통과로 쓰지 않는다.
> 결정은 `GRILLING_STATE.md` §5.1, 규격은 `plans/kits/06_SIDEVIEW_ECOSYSTEM_KIT.md`가 정본이다.

상태: **진행 중 (2026-09-27 세션 시작)**

## 세션 규칙

- 브랜치 `kit/05-stone-story-rpg` 고정. 다른 세션과 같은 폴더·같은 브랜치.
- 소유 경로: `modules/sideview_ecosystem/**`, `tests/core/test_eco_*.gd`, `plans/kits/06_SIDEVIEW_ECOSYSTEM_KIT.md`, `docs/research/rain_world/**`.
- Godot 잠금 이름 `kit06` (`C:\projects\_locks\TINProject-godot.lock`).
- 서브에이전트·워크플로 금지. 사용자 수면 중 — 질문 없이 추천대로 진행.

## 진행 순서

1. [x] 물 규칙·미결 결정 (`GRILLING_STATE.md` §5.1 Q1~Q14)
2. [ ] 계획서 반영 — 빠진 §10~§16·§20 작성, 모순 정정
3. [ ] domain 구현 + 먼저 쓰는 테스트
4. [ ] systems(비시각) 구현 + 테스트
5. [ ] authored content
6. [ ] 전체 자동 검증 → 이 파일 갱신 → 커밋·푸시
