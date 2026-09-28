"""뒤에서 도는 분신 작업을 프로세스 트리째 끈다(_bg 래퍼 → _pipeline → eval_gold 등 → kiro-cli).

  python -X utf8 stop_bg.py    → 끈 프로세스를 ../raw/_stop.txt에 적는다(명령줄 내용은 안 적음)
이 폴더의 _bg.py·_pipeline.py가 띄운 작업만 고른다. 다른 세션이나 KiroCrew 프로세스는 건드리지 않는다.
"""
import json
import os
import re
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
REPORT = os.path.join(os.path.dirname(HERE), "raw", "_stop.txt")
CHILD = re.compile(r"-u -X utf8 (_pipeline|eval_gold|build_model|ask|compare_runs)\.py")


def procs():
    ps = ("[Console]::OutputEncoding=[Text.Encoding]::UTF8; Get-CimInstance Win32_Process | "
          "Select-Object ProcessId,ParentProcessId,Name,CommandLine | ConvertTo-Json -Compress")
    out = subprocess.run(["powershell", "-NoProfile", "-Command", ps], capture_output=True,
                         encoding="utf-8", errors="replace").stdout
    data = json.loads(out or "[]")
    return {p["ProcessId"]: p for p in (data if isinstance(data, list) else [data])}


def is_root(p):
    cmd = p.get("CommandLine") or ""
    wrapper = "import subprocess,sys;lo=open(" in cmd and "avatar_judge" in cmd
    return wrapper or bool(CHILD.search(cmd))


def main():
    table = procs()
    mine, pid = set(), os.getpid()
    while pid in table and pid not in mine:  # 이 스크립트와 그 부모 줄은 빼고 끈다
        mine.add(pid)
        pid = table[pid].get("ParentProcessId")
    kids = {}
    for p in table.values():
        kids.setdefault(p.get("ParentProcessId"), []).append(p["ProcessId"])
    targets, stack = set(), [p for p, v in table.items() if is_root(v) and p not in mine]
    while stack:
        p = stack.pop()
        if p in targets or p in mine:
            continue
        targets.add(p)
        stack += kids.get(p, [])
    for p in sorted(targets):
        subprocess.run(["taskkill", "/PID", str(p), "/T", "/F"], capture_output=True)
    left = set(procs()) & targets
    lines = [f"끈 것 {len(targets) - len(left)}개, 남은 것 {len(left)}개"]
    lines += [f"{p} {table[p].get('Name')}{' (남음)' if p in left else ''}" for p in sorted(targets)]
    with open(REPORT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(lines[0])


if __name__ == "__main__":
    main()
