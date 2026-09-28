@echo off
REM Link the akkado bad-allocation probe against a built nkido. Run this only
REM when you are re-checking PIPELINE_REVIEW.md 3-1; the answer is already
REM recorded there. See badalloc_probe.cpp for what each case means.
REM
REM   nkido_build\probe.cmd            uses the clang-cl build
REM   nkido_build\probe.cmd release    uses the MSVC build, to confirm it differs
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul
cd /d "%~dp0"

set "CLONE=C:\projects\_tools\nkido"
if /I "%~1"=="release" (
  set "LIBDIR=%CLONE%\build-akkado\release"
  set "LIBFLAGS=/MD"
) else (
  set "LIBDIR=%CLONE%\build-clang"
  set "LIBFLAGS=/MD"
)

if not exist "%LIBDIR%\akkado\Release\akkado.lib" (
  echo no MSVC import libs here. Build the clang-cl tree and copy akkado.lib and
  echo cedar.lib into "%LIBDIR%\akkado\Release" and "%LIBDIR%\cedar\Release" first.
  exit /b 1
)

cl /nologo /EHsc /std:c++20 %LIBFLAGS% /O2 /utf-8 ^
   /FI "%~dp0std_bit_shim.h" ^
   /I "%CLONE%\akkado\include" ^
   /I "%CLONE%\cedar\include" ^
   /I "%CLONE%\third_party\frozen\include" ^
   badalloc_probe.cpp ^
   /link /LIBPATH:"%LIBDIR%\akkado\Release" /LIBPATH:"%LIBDIR%\cedar\Release" ^
   akkado.lib cedar.lib /PDB:badalloc_probe.pdb
if errorlevel 1 exit /b 1

echo.
for %%C in (1 2 3) do badalloc_probe.exe %%C
