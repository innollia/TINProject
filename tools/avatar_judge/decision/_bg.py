"""오래 걸리는 스크립트를 detach 백그라운드로 띄운다. Windows에서 확실히 동작.

  python _bg.py build_model.py bm
  -> 로그: ../raw/<tag>.log, ../raw/<tag>.err, 종료 후 ../raw/<tag>.done(종료 코드)

래퍼가 로그 파일을 직접 열어 스크립트에 넘긴다. 예전에는 래퍼 표준 출력만 파일로 돌려서,
DETACHED 래퍼의 손자 프로세스는 출력 핸들을 못 받았고 print와 오류가 전부 사라졌다.
스크립트는 창 없는 콘솔(CREATE_NO_WINDOW)에서 돈다. 보이는 콘솔 창에서 돌면 창이 닫히거나
Ctrl+C류 신호가 오면 종료 코드 3221225786(0xC000013A)으로 끊긴다(2026-09-28 20시 52분에 실제로 끊김).
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "..", "raw")

script = sys.argv[1]
tag = sys.argv[2] if len(sys.argv) > 2 else os.path.splitext(script)[0]
extra = sys.argv[3:]

log = os.path.abspath(os.path.join(RAW, f"{tag}.log"))
err = os.path.abspath(os.path.join(RAW, f"{tag}.err"))
done = os.path.abspath(os.path.join(RAW, f"{tag}.done"))
for f in (done, log, err):
    if os.path.exists(f):
        os.remove(f)

wrapper = (
    "import subprocess,sys;"
    f"lo=open({log!r},'ab');le=open({err!r},'ab');"
    f"rc=subprocess.run([sys.executable,'-u','-X','utf8',{script!r},*{extra!r}],"
    f"cwd={HERE!r},stdin=subprocess.DEVNULL,stdout=lo,stderr=le,creationflags=0x08000000).returncode;"
    "lo.close();le.close();"
    f"open({done!r},'w').write(str(rc))"
)
flags = 0x00000008 | 0x00000200  # DETACHED_PROCESS | CREATE_NEW_PROCESS_GROUP
p = subprocess.Popen([sys.executable, "-c", wrapper], stdin=subprocess.DEVNULL,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                     creationflags=flags, close_fds=True)
print(f"PID={p.pid} tag={tag}")
