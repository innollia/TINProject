"""g01 job documents (added in g01): JOB.md, inputs.json and QA.md for the four g01
jobs, plus the 상태 column of docs/art/projects/generic/catalog/g01_list.md.

    py -3 -B g01_docs.py

Everything is read from the recipes and outputs, so the documents cannot drift from
what was built.  QA findings are kept in QA_NOTES below (written by hand after each
review sheet was looked at).
"""

from __future__ import annotations

import hashlib
import json
import re
from datetime import date
from pathlib import Path

HERE = Path(__file__).resolve()
ROOT = next(p for p in HERE.parents if (p / "project.godot").exists())
JOBS_ASSETS = ROOT / "assets" / "art" / "generic" / "jobs"
JOBS_DOCS = ROOT / "docs" / "art" / "projects" / "generic" / "jobs"
LIST = ROOT / "docs" / "art" / "projects" / "generic" / "catalog" / "g01_list.md"

READ_ONLY = [
    ("docs/art/mass_production/COMMON.md", "rule doc, read only (size table, drawing rules, V1 as the style/tool base)"),
    ("docs/art/mass_production/GENERIC.md", "rule doc, read only (g01 scope, list and folder format, git steps)"),
    ("docs/art/projects/generic/catalog/g01_bs2_inventory.md", "BS2 kind list, read only (g01 share copied into g01_list.md)"),
    ("assets/art/top_down_action_rpg/jobs/h0-icon-mood-v02/recipes/palette_h0_mood.json", "V1 palette; every entry kept in palette_g01.json"),
    ("assets/art/top_down_action_rpg/jobs/h0-icon-mood-v02/tool/build.py", "V1 tool, copied"),
    ("assets/art/top_down_action_rpg/jobs/h0-icon-mood-v02/tool/review_sheet.py", "V1 tool, copied"),
    ("assets/art/top_down_action_rpg/jobs/h0-icon-mood-v02/tool/iconkit/render.py", "V1 renderer, copied unchanged"),
    ("assets/art/top_down_action_rpg/jobs/h0-icon-mood-v02/tool/iconkit/icons.py", "V1 icon library, copied (prefetch workers 8 -> 2)"),
    ("assets/art/top_down_action_rpg/jobs/h0-icon-mood-v02/tool/iconkit/raster.py", "V1 renderer, copied unchanged"),
    ("assets/art/top_down_action_rpg/jobs/h0-icon-mood-v02/tool/iconkit/paint.py", "V1 renderer, copied unchanged"),
]

TOOL_CHANGES = [
    "`iconkit/icons.py`: `prefetch` 기본 workers 8 → 2 (세션 규칙: 도구 workers 2 이하). 그림 결과는 같다.",
    "`build.py`: 레시피의 `meta`(9칸 여백, 핫스팟, 이음 여부, 단계)를 manifest에 그대로 넣는다.",
    "`review_sheet.py`: `--label`(어두운 바탕용 글자색), `--wrap N`(N개마다 줄 바꿈).",
    "추가 `g01kit.py`: 레시피 작성 도우미(원·날카로운 사각형·다각형·물방울·반짝별 조각, 묶음 회전·확대, 부채꼴, 꺾은선, 반지름 일정한 둥근 사각형, 프레임 태그) + `palette_g01.json` 생성. 렌더러는 그대로다.",
    "추가 `g01_docs.py`: 이 문서들과 목록 상태 칸을 레시피·결과에서 다시 쓴다.",
]

JOBS = {
    "g01-icons-v01": {
        "title": "판타지 계열·장르 없는 아이콘 (아이템·장비·스킬·상태)",
        "gen": "gen_icons.py",
        "spec": [
            ("캔버스", "128×128 투명 PNG 한 장씩, 평면 시점(무기는 대각선으로 눕힘)"),
            ("시트", "`output/_sheet/g01_icons_sheet.png` 한 줄 16개, 칸 128 + `g01_icons_sheet.json`(칸 번호 → 자산)"),
            ("화풍", "V1 도구의 윤곽선·명암·붓자국 그대로. 스타일 `icon`(3배 슈퍼샘플, 테두리 1.5px)"),
            ("그림 재료", "at-icons 모양 조각만: 원, 채운 사각형을 다각형·날카로운 사각형으로 자른 것, 물방울, 초승달, `stars`에서 떼어 낸 반짝별, 구름 등. 아이콘 하나를 통째로 그림으로 쓰지 않는다"),
            ("스킬·상태 구분", "스킬 = 청동 테 사각 판 + 종류색 바탕, 상태 = 은 테 원판 + 종류색 바탕"),
            ("글자", "없음(수면은 Z 대신 초승달·반짝별)"),
        ],
        "extra_tools": ["추가 `icon_sheet.py`: 한 줄 16개 아이콘 시트 + 칸 번호표."],
        "rebuild": ["py -3 -B gen_icons.py --stage all", "py -3 -B build.py --all", "py -3 -B icon_sheet.py"],
        "sheets": ["output/_sheet/g01_icons_sheet.png"],
    },
    "g01-ui-v01": {
        "title": "UI (창틀·버튼 바탕·게이지·커서·선택 테두리·감정 말풍선·화면 전환)",
        "gen": "gen_ui.py",
        "spec": [
            ("9칸", "글자 없는 바탕·틀만. 한 장 PNG + manifest `meta.nine_slice` = [왼, 위, 오른, 아래] px. 모서리 칸 밖의 변은 길이 방향으로 똑같게 만들어 늘려도 무늬가 안 깨진다"),
            ("상태", "버튼 4상태, 게이지 채움 4색은 한 레시피의 프레임(`<asset>_<상태>.png`) + `<asset>_sheet.png` 한 줄"),
            ("커서", "128×128, manifest `pivot` = `meta.hotspot`(누르는 점)"),
            ("감정 말풍선", "128×128, 5프레임(1~3 튀어나옴, 4~5 가볍게 흔들림) + 한 줄 시트, `meta.anchor` = 꼬리 끝(말하는 캐릭터 머리 위에 둘 점). 기호는 도형으로 조립"),
            ("화풍", "V1 도구. 스타일 `ui`(2배 슈퍼샘플). 바탕 판은 V1보다 거의 검게(글자가 올라갈 자리)"),
        ],
        "extra_tools": ["추가 `row_sheet.py`: 프레임을 한 줄 시트로 잇는다.",
                        "추가 `nine_preview.py`: 9칸 원본과 늘린 모습을 나란히 그린 확인 시트."],
        "rebuild": ["py -3 -B gen_ui.py --stage all", "py -3 -B build.py --all", "py -3 -B row_sheet.py",
                    "py -3 -B nine_preview.py --out ../preview/nine_all.png"],
        "sheets": [],
    },
    "g01-fx-v01": {
        "title": "전투·마법 효과 애니메이션",
        "gen": "gen_fx.py",
        "spec": [
            ("칸", "192×192 투명 PNG × 5프레임(`<asset>_1..5.png`) + 한 줄 시트 `<asset>_sheet.png` 960×192"),
            ("시점", "정면·평면(전투 화면용)"),
            ("빛", "잉크 테두리 없음. 빛 번짐은 흐린 평면 형태(g01kit.halo)로 따로 그림. 보통 알파 합성, 가산 합성도 가능"),
            ("화풍", "V1 도구, 스타일 `fx`(2배 슈퍼샘플). 얼음 결정·흙처럼 물체인 부분만 V1 명암·선을 쓴다"),
        ],
        "extra_tools": ["추가 `row_sheet.py`: 5프레임 한 줄 시트."],
        "rebuild": ["py -3 -B gen_fx.py --stage all", "py -3 -B build.py --all", "py -3 -B row_sheet.py"],
        "sheets": [],
    },
    "g01-overlays-v01": {
        "title": "날씨·안개·빛 겹침 무늬, 어둠 가림막",
        "gen": "gen_overlays.py",
        "spec": [
            ("이음 무늬", "768×768, 네 변이 이어진다(가장자리에 걸친 조각을 반대편에 한 번 더 놓음). manifest `meta.tileable = true`"),
            ("빛 원", "192·384·768 정사각, 색마다 프레임. 가산(또는 스크린) 합성용"),
            ("가림막·전환", "2560×1440(배경 크기와 같음)"),
            ("화풍", "V1 팔레트 색, 스타일 `overlay`(슈퍼샘플 1, 선·테두리 없음). 반복 무늬에는 이어지지 않는 잡음(얼룩·붓자국)을 쓰지 않음"),
        ],
        "extra_tools": ["추가 `tile_preview.py`: 이음 무늬를 2×2로 붙여 이음새를, 빛·가림막을 체커 위에서 투명도를 보는 확인 시트."],
        "rebuild": ["py -3 -B gen_overlays.py --stage all", "py -3 -B build.py --all",
                    "py -3 -B tile_preview.py --out ../preview/overlays_all.png"],
        "sheets": [],
    },
}

# list-ID -> recipe assets, for list rows that are made of several recipes
MULTI = {
    "ui_gauge": ["ui_gauge_frame", "ui_gauge_fill"],
    "ov_light_circle": ["ov_light_circle_s", "ov_light_circle_m", "ov_light_circle_l"],
    "ov_light_circle_color": ["ov_light_circle_color_s", "ov_light_circle_color_m", "ov_light_circle_color_l"],
    "ui_scrollbar": ["ui_scrollbar_track", "ui_scrollbar_thumb"],
}
SKIPPED: dict = {}   # list-ID -> reason

QA_NOTES = {
    "g01-icons-v01": {
        "A": [
            "모아 보기 3장(`preview/review_A1.png`, `review_A2.png`, `review_A3.png`)과 시트(`review_A_sheet.png`)를 2배·1배로 봤다.",
            "열쇠: 처음엔 `club` 아이콘 모양이 그대로 보이고 쇠색이 바탕에 묻혔다 → 고리 + 작은 원 셋으로 다시 짜고 강철색 + 녹 얼룩으로 바꿈(1회 수정).",
            "흉갑: 큰 판에 하이라이트가 얼룩처럼 번졌다 → 명암 하이라이트 0.75→0.3, 볼록함 0.75(1회).",
            "장궁: 몸통이 너무 가늘어 1배에서 선처럼 보였다 → 두께 8→10(1회).",
            "상태 기절: 별이 어두운 금색이라 바탕에 묻혔다 → 별을 키우고 밝은 속별을 겹침(1회).",
            "나머지(물약 3, 금화, 두루마리, 빵, 장검, 단검, 도끼, 지팡이, 방패, 투구, 스킬 4, 상태 4)는 첫 결과 그대로.",
        ],
    },
    "g01-ui-v01": {
        "A": [
            "`preview/nine_A.png`(원본·늘린 모습), `review_A_ui_misc.png`, `review_A_ui_fix.png`를 봤다. 9칸을 늘려도 변에 이음새·찌그러짐이 없다.",
            "버튼: V1 명암의 거친 경계가 버튼 판에서 얼룩처럼 보였다 → 버튼 판만 명암 경계 잡음·볼록함을 낮춤(1회).",
            "말풍선: 바탕 판 명암 얼룩을 같은 방법으로 줄이고, 튀어나오는 프레임 크기 1.12→1.08(캔버스 위쪽 잘림 방지)(1회).",
            "손가락 커서: 손가락이 가늘고 손 모양이 약했다 → 검지를 굵게, 접은 손가락 3개·마디 선을 다시 짬(1회).",
        ],
    },
    "g01-fx-v01": {
        "A": [
            "`preview/review_A_fx.png`(7개 × 5프레임)와 `review_A_fx_fix.png`를 어두운 바탕에서 봤다.",
            "찌르기: 4·5프레임 고리가 칸 오른쪽·위쪽에서 잘렸다 → 끝점을 (150,42)→(140,52), 5프레임 고리 100→88(1회).",
            "낙뢰: 땅 섬광이 칸 아래쪽에서 잘렸다 → 착지점 y 168→156(1회).",
            "얼음 파편: 5프레임 안개가 회색 덩어리처럼 무거웠다 → 흐림 6→10, 투명도 약 절반(1회).",
            "베기, 둔기 타격, 화염 폭발, 치유 빛은 첫 결과 그대로.",
        ],
    },
    "g01-overlays-v01": {
        "A": [
            "`preview/overlays_A.png`: 안개는 2×2로 붙여 이음새가 없는지, 빛 원·가림막은 체커 위에서 투명도가 부드럽게 빠지는지 봤다. 고친 것 없음.",
        ],
    },
}

WEAK = {
    "g01-icons-v01": [
        "V1 명암은 둥근 덩어리를 전제로 해서, 칼날처럼 평평한 금속도 약간 볼록하게 보인다.",
        "금화 더미의 동전 옆면은 블록 돌출이라 아주 얇게만 보인다.",
    ],
    "g01-ui-v01": [
        "9칸의 변에 붓자국·얼룩이 조금 있어 아주 길게 늘리면 결이 길쭉해진다(stretch 대신 tile 모드로 쓰면 덜하다).",
    ],
    "g01-fx-v01": [
        "프레임 사이 움직임은 5장이라 거칠다. 게임에서 프레임당 2~3틱으로 재생하는 것을 전제로 했다.",
    ],
    "g01-overlays-v01": [
        "안개 농도는 어두운 V1 바닥 기준으로 낮게 잡았다. 밝은 장면에서는 불투명도를 올려 써야 한다.",
    ],
}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def recipes(job: str):
    out = []
    for rp in sorted((JOBS_ASSETS / job / "recipes").glob("*.json")):
        if rp.name.startswith(("_", "palette_", "scene_")):
            continue
        rec = json.loads(rp.read_text(encoding="utf-8"))
        frames = [f["name"] for f in rec.get("frames") or [{"name": rec["asset"]}]]
        built = all((JOBS_ASSETS / job / "output" / rec["asset"] / f"{n}.png").exists() for n in frames)
        out.append({"asset": rec["asset"], "stage": (rec.get("meta") or {}).get("stage", "?"), "note": rec.get("note", ""),
                    "canvas": rec["canvas"], "frames": frames, "built": built})
    return out


def stage_order(r):
    return ({"A": 0, "B": 1, "C": 2}.get(r["stage"], 9), r["asset"])


def write_job(job: str, cfg: dict):
    recs = sorted(recipes(job), key=stage_order)
    ddir = JOBS_DOCS / job
    ddir.mkdir(parents=True, exist_ok=True)
    stages_done = {s for s in "ABC" if any(r["stage"] == s for r in recs) and all(r["built"] for r in recs if r["stage"] == s)}
    lines = [f"# {job} — {cfg['title']}", "",
             "상태: **candidate.** 승인·반려는 사용자만 한다. 게임 코드·씬에는 연결하지 않았다.", "",
             "## 근거", "",
             "- 규칙: `docs/art/mass_production/GENERIC.md`(g01 담당: BS2 목록 보강 + 판타지 계열·장르 없는 아이콘·UI·효과·겹침 무늬), `COMMON.md`(그리는 규칙, 크기 통일, V1 기준 도구·팔레트).",
             "- 목록: `docs/art/projects/generic/catalog/g01_list.md`(A → B → C).",
             "- BS2: 이 컴퓨터에 BLACK SOULS II가 없어 보강은 건너뛰었다. `g01_bs2_inventory.md`의 g01 몫(아이콘 세트, 창틀·게이지 바탕·커서·감정 말풍선·전투 시작 전환, 칼·화살·소환·불꽃놀이·선 긋기·특수기·마법진, 안개·잡음·낙엽·거품·햇살·빛 원·시야 밖 어둠)은 전부 목록에 넣었다.",
             "- 그림은 at-icons 모양을 잘라 겹친 조합으로만 만들었다. 글자·숫자·워터마크·원작 고유 요소 없음.", "",
             "## 규격", "", "| 항목 | 값 |", "|---|---|"]
    lines += [f"| {k} | {v} |" for k, v in cfg["spec"]]
    lines += ["| 색 | `recipes/palette_g01.json` = V1 `palette_h0_mood.json`의 모든 항목 그대로 + g01 추가 재질·색·스타일(금속, 물약, 보석, 음식, 천, 판 색, 효과 빛) |", ""]
    lines += ["## 자산", "", "| 단계 | 자산 | 크기·프레임 | 설명 | 상태 |", "|---|---|---|---|---|"]
    for r in recs:
        fr = f"{r['canvas'][0]}×{r['canvas'][1]}" + (f" × {len(r['frames'])}" if len(r["frames"]) > 1 else "")
        lines.append(f"| {r['stage']} | `{r['asset']}` | {fr} | {r['note']} | {'완료' if r['built'] else '대기'} |")
    lines += ["", "## 결과 파일", "",
              f"- `assets/art/generic/jobs/{job}/output/<asset>/<frame>.png` + `<frame>.json`(manifest: status candidate, 쓴 아이콘과 SHA-256, meta).",
              f"- 여러 프레임 자산은 `<asset>_sheet.png`(한 줄) + `<asset>_sheet.json`."]
    for s in cfg["sheets"]:
        lines.append(f"- `assets/art/generic/jobs/{job}/{s}`")
    lines += [f"- 확인용 모아 보기: `assets/art/generic/jobs/{job}/preview/`", "",
              "## 도구", "", "V1 `h0-icon-mood-v02/tool` 전체(__pycache__ 제외)와 `palette_h0_mood.json`을 복사했다. 바꾼 점:", ""]
    lines += [f"- {t}" for t in TOOL_CHANGES + cfg["extra_tools"]]
    lines += ["", "다시 만들기(`tool` 폴더에서):", "", "```"] + cfg["rebuild"] + ["```", "", "## 진행", ""]
    for s in "ABC":
        n = sum(1 for r in recs if r["stage"] == s)
        mark = "x" if s in stages_done else " "
        lines.append(f"- [{mark}] {s} 단계 ({n}개 레시피)")
    (ddir / "JOB.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

    inputs = {"job_id": job, "status": "candidate", "hashes_taken": str(date.today()),
              "read_only_inputs": [{"path": p, "sha256": sha(ROOT / p), "role": role} for p, role in READ_ONLY],
              "shape_source": "addons/at-icons/node2d SVG icons (MIT, Valentin Fossati & contributors)",
              "bs2_reference": {"installed_on_this_computer": False,
                                "searched": "Steam library folders, C:/ and D:/ game and user folders (depth 4)",
                                "use": "none - the g01 share of g01_bs2_inventory.md was taken as it is"},
              "generator": f"assets/art/generic/jobs/{job}/tool/{cfg['gen']}"}
    (ddir / "inputs.json").write_text(json.dumps(inputs, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")

    qa = [f"# {job} QA", "", "전부 candidate. 승인·반려는 사용자만 한다. 확인은 모아 보기 시트를 read 도구로 직접 보고, 이상한 것만 고쳤다(자산당 최대 2번).", ""]
    for s in "ABC":
        notes = QA_NOTES.get(job, {}).get(s)
        if notes:
            qa += [f"## {s} 단계", ""] + [f"- {n}" for n in notes] + [""]
    qa += ["## 아쉬운 점", ""] + [f"- {w}" for w in WEAK.get(job, [])]
    (ddir / "QA.md").write_text("\n".join(qa) + "\n", encoding="utf-8")
    return recs


def update_list(all_recs):
    built = {r["asset"]: r["built"] for r in all_recs}
    text = LIST.read_text(encoding="utf-8")
    out = []
    for line in text.splitlines():
        m = re.match(r"^\| (\d+) \|(.*)\| (대기|완료|건너뜀) \|$", line)
        if m:
            cells = [c.strip() for c in line.strip("|").split("|")]
            asset_id = cells[2]
            members = MULTI.get(asset_id, [asset_id])
            if asset_id in SKIPPED:
                state = "건너뜀"
            elif all(built.get(a, False) for a in members):
                state = "완료"
            else:
                state = "대기"
            line = line[: line.rfind("|", 0, len(line) - 1)] + f"| {state} |"
        out.append(line)
    LIST.write_text("\n".join(out) + "\n", encoding="utf-8")


def main() -> int:
    all_recs = []
    for job, cfg in JOBS.items():
        if (JOBS_ASSETS / job / "recipes").exists():
            all_recs += write_job(job, cfg)
    update_list(all_recs)
    done = sum(1 for r in all_recs if r["built"])
    print(f"docs written for {len(JOBS)} jobs; recipes built {done}/{len(all_recs)}; list updated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
