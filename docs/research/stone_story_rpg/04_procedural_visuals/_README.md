# 04_procedural_visuals — 코드로만 그리는 비주얼 계약

이 Kit은 **이미지 자산 파일을 쓰지 않는다.** 모든 화면은 코드로 그린다.
시각 근거: [../01_stone_story_rpg/structure_extraction.md](../01_stone_story_rpg/structure_extraction.md) §1

## 금지

- 이미지 파일 로드
- GPT 이미지 생성/편집
- 스프라이트 시트·아틀라스
- 폰트 이미지
- **ASCII 문자 렌더링** (사용자 확정 금지, `PROJECT_DECISIONS.md` §21)

## 1. 내부 버퍼와 정수 스케일 (결정)

```text
내부 해상도   960 × 540   (16:9)
렌더 필터     nearest
스케일        정수 배만. 실수 배 금지.
```

| 목표 출력 | 정수 배 | 결과 | 여백 |
|---|---|---|---|
| 1280×720 | 1 | 960×540 | 없음 |
| 1920×1080 | 2 | 1920×1080 | 없음 |
| 2560×1440 | 2 | 1920×1080 | 좌우 320px + 상하 180px |

**여백이 보이지 않는 이유:** 이 Kit의 화면은 순수 검정 배경 + 흰 헤어라인이다.
레터박스/필러박스도 검정이므로 화면과 경계가 없다. 이것이 흑백 방향의 실제 이득이다.

### Godot 4.7 설정

```ini
; project.godot — 이 Kit 전용 SubViewport 기준
display/window/stretch/mode="disabled"
display/window/stretch/aspect="keep"
rendering/textures/canvas_textures/default_texture_filter=0   ; nearest
rendering/anti_aliasing/quality/msaa_2d=0
```

씬 구조:

```text
Root (Control, full rect)
└── SubViewportContainer  stretch=true, stretch_shrink=<정수배>
    └── SubViewport  size=960x540, own_world_3d=false
        └── WorldRoot (Node2D)  ← 모든 절차 드로잉
```

`stretch_shrink`을 창 크기에 맞춰 매 프레임 재계산한다.
`k = max(1, floor(min(win.x/960, win.y/540)))`.

## 2. 드로잉 규칙 (결정)

| 규칙 | 값 |
|---|---|
| 앵티에일리어싱 | 금지. 모든 좌표 정수 스냅 |
| 선 굵기 | 논리 1px 고정. 2px 이상 금지 |
| 채움 | 금지. 면을 채우는 도형 쓰지 않음 (전경선 전용) |
| 곡선 | 선분 폴리라인. 베지어 사용 금지 |
| 색 | 무채색 원칙. 화면당 강조색 최대 2색, 총 면적 1% 미만 |
| 텍스트 | 엔진 폰트. 등폭이 아닌 일반 산세리프. 크기 8/10/12/14px만 |
| 텍스트 스냅 | 정수 좌표. 픽셀 중간 정렬 금지 |
| 커서 | 흰 1×1 칩 1개 |
| 포커스 | 색 변화 금지. **점선(파선) 테두리** |
| 패널 | 1px 외곽선 + 내부 빈 공간. 반투명 채움 금지 |

## 3. 절차 생성 규칙 (결정)

- **결정론**: 같은 `(location, star_level, seed)` 는 항상 같은 화면을 만든다.
- `randf()` 금지. 전부 시드 기반 정수 난수.
- 애니메이션은 프레임 카운터 기반 상태 전이. 보간 금지(픽셀 격자 유지).
- 벽/바닥/천장 텍스처는 **셀이 아니라 절차 배치**:
  시드 → 라인 개수/길이/간격/기울기 → 정수 좌표 폴리라인.
- 배경 밀도는 위치마다 다른 밀도 등급을 가진다 (근경 ≥ 중경 > 원경).

## 4. 정보 밀도 (스크린샷 근거)

- HUD는 모서리에 2~3 glyph씩. **박스·프레임·배경 없음.**
- 월드 정보는 오브젝트 실루엣과 지면 텍스처 대역으로만 전달.
- 대사창: 중앙~하단 가로 박스 + `<)` 계속 글리프.
- 상점/보물창/작업대: 우측 정렬 대형 패널, 좌측에 얇은 라벨 목록.

## 5. 허용 API

- CanvasItem `_draw()` / `queue_redraw()`
- `draw_line`, `draw_polyline`, `draw_polygon`(선 루프로만), `draw_rect`(선 모드), `draw_circle`(선 모드), `draw_arc`
- `draw_string` / `draw_multiline_string` (엔진 폰트)
- `draw_set_transform` (정수 이동만)
- 셰이더 코드 (이미지 파일 없이)
- `SubViewport` + `stretch_shrink` 정수 스케일

## 6. 미수집

- 보스 방 외 전투 방의 카메라 이동 규칙
- 지역 간 전환 연출의 실제 화면
- 오닉스 프레임의 종류와 등장 조건
