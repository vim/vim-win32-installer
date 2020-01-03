@echo off
:: Batch file for building/testing Vim on AppVeyor

setlocal ENABLEDELAYEDEXPANSION
FOR /f "delims=. tokens=1-3" %%i in ("%APPVEYOR_REPO_TAG_NAME%") do set PATCHLEVEL=%%k

cd %APPVEYOR_BUILD_FOLDER%

if /I "%ARCH%"=="x64" (
  set BIT=64
) else (
  set BIT=32
)

:: ----------------------------------------------------------------------
:: Download URLs, local dirs and versions
:: Lua
set LUA_VER=53
set LUA32_URL=http://downloads.sourceforge.net/luabinaries/lua-5.3.2_Win32_dllw4_lib.zip
set LUA64_URL=http://downloads.sourceforge.net/luabinaries/lua-5.3.2_Win64_dllw4_lib.zip
set LUA_URL=!LUA%BIT%_URL!
set LUA_DIR=C:\Lua
:: Perl
set PERL_VER=528
set PERL32_URL=http://strawberryperl.com/download/5.28.0.1/strawberry-perl-5.28.0.1-32bit-portable.zip
set PERL64_URL=http://strawberryperl.com/download/5.28.0.1/strawberry-perl-5.28.0.1-64bit-portable.zip
set PERL_URL=!PERL%BIT%_URL!
set PERL_DIR=C:\Strawberry\perl
:: Python2
set PYTHON_VER=27
set PYTHON_32_DIR=C:\python%PYTHON_VER%
set PYTHON_64_DIR=C:\python%PYTHON_VER%-x64
set PYTHON_DIR=!PYTHON_%BIT%_DIR!
:: Python3
set PYTHON3_VER=38
set PYTHON3_32_DIR=C:\python%PYTHON3_VER%
set PYTHON3_64_DIR=C:\python%PYTHON3_VER%-x64
set PYTHON3_DIR=!PYTHON3_%BIT%_DIR!
:: Racket
set RACKET_VER=3m_a36fs8
set RACKET32_URL=https://www.cs.utah.edu/plt/installers/6.10.1/racket-minimal-6.10.1-i386-win32.exe
set RACKET64_URL=https://www.cs.utah.edu/plt/installers/6.10.1/racket-minimal-6.10.1-x86_64-win32.exe
set RACKET_URL=!RACKET%BIT%_URL!
set RACKET32_DIR=%PROGRAMFILES(X86)%\Racket
set RACKET64_DIR=%PROGRAMFILES%\Racket
set RACKET_DIR=!RACKET%BIT%_DIR!
set MZSCHEME_VER=%RACKET_VER%
:: Ruby
set RUBY_VER=24
set RUBY_API_VER_LONG=2.4.0
set RUBY_BRANCH=ruby_2_4
set RUBY_URL=https://github.com/ruby/ruby/archive/%RUBY_BRANCH%.zip
set RUBY32_DIR=C:\Ruby%RUBY_VER%
set RUBY64_DIR=C:\Ruby%RUBY_VER%-x64
set RUBY_DIR=!RUBY%BIT%_DIR!
:: Tcl
set TCL_VER_LONG=8.6
set TCL_VER=%TCL_VER_LONG:.=%
set TCL32_URL=http://downloads.activestate.com/ActiveTcl/releases/8.6.6.8607/ActiveTcl-8.6.6.8607-MSWin32-x86-403667.exe
set TCL64_URL=http://downloads.activestate.com/ActiveTcl/releases/8.6.6.8606/ActiveTcl-8.6.6.8606-MSWin32-x64-401995.exe
set TCL_URL=!TCL%BIT%_URL!
set TCL_DIR=C:\Tcl
set TCL_DLL=tcl%TCL_VER%t.dll
set TCL_LIBRARY=%TCL_DIR%\lib\tcl%TCL_VER_LONG%
:: Gettext
set GETTEXT32_URL=https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.19.8.1-v1.15/gettext0.19.8.1-iconv1.15-shared-32.zip
set GETTEXT64_URL=https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.19.8.1-v1.15/gettext0.19.8.1-iconv1.15-shared-64.zip
:: winpty
set WINPTY_URL=https://github.com/rprichard/winpty/releases/download/0.4.3/winpty-0.4.3-msvc2015.zip
:: UPX
set UPX_URL=https://github.com/upx/upx/releases/download/v3.94/upx394w.zip

:: Subsystem version (targeting Windows XP)
set SUBSYSTEM_VER32=5.01
set SUBSYSTEM_VER64=5.02
set SUBSYSTEM_VER=!SUBSYSTEM_VER%BIT%!
:: ----------------------------------------------------------------------

:: Update PATH
path %PYTHON_DIR%;%PYTHON3_DIR%;%PERL_DIR%\bin;%path%;%LUA_DIR%;%RUBY_DIR%\bin;%RUBY_DIR%\bin\ruby_builtin_dlls;%RACKET_DIR%;%RACKET_DIR%\lib

if /I "%1"=="" (
  set target=build
) else (
  set target=%1
)

goto %target%_%ARCH%
echo Unknown build target.
exit 1


:install_x86
:install_x64
:: ----------------------------------------------------------------------
@echo on

:: Get Vim source code
git submodule update --init

:: Apply experimental patches
pushd vim
for %%i in (..\patch\*.patch) do git apply -v %%i
popd

if not exist downloads mkdir downloads

:: Lua
call :downloadfile %LUA_URL% downloads\lua.zip
7z x downloads\lua.zip -o%LUA_DIR% > nul || exit 1

:: Perl
call :downloadfile %PERL_URL% downloads\perl.zip
:: Extract only the "perl" folder.
7z x downloads\perl.zip perl -o%PERL_DIR%\.. > nul || exit 1

:: Tcl
call :downloadfile %TCL_URL% downloads\tcl.exe
mkdir c:\ActiveTclTemp
start /wait downloads\tcl.exe /extract:c:\ActiveTclTemp /exenoui /exenoupdates /quiet /norestart
for /d %%i in (c:\ActiveTclTemp\*) do move %%i %TCL_DIR%
copy %TCL_DIR%\bin\%TCL_DLL% vim\src\

:: Ruby
:: RubyInstaller is built by MinGW, so we cannot use header files from it.
:: Download the source files and generate config.h for MSVC.
rem git clone https://github.com/ruby/ruby.git -b %RUBY_BRANCH% --depth 1 -q ../ruby
call :downloadfile %RUBY_URL% downloads\ruby.zip
:: Extract the files only we needed to reduce the building time.
:: We need to use `^^` to escape `!` because we enable delayed expansion.
7z x downloads\ruby.zip */bin */enc/Makefile.in */win32 */common.mk -ir^^!version.h -xr^^!README.* -xr^^!*/win32/*.c -xr^^!*/win32/*.h -o.. > nul || exit 1
move ..\ruby-%RUBY_BRANCH% ..\ruby > nul || exit 1
pushd ..\ruby
call win32\configure.bat
echo on
nmake .config.h.time || exit 1
xcopy /s .ext\include %RUBY_DIR%\include\ruby-%RUBY_API_VER_LONG%
popd

:: Racket
call :downloadfile %RACKET_URL% downloads\racket.exe
start /wait downloads\racket.exe /S

:: Install libintl.dll and iconv.dll
call :downloadfile %GETTEXT32_URL% downloads\gettext32.zip
7z e -y downloads\gettext32.zip -oc:\gettext32 > nul || exit 1
call :downloadfile %GETTEXT64_URL% downloads\gettext64.zip
7z e -y downloads\gettext64.zip -oc:\gettext64 > nul || exit 1

:: Install winpty
call :downloadfile %WINPTY_URL% downloads\winpty.zip
7z x -y downloads\winpty.zip -oc:\winpty > nul || exit 1
if /i "%ARCH%"=="x64" (
	copy /Y c:\winpty\x64_xp\bin\winpty.dll        vim\src\winpty64.dll
	copy /Y c:\winpty\x64_xp\bin\winpty-agent.exe  vim\src\
) else (
	copy /Y c:\winpty\ia32_xp\bin\winpty.dll       vim\src\winpty32.dll
	copy /Y c:\winpty\ia32_xp\bin\winpty-agent.exe vim\src\
)

:: Install UPX
call :downloadfile %UPX_URL% downloads\upx.zip
7z e downloads\upx.zip *\upx.exe -ovim\nsis > nul || exit 1

:: Show PATH for debugging
path

:: Install additional packages for Racket
raco pkg install --auto r5rs-lib

@echo off
goto :eof


:build_x86
:build_x64
:: ----------------------------------------------------------------------
@echo on
cd vim\src

:: Setting for targeting Windows XP
set WinSdk71=%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.1A
set INCLUDE=%WinSdk71%\Include;%INCLUDE%
if /i "%ARCH%"=="x64" (
	set "LIB=%WinSdk71%\Lib\x64;%LIB%"
) else (
	set "LIB=%WinSdk71%\Lib;%LIB%"
)
set CL=/D_USING_V110_SDK71_

:: Replace VIM_VERSION_PATCHLEVEL in version.h with the actual patchlevel
:: Set CHERE_INVOKING to start Cygwin in the current directory
set CHERE_INVOKING=1
c:\cygwin64\bin\bash -lc "sed -i -e /VIM_VERSION_PATCHLEVEL/s/0/$(sed -n -e '/included_patches/{n;n;n;s/ *\([0-9]*\).*/\1/p;q}' version.c)/ version.h"

:: Remove progress bar from the build log
sed -e "s/@<<$/@<< | sed -e 's#.*\\\\r.*##'/" Make_mvc.mak > Make_mvc2.mak
:: Build GUI version
nmake -f Make_mvc2.mak ^
	GUI=yes OLE=yes DIRECTX=yes ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	DYNAMIC_PERL=yes PERL=%PERL_DIR% ^
	DYNAMIC_PYTHON=yes PYTHON=%PYTHON_DIR% ^
	DYNAMIC_PYTHON3=yes PYTHON3=%PYTHON3_DIR% ^
	DYNAMIC_LUA=yes LUA=%LUA_DIR% ^
	DYNAMIC_TCL=yes TCL=%TCL_DIR% ^
	DYNAMIC_RUBY=yes RUBY=%RUBY_DIR% RUBY_MSVCRT_NAME=msvcrt ^
	DYNAMIC_MZSCHEME=yes "MZSCHEME=%RACKET_DIR%" ^
	TERMINAL=yes ^
	|| exit 1
:: Build CUI version
nmake -f Make_mvc2.mak ^
	GUI=no OLE=no DIRECTX=no ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	DYNAMIC_PERL=yes PERL=%PERL_DIR% ^
	DYNAMIC_PYTHON=yes PYTHON=%PYTHON_DIR% ^
	DYNAMIC_PYTHON3=yes PYTHON3=%PYTHON3_DIR% ^
	DYNAMIC_LUA=yes LUA=%LUA_DIR% ^
	DYNAMIC_TCL=yes TCL=%TCL_DIR% ^
	DYNAMIC_RUBY=yes RUBY=%RUBY_DIR% RUBY_MSVCRT_NAME=msvcrt ^
	DYNAMIC_MZSCHEME=yes "MZSCHEME=%RACKET_DIR%" ^
	TERMINAL=yes ^
	|| exit 1
:: Build translations
pushd po
nmake -f Make_mvc.mak GETTEXT_PATH=C:\cygwin\bin VIMRUNTIME=..\..\runtime install-all || exit 1
popd

:check_executable
:: ----------------------------------------------------------------------
start /wait .\gvim -silent -register
start /wait .\gvim -u NONE -c "redir @a | ver | 0put a | wq!" ver.txt
type ver.txt
.\vim --version
:: Print interface versions
start /wait .\gvim -u NONE -S ..\..\if_ver.vim -c quit
type if_ver.txt
@echo off
goto :eof


:package_x86
:package_x64
:: ----------------------------------------------------------------------
@echo on
cd vim\src

mkdir GvimExt64
mkdir GvimExt32
:: Build both 64- and 32-bit versions of gvimext.dll for the installer
start /wait cmd /c ""C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /x64 && cd GvimExt && nmake CPU=AMD64 clean all > ..\gvimext.log"
type gvimext.log
copy GvimExt\gvimext.dll   GvimExt\gvimext64.dll
move GvimExt\gvimext.dll   GvimExt64\gvimext.dll
copy /Y GvimExt\README.txt GvimExt64\
copy /Y GvimExt\*.inf      GvimExt64\
copy /Y GvimExt\*.reg      GvimExt64\
start /wait cmd /c ""C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /x86 && cd GvimExt && nmake CPU=i386 clean all > ..\gvimext.log"
type gvimext.log
copy GvimExt\gvimext.dll   GvimExt32\gvimext.dll
copy /Y GvimExt\README.txt GvimExt32\
copy /Y GvimExt\*.inf      GvimExt32\
copy /Y GvimExt\*.reg      GvimExt32\

:: Create zip packages
7z a ..\..\gvim_%APPVEYOR_REPO_TAG_NAME:~1%_%ARCH%_pdb.zip *.pdb
copy /Y ..\README.txt ..\runtime
copy /Y ..\vimtutor.bat ..\runtime
copy /Y *.exe ..\runtime\
copy /Y xxd\*.exe ..\runtime
copy /Y tee\*.exe ..\runtime
mkdir ..\runtime\GvimExt64
mkdir ..\runtime\GvimExt32
copy /Y GvimExt64\*.*                    ..\runtime\GvimExt64\
copy /Y c:\gettext64\libiconv-2.dll      ..\runtime\GvimExt64\
copy /Y c:\gettext64\libintl-8.dll       ..\runtime\GvimExt64\
copy /Y GvimExt32\*.*                    ..\runtime\GvimExt32\
copy /Y c:\gettext32\libiconv-2.dll      ..\runtime\GvimExt32\
copy /Y c:\gettext32\libintl-8.dll       ..\runtime\GvimExt32\
copy /Y c:\gettext32\libgcc_s_sjlj-1.dll ..\runtime\GvimExt32\
copy /Y ..\..\diff.exe ..\runtime\
copy /Y c:\gettext%BIT%\libiconv-2.dll   ..\runtime\
copy /Y c:\gettext%BIT%\libintl-8.dll    ..\runtime\
if exist c:\gettext%BIT%\libgcc_s_sjlj-1.dll copy /Y c:\gettext%BIT%\libgcc_s_sjlj-1.dll ..\runtime\
copy /Y winpty* ..\runtime\
copy /Y winpty* ..\..\
set dir=vim%APPVEYOR_REPO_TAG_NAME:~1,1%%APPVEYOR_REPO_TAG_NAME:~3,1%
mkdir ..\vim\%dir%
xcopy ..\runtime ..\vim\%dir% /Y /E /V /I /H /R /Q
7z a ..\..\gvim_%APPVEYOR_REPO_TAG_NAME:~1%_%ARCH%.zip ..\vim

:: Create installer
c:\cygwin64\bin\bash -lc "cd $(cygpath '%APPVEYOR_BUILD_FOLDER%')/vim/runtime/doc && touch ../../src/auto/config.mk && make uganda.nsis.txt"
copy gvim.exe gvim_ole.exe
copy vim.exe vimw32.exe
copy tee\tee.exe teew32.exe
copy xxd\xxd.exe xxdw32.exe
copy install.exe installw32.exe
copy uninstall.exe uninstallw32.exe
pushd ..\nsis
7z x icons.zip > nul
if /i "%ARCH%"=="x64" (
	"%ProgramFiles(x86)%\NSIS\makensis" /DVIMRT=..\runtime /DGETTEXT=c: /DWIN64=1 /DPATCHLEVEL=%PATCHLEVEL% gvim.nsi "/XOutFile ..\..\gvim_%APPVEYOR_REPO_TAG_NAME:~1%_%ARCH%.exe"
) else (
	"%ProgramFiles(x86)%\NSIS\makensis" /DVIMRT=..\runtime /DGETTEXT=c: /DPATCHLEVEL=%PATCHLEVEL%  gvim.nsi "/XOutFile ..\..\gvim_%APPVEYOR_REPO_TAG_NAME:~1%_%ARCH%.exe"
)
popd

:: Create zipfile for signing with signpath.io
:: This will create a single zip file that should be uploaded to signpath
:: signpath can then sign each artifact inside the zip file
:: (the Vim zip archive as well as the installer)
echo Creating Signpath Zip Archive
cd %APPVEYOR_BUILD_FOLDER%
7z a unsigned-gvim_%APPVEYOR_REPO_TAG_NAME:~1%_%ARCH%.zip gvim_%APPVEYOR_REPO_TAG_NAME:~1%_%ARCH%.zip gvim*.exe

@echo off
goto :eof


:test_x86
:test_x64
:: ----------------------------------------------------------------------
@echo on
cd vim\src\testdir
nmake -f Make_dos.mak VIMPROG=..\gvim || exit 1
nmake -f Make_dos.mak clean
nmake -f Make_dos.mak VIMPROG=..\vim || exit 1

@echo off
goto :eof


:downloadfile
:: ----------------------------------------------------------------------
:: call :downloadfile <URL> <localfile>
if not exist %2 (
  curl -f -L %1 -o %2 || exit 1
)
@goto :eof
