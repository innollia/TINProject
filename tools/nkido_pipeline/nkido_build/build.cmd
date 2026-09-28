@echo off
REM ---------------------------------------------------------------------------
REM Build nkido on Windows. Kept in the repository so the tool can be rebuilt
REM from the repository alone, without anyone remembering the session that
REM worked it out.
REM
REM Do NOT build this with MSVC. It links, it launches, `akkado --help` works --
REM and then every non-empty patch kills the compiler with 0xC0000409. The
REM akkado front end asks malloc for 0x0102011600000037 bytes (about 66 PB),
REM where the low 32 bits are a real count and the high 32 bits are neighbouring
REM memory. clang-cl does not have the problem. See music/PIPELINE_REVIEW.md 3-1.
REM
REM Prerequisites (winget):
REM   Microsoft.VisualStudio.2022.BuildTools  (--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended)
REM   Kitware.CMake
REM   Ninja-build.Ninja
REM   ShiningLight.OpenSSL.Dev   <- Dev, not Light. Light ships no headers.
REM   LLVM.LLVM
REM   plus SDL2-devel-<ver>-VC.zip from libsdl.org
REM
REM Expect roughly 10-15 minutes. The path below is where the clone is expected
REM to live; change CLONE if yours is elsewhere.
REM ---------------------------------------------------------------------------
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul
set "PATH=C:\Program Files\LLVM\bin;%PATH%"

set "CLONE=C:\projects\_tools\nkido"
set "DEPS=C:\projects\_tools\deps"
set "LOGDIR=%TEMP%"
cd /d "%CLONE%"

REM Nothing here may contain a space: CMake splits -D on whitespace and
REM "C:\Program Files\OpenSSL-Win64" silently breaks find_package(OpenSSL).
if not exist "%DEPS%\openssl\lib" (
    echo copying OpenSSL headers and libs out of the Program Files tree
    mkdir "%DEPS%\openssl"
    xcopy /E /I /Q "C:\Program Files\OpenSSL-Win64\include" "%DEPS%\openssl\include" >nul
    xcopy /E /I /Q "C:\Program Files\OpenSSL-Win64\lib" "%DEPS%\openssl\lib" >nul
)

cmake -S . -B build-clang -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_C_COMPILER=clang-cl ^
  -DCMAKE_CXX_COMPILER=clang-cl ^
  -DNKIDO_BUILD_TESTS=OFF ^
  -DCEDAR_BUILD_BENCH=OFF ^
  -DCEDAR_ENABLE_FILE_IO=ON ^
  "-DOPENSSL_ROOT_DIR=%DEPS%/openssl" ^
  -DOPENSSL_USE_STATIC_LIBS=OFF ^
  "-DSDL2_DIR=%DEPS%/sdl2/SDL2-2.32.10/lib/cmake/SDL2" ^
  "-DCMAKE_PREFIX_PATH=%DEPS%/sdl2/SDL2-2.32.10" ^
  -DCMAKE_CXX_FLAGS="/EHsc /utf-8 /D__PRFCHWINTRIN_H /FI std_bit_shim.h -Wno-unknown-warning-option" ^
  -DCMAKE_C_FLAGS="/EHsc /utf-8 /D__PRFCHWINTRIN_H -Wno-unknown-warning-option" ^
  > "%LOGDIR%\nkido_clang_configure.log" 2>&1
echo CONFIGURE EXIT %ERRORLEVEL%
if not "%ERRORLEVEL%"=="0" exit /b 1

cmake --build build-clang --target nkido_cli akkado_cli > "%LOGDIR%\nkido_clang_build.log" 2>&1
echo BUILD EXIT %ERRORLEVEL%
if not "%ERRORLEVEL%"=="0" exit /b 1

REM No DLLs beside the exe means the process dies with 0xC0000135 at startup.
copy /Y "%DEPS%\sdl2\SDL2-2.32.10\lib\x64\SDL2.dll" "build-clang\bin\" >nul
copy /Y "C:\Program Files\OpenSSL-Win64\bin\libcrypto-4-x64.dll" "build-clang\bin\" >nul
copy /Y "C:\Program Files\OpenSSL-Win64\bin\libssl-4-x64.dll" "build-clang\bin\" >nul

echo binaries are in "%CLONE%\build-clang\bin"
echo sanity: nkido.exe check on any .akkado file must exit 0
exit /b 0
