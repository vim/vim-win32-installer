@echo off

setlocal

set "DEST=%~1"
set "VIMSRC=%~2"
set "DIFFEXE=%~3"
set "GETTEXT_TOP=%~4"
set "ARCH=%~5"

set "GETTEXT_DIR=%GETTEXT_TOP%\gettext"
set "GETTEXT32_DIR=%GETTEXT_TOP%\gettext32"
set "GETTEXT64_DIR=%GETTEXT_TOP%\gettext64"

md "%DEST%"

:: Assuming GvimExt{32,64} exist in %VIMSRC%\runtime
robocopy "%VIMSRC%\runtime" "%DEST%" /E /NP /NFL /NDL
if ERRORLEVEL 8 exit /b 1

copy "%VIMSRC%\src\*vim*.exe" "%DEST%" || exit /b 1
copy "%VIMSRC%\src\vim*.dll"  "%DEST%" || exit /b 1
copy "%VIMSRC%\src\tee\*.exe" "%DEST%" || exit /b 1
copy "%VIMSRC%\src\xxd\*.exe" "%DEST%" || exit /b 1
copy "%VIMSRC%\src\libsodium.dll" "%DEST%" || exit /b 1
copy "%VIMSRC%\src\winpty*"   "%DEST%" || exit /b 1
copy "%VIMSRC%\README.txt"    "%DEST%" || exit /b 1
copy "%VIMSRC%\LICENSE"       "%DEST%\LICENSE.txt" || exit /b 1
copy "%VIMSRC%\uninstall.txt" "%DEST%" || exit /b 1
copy "%VIMSRC%\vimtutor.bat"  "%DEST%" || exit /b 1
copy "%VIMSRC%\src\vim.ico"   "%DEST%" || exit /b 1
copy "%VIMSRC%\src\install.exe" "%DEST%" || exit /b 1
copy "%VIMSRC%\src\uninstall.exe" "%DEST%" || exit /b 1
copy "%DIFFEXE%\diff.exe"     "%DEST%" || exit /b 1
rem copy "%LUA_DIR%\lua*.dll"   "%DEST%" || exit /b 1

:: Copy gettext for (g)vim.exe
copy %GETTEXT_DIR%\libiconv-2.dll %DEST% || exit /b 1
copy %GETTEXT_DIR%\libintl-8.dll  %DEST% || exit /b 1
:: Check if libgcc_s_*.dll is required
set INCLUDE_LIBGCC=0
if NOT "%ARCH%"=="arm64" (
  dumpbin /DEPENDENTS %GETTEXT32_DIR%\libintl-8.dll | findstr /R "libgcc_s_.*\.dll" && set INCLUDE_LIBGCC=1
)
if "%ARCH%"=="x86" (
  if "%INCLUDE_LIBGCC%" EQU 1 (
    if exist %GETTEXT_DIR%\libgcc_s_sjlj-1.dll (
      copy %GETTEXT_DIR%\libgcc_s_sjlj-1.dll %DEST% || exit /b 1
    )
  )
)

:: Copy gettext for GvimExt64
copy %GETTEXT64_DIR%\libiconv-2.dll %DEST%\GvimExt64 || exit /b 1
copy %GETTEXT64_DIR%\libintl-8.dll  %DEST%\GvimExt64 || exit /b 1
:: Copy gettext for GvimExt32
if NOT "%ARCH%"=="arm64" (
  copy %GETTEXT32_DIR%\libiconv-2.dll %DEST%\GvimExt32 || exit /b 1
  copy %GETTEXT32_DIR%\libintl-8.dll  %DEST%\GvimExt32 || exit /b 1
  if "%INCLUDE_LIBGCC%" EQU 1 (
    if exist %GETTEXT32_DIR%\libgcc_s_sjlj-1.dll (
      copy %GETTEXT32_DIR%\libgcc_s_sjlj-1.dll %DEST%\GvimExt32 || exit /b 1
    )
  )
)

endlocal & (
  set "INCLUDE_LIBGCC=%INCLUDE_LIBGCC%"
)
