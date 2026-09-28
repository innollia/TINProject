"""Jev(TypeSafe System One) 최소 클라이언트. 파이썬 표준 라이브러리만 쓴다.

  python jevlib.py   → 키 확인(모델 목록 조회) + 날씨 문장으로 판정 호출 1번 + 데이터 폴더 위치
형식 근거: https://docs.typesafe.ai/api (2026-09-28 확인)
  요청 {"model", "state": 글|객체, "questions": {id: {"type": "noul"|"choice"|"score", "instructions", "criteria"}}}
  응답 {"model", "answers": {id: 답}, "usage"}
"""
import json
import os
import sys
import time
import urllib.error
import urllib.request

SKILL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = os.environ.get("JEV_BASE_URL", "https://api.typesafe.ai").rstrip("/")
MODEL = os.environ.get("JEV_MODEL", "jev-latest")


class JevError(Exception):
    pass


def data_dir():
    """형님 근거가 든 폴더. AVATAR_JUDGE_DATA → 스킬 폴더의 data_dir.txt → 저장소 안 위치(../..) → ~/.avatar_judge."""
    env = os.environ.get("AVATAR_JUDGE_DATA", "").strip()
    if env:
        return env
    note = os.path.join(SKILL, "data_dir.txt")
    if os.path.exists(note):
        with open(note, encoding="utf-8") as f:
            path = f.read().strip()
        if path:
            return path
    up = os.path.dirname(os.path.dirname(SKILL))
    if os.path.exists(os.path.join(up, "decision", "judgment_model.json")):
        return up
    return os.path.join(os.path.expanduser("~"), ".avatar_judge")


def load_key():
    key = (os.environ.get("TYPESAFE_API_KEY") or os.environ.get("JEV_API_KEY") or "").strip()
    if not key:
        path = os.path.join(data_dir(), "raw", "jev_key.txt")
        if os.path.exists(path):
            with open(path, encoding="utf-8") as f:
                key = f.read().strip()
    return key


def _call(path, body=None, timeout=30):
    key = load_key()
    if not key:
        raise JevError("no key: set TYPESAFE_API_KEY or write <data dir>/raw/jev_key.txt")
    headers = {"Authorization": f"Bearer {key}"}
    if body is not None:
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(BASE + path, data=body, headers=headers,
                                 method="GET" if body is None else "POST")
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.loads(r.read().decode("utf-8"))


def ask(state, questions, retries=3):
    """(answers 맵, 답한 모델 이름)을 돌려준다. 실패하면 JevError."""
    body = json.dumps({"model": MODEL, "state": state, "questions": questions},
                      ensure_ascii=False).encode("utf-8")
    for attempt in range(retries):
        try:
            data = _call("/v1/systemone", body)
            return data.get("answers") or {}, data.get("model", MODEL)
        except urllib.error.HTTPError as e:
            detail = e.read().decode("utf-8", "replace")[:500]
            if (e.code == 429 or e.code >= 500) and attempt + 1 < retries:
                time.sleep(2 ** attempt)
                continue
            raise JevError(f"HTTP {e.code}: {detail}")
        except (urllib.error.URLError, TimeoutError, ValueError) as e:
            if attempt + 1 < retries:
                time.sleep(2 ** attempt)
                continue
            raise JevError(str(e))
    raise JevError("retries exhausted")


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    try:
        names = [m.get("name") for m in _call("/v1/models", timeout=20).get("models", [])]
        print("key ok:", ", ".join(names))
        answers, model = ask("Weather report: clear blue sky, no clouds.",
                             {"q": {"type": "noul", "instructions": "Is the sky clear?"}})
        print("decision ok:", model, (answers.get("q") or {}).get("noul"))
    except urllib.error.HTTPError as e:
        print(f"key rejected: HTTP {e.code}")
    except Exception as e:  # 키 없음, 네트워크 등
        print("error:", e)
    print("data dir:", data_dir())


if __name__ == "__main__":
    main()
