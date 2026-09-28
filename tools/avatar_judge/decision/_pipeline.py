"""그림 분야 규칙 다시 만들기 → A/B 질문 → 시험지 채점(LLM 기준선) → v1과 비교를 차례로 돌린다.

  python _bg.py _pipeline.py pipe                   → 전부. 진행 로그 ../raw/pipe.log, 끝나면 ../raw/pipe.done
  python _bg.py _pipeline.py pipe ask gold compare  → 고른 단계만
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
}
ENV = {"gold": {"JEV_DISABLE": "1"}}
FLAGS = (0x08000000 | 0x00000200) if os.name == "nt" else 0  # CREATE_NO_WINDOW | CREATE_NEW_PROCESS_GROUP

for name in sys.argv[1:] or list(STEPS):
    t = time.time()
    rc = subprocess.run([sys.executable, "-u", "-X", "utf8", *STEPS[name]], cwd=HERE,
                        env=dict(os.environ, **ENV.get(name, {})), stdin=subprocess.DEVNULL,
                        stdout=sys.stdout, stderr=sys.stderr, creationflags=FLAGS).returncode
    print(f"[pipeline] {name} rc={rc} {time.time() - t:.0f}s", flush=True)
