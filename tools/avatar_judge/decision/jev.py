"""Jev(TypeSafe System One) 어댑터.

Jev는 글을 만들지 않고, state + 타입 질문(noul/choice/score)에 확률을 붙여 답한다.
키가 있으면 Jev를 부르고, 없거나 서버가 거절하면 부른 쪽(decide.py)이 LLM으로 넘어간다.

키: 환경변수 TYPESAFE_API_KEY(또는 JEV_API_KEY)를 먼저 보고, 없으면 ../raw/jev_key.txt를 읽는다.
raw/는 git에 올라가지 않는다. JEV_DISABLE=1이면 키가 있어도 Jev를 쓰지 않는다(LLM과 비교 채점용).
주소: 기본 https://api.typesafe.ai. 중개 서비스 키면 JEV_BASE_URL(또는 JEV_ENDPOINT 전체 주소)로 바꾼다.

공식 형식(https://docs.typesafe.ai/api, 2026-09-28 확인):
  요청 {"model": "jev-latest", "state": 글|객체, "questions": {id: 질문}}
    noul   {"type": "noul", "instructions": ..., "criteria": {"true": ..., "false": ...}}  criteria는 선택
    choice {"type": "choice", "instructions": ..., "criteria": {선택지: 설명|null}}   최대 255개
    score  {"type": "score", "instructions": ..., "criteria": [낮은 단계, ..., 높은 단계]}  2~10단계
  응답 {"model": ..., "answers": {id: 답}, "usage": {...}}
    noul   {"noul": 0~1}  yes일 확률. confidence 칸은 없다.
    choice {"choice", "probabilities", "confidence"}
    score  {"score": 0~(단계수-1) 사이 실수, "legend", "probabilities", "confidence"}
"""
import json
import os
import time
import urllib.error
import urllib.request

BASE = os.environ.get("JEV_BASE_URL", "https://api.typesafe.ai").rstrip("/")
ENDPOINT = os.environ.get("JEV_ENDPOINT", BASE + "/v1/systemone")
MODELS_URL = BASE + "/v1/models"
MODEL = os.environ.get("JEV_MODEL", "jev-latest")
KEY_FILE = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "raw", "jev_key.txt")


def _load_key():
    if os.environ.get("JEV_DISABLE"):
        return ""
    key = (os.environ.get("TYPESAFE_API_KEY") or os.environ.get("JEV_API_KEY") or "").strip()
    if not key and os.path.exists(KEY_FILE):
        with open(KEY_FILE, encoding="utf-8") as f:
            key = f.read().strip()
    return key


KEY = _load_key()
LAST_ERROR = ""
_rejected = False  # 서버가 키를 거절하면(401/403) 이번 실행 동안 더 부르지 않는다.

VERDICT_LEVELS = [
    "clear reject: common, stiff, a knockoff of a reference, or mass-produced",
    "leaning reject: only one or two parts are good",
    "borderline: neither a pass nor a reject",
    "leaning pass: the core is new but needs polish",
    "clear pass: a never-seen core verb or structure, soft and springy motion",
]
VERDICT_QUESTIONS = {
    "verdict": {"type": "noul",
                "instructions": "Would innollia approve the work described under [판정할 대상/상황]? "
                                "Base it on his rules under [형님 판단 규칙] and his past verdicts under [비슷한 과거 판정].",
                "criteria": {"true": "he approves it", "false": "he rejects it"}},
    "score": {"type": "score",
              "instructions": "Where does the work under [판정할 대상/상황] sit on innollia's scale? "
                              "He weighs originality, structural variety, soft physical motion, and not copying a reference.",
              "criteria": VERDICT_LEVELS},
}


def available():
    return bool(KEY) and not _rejected


def _request(url, body=None, timeout=30):
    headers = {"Authorization": f"Bearer {KEY}"}
    if body is not None:
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=body, method="GET" if body is None else "POST", headers=headers)
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.loads(r.read().decode("utf-8"))


def _detail(e):
    try:
        return e.read().decode("utf-8", "replace")[:1000]
    except Exception:
        return ""


def ask(state, questions, timeout=30, retries=3):
    """반환: answers 맵 {id: 답}. 실패하면 None이고 이유는 LAST_ERROR에 남긴다."""
    global LAST_ERROR, _rejected
    if not available():
        LAST_ERROR = LAST_ERROR or "키 없음"
        return None
    body = json.dumps({"model": MODEL, "state": state, "questions": questions},
                      ensure_ascii=False).encode("utf-8")
    for attempt in range(retries):
        try:
            data = _request(ENDPOINT, body, timeout)
            LAST_ERROR = ""
            return data.get("answers") or {}
        except urllib.error.HTTPError as e:
            LAST_ERROR = f"HTTP {e.code}: {_detail(e)}"
            if e.code in (401, 403):
                _rejected = True
                return None
            if e.code in (429, 529) and attempt + 1 < retries:
                try:
                    wait = float(e.headers.get("retry-after") or 0) or 2 ** attempt
                except ValueError:
                    wait = 2 ** attempt
                time.sleep(wait)
                continue
            return None
        except (urllib.error.URLError, TimeoutError, ValueError) as e:
            LAST_ERROR = str(e)
            if attempt + 1 < retries:
                time.sleep(2 ** attempt)
                continue
            return None
    return None


def read_verdict(answers):
    """verdict(noul) + score 답을 판정 모양으로 바꾼다. 점수는 0~100으로 편다."""
    p = float((answers.get("verdict") or {}).get("noul", 0.0))
    s = answers.get("score") or {}
    pts = round(float(s["score"]) / (len(VERDICT_LEVELS) - 1) * 100) if "score" in s else None
    return {"선택": "통과" if p >= 0.5 else "퇴짜", "통과확률": round(p, 3), "점수": pts,
            "확신도": round(max(p, 1 - p), 3), "점수_확신도": s.get("confidence")}


def check_key():
    """키가 먹히는지 본다. 모델 목록 조회라 판정할 내용은 보내지 않는다."""
    if not KEY:
        return False, "키 없음"
    try:
        data = _request(MODELS_URL, timeout=20)
        return True, ", ".join(m.get("name", "?") for m in data.get("models", []))
    except urllib.error.HTTPError as e:
        return False, f"HTTP {e.code}: {_detail(e)}"
    except (urllib.error.URLError, TimeoutError, ValueError) as e:
        return False, str(e)



if __name__ == "__main__":
    import sys
    sys.stdout.reconfigure(encoding="utf-8")
    ok, info = check_key()
    print(("키 됨: " if ok else "키 안 됨: ") + info)
    if ok:
        a = ask("Weather report: the sky is clear and blue, no clouds.",
                {"q": {"type": "noul", "instructions": "Is the sky clear?"},
                 "c": {"type": "choice", "instructions": "Sky color?", "criteria": {"blue": None, "red": None}},
                 "s": {"type": "score", "instructions": "How clear?", "criteria": ["cloudy", "mixed", "clear"]}})
        print("판정 시험: " + (json.dumps(a, ensure_ascii=False) if a else "실패 " + LAST_ERROR))
