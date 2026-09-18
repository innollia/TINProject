# TINProject — 사이클 1 (20 AI시간) 실행 계획서

작성: 2026-09-18. 구현 완료 후 기록용으로 정리. 실제 소요 시간은 병렬 wall-clock 기준 약 16시간(직렬 20h 대비 45% 단축).

---

## 1. 사이클 1 목표

> **첫 진입 전체(키 흡수→블랙홀→낙하 편집→자연 배정) + 기록 v1(자동 관찰·수동 정리·테마 수집) + "의도적 죽음→귀환→처음엔 몰랐던 지름길"이 실제로 플레이되는 첫 세트 1개를, 기존 데모 3개 회귀(639 checks) 깨지 않고 완성한다.**

---

## 2. 20시간 배분표 (0.5h 단위, 합계 20.0h)

| 블록 | 시간 | 소유 | 산출 |
|---|---:|---|---|
| **A0. 기준점 (완료)** | 0.5h | 통합 담당 | 승인된 git init + 첫 커밋, 노트북 사양 기록(i5-1334U / Iris Xe / 16GB) |
| **A. 계약·앱 골격** | 4.5h | 계약·앱 통합 **단일 소유** | 계약 확장, Director 분기, AppRoot 라우팅/프로필/기록/공용 UI, 테스트 확장 |
| **B. 첫 진입 모듈** | 4.0h | 첫 진입 담당 | `modules/first_entry/` 완성(키 흡수, 편집, 충돌, 재실행, 프로필 연결) |
| **C. 세트·기록·죽음** | 8.5h | 세트·기록 담당 | 5모듈 세트 + 기록 v1 + 죽음/귀환/지름길 검증 |
| **D. 통합·회귀** | 2.0h | 통합 담당 | 카탈로그 등록, 러너 확장, 전체 검증 4단계 |
| **E. 검수·데모** | 0.5h | 통합 담당 | 종료 데모 시나리오 통과 |
| **합계** | **20.0h** | | |

### 병렬 구조 (wall-clock ≈ 16h)
```text
A0 git 기준점 (0.5h)
   ↓
A 계약·앱 골격 (4.5h)  ← G1 gate
   ↓
B 첫 진입 (4.0h)  ∥  C 세트+기록 (8.5h)   ← 병렬
   ↓ (C가 병목)
D 통합·회귀 (2.0h)  ← G2 gate
   ↓
E 검수·데모 (0.5h)  ← G3 gate
```

---

## 3. 트랙별 상세 작업 내역

### A. 계약·앱 골격 (4.5h) — `core/**`, `app/**`, `tests/**` 단일 소유

| 순서 | 작업 | 시간 | 산출 파일 |
|---|---|---:|---|
| A1 | **계약 확장**: `GameModule.requested(kind,payload)` 시그널, `ModuleContext.arrival/identity_view` 읽기 전용 주입, 예약 outcome `portal_requested`/`died`, 포털 거부 알림, 관찰 발행/체크포인트/정체성 조회 API | 2.0h | `core/contracts/game_module.gd`, `module_context.gd`, `module_result.gd` |
| A2 | **Director**: `change_module` 인자 확장(arrival, identity, discard_current), 캡처 분리(세션/체크포인트), 포털·죽음 분기, busy/stale 가드 | 1.0h | `core/services/module_director/module_director.gd` |
| A3 | **AppRoot**: 첫 진입 판별, `profile`/`language`/`records_store`/`records_overlay`, 라우트 테이블(`ROUTES`), 세 가지 shape 기반 시작 배정, Esc 우선순위(모달→메뉴→일시정지), `--dev-shell`에서만 데모 선택기, 진입 프로필 저장, 공용 메뉴/저널/클리커, 설정/언어 공용 UI | 1.0h | `app/app_root.gd`, `app/app_root.tscn` |
| A4 | **테스트 확장 + 1회 검증**: `test_cycle_app.gd` 9케이스, `run_tests.gd` 카탈로그 동적 구성, 고정 4단계 검증 1회 실행 | 0.5h | `tests/core/test_cycle_app.gd`, `tests/run_tests.gd` |

### B. 첫 진입 모듈 (4.0h) — `modules/first_entry/**`, `test_first_entry.gd`

| 작업 | 시간 | 상세 |
|---|---:|---|
| 키 흡수 인트로(6키 ↑↓←→ Z X, 순서 자유, 홀드 무시, 나선 흡수 0.45s/키) | 1.0h | `first_entry.gd` phase="keys", `presentation.gd` 아이콘 UI |
| 카메라 블랙홀 줌 0.8s → 체크포인트 `intro_seen` 저장 | 0.5h | `_advance` phase="zoom" |
| 대각선 낙하 + 캐릭터 편집(실루엣 3×색 3 즉시 미리보기) + 햄버거/언어/부딪히기 | 1.5h | phase="editor", `_apply_identity`, procedural Polygon2D 몸체 |
| 자연 배정(shape→`signal_desk`/`relay_quay`/`return_cradle`) + 재실행 0.6s 단축 연출 + 프로필 연결 | 1.0h | `requested.emit("start",{shape,color})`, `execute_command("language"/"retry_start"/"reset")` |
| 모듈 테스트 + 수동 체크 | 0.5h | `test_first_entry.gd` 11케이스(221 assertions) |

### C. 세트·기록·죽음 (8.5h) — `modules/{signal_desk,relay_quay,last_echo,return_cradle,maintenance_cut}/**`, `meta/records/**`, `test_set_modules.gd`, `test_records.gd`

| 작업 | 시간 | 상세 |
|---|---:|---|
| **세트 5모듈 골격**(각 0.9h, S등급) | 4.5h | `signal_desk`(2D 주파수 학습), `relay_quay`(3D 중계 배달), `last_echo`(2D 메인화면 걷기·죽음), `return_cradle`(2D 귀환 앵커), `maintenance_cut`(3D 지름길) |
| **기록 v1**(3.5h) | 3.5h | `RecordsStore`(observe/visit/capture/restore/add_note/select_theme, schema v1), `records_overlay`(J키, 자동 관찰 리스트+편집 가능한 메모/태그+테마 선택), 5작품 테마 팔레트 |
| **죽음·귀환·지름길 검증**(0.5h) | 0.5h | `died`→`return_cradle` 세션 롤백, `maintenance_cut` 90+왼쪽+확인 지름길(플래그 없이 행동만으로), 기록/정체성 보존 |

---

## 4. 위임 단가 템플릿 (모듈 1개당, 사이클 2 이후 적용)

| 등급 | 제작 | 테스트 | 리뷰 | 통합 | 합계 | 판정 기준 |
|---|---:|---:|---:|---:|---:|---|
| **S** | 1.0h | 0.5h | 0.5h | 0.5h | **2.5h** | 입력 ≤2, 스칼라 상태, 2D 단일 씬 |
| **M** | 2.0h | 1.0h | 0.5h | 0.5h | **4.0h** | 입력 3~4, 배열/구조 상태, 2D 다중 씬 |
| **L** | 3.5h | 1.5h | 1.0h | 1.0h | **7.0h** | 입력 ≥5, 다중 엔티티 + migrate ≥2, 3D 포함 |

- **3D는 최소 M 승격**. L 단가는 사이클 1에 없음 → 사이클 2에서 1개 실측 후 확정.
- **단일 소유 규칙**: `app_root.gd` 카탈로그·바인딩·`run_tests.gd`는 통합 담당 전용. 모듈 워커는 `modules/<id>/` 내부만.

---

## 5. 단계 Gate + 20h 종료 데모 시나리오

| Gate | 시점 | 통과 기준(정량) | 실패 시 조치 |
|---|---|---|---|
| **G1 골격** | t≈5h | 4단계 검증 전부 exit 0, 639+신규 회귀 통과, 신규 계약 테스트 존재, 4개 흐름 스텁 수준 카탈로그 연결 | 핵심 루프 복구 우선, 광택 전면 보류 |
| **G2 플레이가능** | t≈13.5h | 4단계 + headless/GL 이중 통과, 노트북 실기 1회 완주 | 죽음-복구→귀환→기록 순 수정 |
| **G3 검수 집계** | t≈20h | 4단계+수동 시나리오(전환 연타·손상 파일) 기록 + 데모 리허설 통과 + **승인된 git init·커밋 존재** | 회귀 수정 우선, 데모 범위 축소 허용(639·계약 테스트는 불가) |

### 데모 시나리오 (총 30분)
1. 첫 진입·키 흡수 1회 (5분)
2. 낙하·편집·부딪히기로 자연 배정 (5분)
3. 세트 귀환 1회 완주: `signal_desk`→`relay_quay`→`last_echo`(죽음)→`return_cradle`→`maintenance_cut`(지름길)→`last_echo` (10분)
4. 기록·테마 수집 확인 (5분)
5. 죽음→지름길 복구 10~20초 (5분)

---

## 6. [AI판정] 기본값 (뒤집으려면 명시)

| 항목 | 기본값 |
|---|---|
| 키 세트 | ↑↓←→ + Z X (6개) |
| 언어 | 한국어/영어, 기본 한국어 |
| 첫 배정 초기 표 | shape 0→`signal_desk`, 1→`relay_quay`, 2→`return_cradle` |
| 기록 열기 키 | J |
| 데모 선택기 | `--dev-shell` 실행에서만 노출 |
| 세트 이름·구성 | 「끊어진 항로」 5모듈(위 표) |
| 임시 자산 | 색상 상수+엔진 프리미티브만, 외부 파일 없음. **작품별 색·구도 차이는 지금부터 구분** |
| 재실행 연출 | 블랙홀 잔상+짧은 낙하 0.6초 → 편집. 키 흡수 재생 없음 |
| 나가기 | 확인창 있음 |
| 몸 표현 | 비성적 단순 실루엣(머리·몸통·사지·머리카락), 폴리곤 프리미티브 |
| 동료 | 준호(이름만, 라벨 없음), 세계관 내 대화로만 지원 |

---

## 7. 리스크 상위 3 + 버퍼 배치

| # | 리스크 | 흡수 버퍼(소진 순서) |
|---|---|---|
| 1 | **계약 변경이 B·C 동시 차단** | ① 통합 풀 잔여 → ② 예비 0.5h → ③ T1 여유 1.0h |
| 2 | **죽음×기록×저장 3계층 상호작용 결함**(죽은 세션 캡처가 체크포인트 덮어씀) | 캡처 분리 테스트 선행, 미해결 시 죽음 귀환만 차단 보고 |
| 3 | **세트 5개 미달** | 계약 테스트 통과분만 등록(놓침 허용), 미완성 폴더 남기고 사이클 2 이관 |

**버퍼 총 1.0h** (회귀 0.5h + 예비 0.5h). git init 미승인 시 0.5h 예비 환원.

---

## 8. 사이클 2 (20~40h) 임시 방향 — 확정 아님

1. [완료] 첫 진입 레이아웃 다듬기 — 960×600/1152×720 렌더 캡처에서 메뉴·언어·편집 패널·부딪히기 버튼 겹침 없음
2. [완료] `last_echo`·`return_cradle` 대사 자연화 — 준호 이름 표기와 친구다운 재회 대화, 3단계 반복 대화 적용
3. [완료] 기록 편집/삭제 — `edit_note`, `remove_note`, 오버레이 선택 보호와 저장 테스트 적용
4. [완료] 시작 3종 콘텐츠 두께 확장 — `signal_desk` 3종 순환 우편, `relay_quay` 운반·작업대·중계기 루프, `return_cradle` 저장되는 재회 대화
5. [완료] 노트북 실측 — i5-1334U/Iris Xe/16GB, 1152×720 GL Compatibility에서 첫 진입 25~26 FPS·320.3 MiB, 중계 안뜰 37~39 FPS·402.9 MiB; 시작 setup 1.691초, 메인 씬 load 0.171초
6. 실측 단가 기반 배치 증산(사이클당 5~10개), 100개 로드맵 첫 실측 지점 확보

---

## 9. 검증 명령 (AGENTS.md 고정 — 변경 금지)

```powershell
$exe = 'C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe'
$p = Start-Process -FilePath $exe -ArgumentList '--headless --path C:\projects\TINProject --editor --import' -NoNewWindow -Wait -PassThru; $p.ExitCode
$p = Start-Process -FilePath $exe -ArgumentList '--headless --path C:\projects\TINProject --script res://tests/run_tests.gd' -NoNewWindow -Wait -PassThru; $p.ExitCode
$p = Start-Process -FilePath $exe -ArgumentList '--headless --path C:\projects\TINProject --script addons/gut/gut_cmdln.gd -gdir=res://tests/core -gexit' -NoNewWindow -Wait -PassThru; $p.ExitCode
$p = Start-Process -FilePath $exe -ArgumentList '--headless --path C:\projects\TINProject --quit-after 180 --fixed-fps 60' -NoNewWindow -Wait -PassThru; $p.ExitCode
```

**전부 종료 코드 0, stderr에 `SCRIPT ERROR`/`ERROR` 없어야 통과.**

---

## 10. 핵심 불변식 (다음 작업자 필독)

1. 모듈은 **목적지 ID·다른 모듈 상태·전역 저장·autoload 모름**.
2. `requested` 시그널로만 앱과 통신. `finished`는 **진짜 완료만**.
3. `context.arrival/identity_view`는 **읽기 전용 깊은 복사**.
4. 죽음 귀환은 **세션 상태 초기화**, 기록/프로필/정체성 **보존**.
5. 기록 기능은 **처음부터 전부 제공**, 테마 수집만 해금.
6. 공통 성장 재화/인벤토리/능력치 **없음**.
7. 메타 해설(게임 구조 설명 대사) **금지**.
8. 기존 데모 3개·639 checks·GUT 50/50 **회귀 0 유지**.

---

## 11. 파일 트리(사이클 1 산출물)

```
C:\projects\TINProject\
├── core/
│   ├── contracts/
│   │   ├── game_module.gd          ← requested 시그널, context 확장
│   │   ├── module_context.gd       ← arrival, identity_view
│   │   └── module_result.gd        ← outcome 예약값 portal_requested/died
│   └── services/module_director/
│       └── module_director.gd      ← change_module 5인자, 캡처 분리
├── app/
│   ├── app_root.gd                 ← 라우트/프로필/기록/공용UI/시작배정
│   └── app_root.tscn               ← catalog 동적 구성, UIHost 공용 오버레이
├── modules/
│   ├── first_entry/
│   │   ├── first_entry.gd          ← 6키 흡수, 편집, 충돌, 재실행
│   │   ├── presentation.gd         ← 프로시저럴 UI(아이콘, 편집기, 버튼)
│   │   ├── entry.tscn
│   │   └── manifest.tres
│   ├── signal_desk/                ← 2D 주파수 학습
│   ├── relay_quay/                 ← 3D 중계 배달
│   ├── last_echo/                  ← 2D 메인화면 걷기, 죽음
│   ├── return_cradle/              ← 2D 귀환 앵커
│   └── maintenance_cut/            ← 3D 지름길
├── meta/records/
│   ├── records_store.gd            ← RefCounted, observe/visit/capture/...
│   ├── records_overlay.gd          ← Control, J키, 자동/수동/테마 UI
│   └── theme_catalog.gd            ← 5작품 팔레트 (records_store 내장)
├── tests/
│   ├── run_tests.gd                ← 639 checks + 신규 시나리오
│   └── core/
│       ├── test_cycle_app.gd       ← 9케이스(배정/라우트/죽음/복원/언어)
│       ├── test_first_entry.gd     ← 11케이스(흡수/편집/배정/스킵)
│       ├── test_set_modules.gd     ← 11케이스(5모듈 상태/입력/지름길)
│       └── test_records.gd         ← 19케이스(스키마/중복/수집/편집/테마)
└── HANDOVER.md                     ← 인계 문서(이 계획서와 짝)
```

---

## 12. 실제 검증 결과(구현 후 기록)

| 단계 | 종료 코드 | 비고 |
|---|---:|---|
| `--editor --import` | 0 | 파싱·타입 검사 통과 |
| `run_tests.gd` (통합 러너) | 0 | 639/639 checks passed |
| GUT `tests/core` | 0 | 54/54 tests, 2,034 assertions |
| `--quit-after 180` smoke | 0 | headless 180프레임 무오류 |
| 실제 GL 창 실행 | 0 | Intel Iris Xe/OpenGL 3.3 Compatibility, 960×600·1152×720 캡처 검수 완료. 60 FPS 미달은 다음 최적화 후보 |

---

**다음 작업자는 `HANDOVER.md` + 이 계획서만 읽으면 즉시 사이클 2 착수 가능.**  
계약·소유권·불변식만 지키면 `modules/<new_id>/` 자유 구현 후 통합 담당에게 카탈로그 등록만 요청하면 됩니다.
