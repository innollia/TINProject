"""그림 분야 규칙 다시 만들기 → A/B 질문 → 시험지 채점(LLM 기준선) → v1과 비교를 차례로 돌린다.

  python _bg.py _pipeline.py pipe     → 진행 로그 ../raw/pipe.log, 끝나면 ../raw/pipe.done
"""
import os
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
STEPS = [
    (["build_model.py", "--domains", "그림"], {}),
    (["ask.py", "--n", "12"], {}),
    (["eval_gold.py", "--name", "v2-llm", "--n", "80"], {"JEV_DISABLE": "1"}),
    (["compare_runs.py", "v1", "v2-llm"], {}),
]
for args, extra_env in STEPS:
    t = time.time()
    rc = subprocess.run([sys.executable, "-u", "-X", "utf8", *args], cwd=HERE,
                        env=dict(os.environ, **extra_env), stdout=sys.stdout, stderr=sys.stderr).returncode
    print(f"[pipeline] {' '.join(args)} rc={rc} {time.time() - t:.0f}s", flush=True)
