"""분신 작업 단계를 차례로 돌린다.

  python _bg.py _pipeline.py pipe                           → 기본: model ask gold compare
  python _bg.py _pipeline.py jev jregrade jgold jcompare    → Jev만 쓰는 채점(LLM 토큰 안 씀)
단계마다 창 없는 콘솔·새 프로세스 그룹에서 돌린다. 한 단계가 Ctrl+C류 신호로 끊겨도 다음 단계는 돈다.
"""
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
STEPS = {
    "model": ["build_model.py", "--domains", "그림"],
    "ask": ["ask.py", "--n", "12"],
    "gold": ["eval_gold.py", "--name", "v2-llm", "--n", "80"],
    "compare": ["compare_runs.py", "v1", "v2-llm"],
    "jregrade": ["eval_gold.py", "--regrade", "v2-llm", "--grader", "jev"],
    "jgold": ["eval_gold.py", "--name", "v2-jev-jg", "--n", "80", "--with-options", "--grader", "jev"],
    "jcompare": ["compare_runs.py", "v2-llm-jg", "v2-jev-jg"],
}
DEFAULT = ["model", "ask", "gold", "compare"]
ENV = {"gold": {"JEV_DISABLE": "1"}, "jgold": {"JEV_NO_FALLBACK": "1"}}
FLAGS = (0x08000000 | 0x00000200) if os.name == "nt" else 0  # CREATE_NO_WINDOW | CREATE_NEW_PROCESS_GROUP

for name in sys.argv[1:] or DEFAULT:
    t = time.time()
    rc = subprocess.run([sys.executable, "-u", "-X", "utf8", *STEPS[name]], cwd=HERE,
                        env=dict(os.environ, **ENV.get(name, {})), stdin=subprocess.DEVNULL,
                        stdout=sys.stdout, stderr=sys.stderr, creationflags=FLAGS).returncode
    print(f"[pipeline] {name} rc={rc} {time.time() - t:.0f}s", flush=True)
