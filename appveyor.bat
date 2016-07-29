@echo off
:: Batch file for building/testing Vim on AppVeyor

setlocal ENABLEDELAYEDEXPANSION
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
set PERL_VER=522
set PERL32_URL=http://downloads.activestate.com/ActivePerl/releases/5.22.1.2201/ActivePerl-5.22.1.2201-MSWin32-x86-64int-299574.zip
set PERL64_URL=http://downloads.activestate.com/ActivePerl/releases/5.22.1.2201/ActivePerl-5.22.1.2201-MSWin32-x64-299574.zip
set PERL_URL=!PERL%BIT%_URL!
set PERL_DIR=C:\Perl%PERL_VER%\perl
:: Python2
set PYTHON_VER=27
set PYTHON_32_DIR=C:\python%PYTHON_VER%
set PYTHON_64_DIR=C:\python%PYTHON_VER%-x64
set PYTHON_DIR=!PYTHON_%BIT%_DIR!
:: Python3
set PYTHON3_VER=34
set PYTHON3_32_DIR=C:\python%PYTHON3_VER%
set PYTHON3_64_DIR=C:\python%PYTHON3_VER%-x64
set PYTHON3_DIR=!PYTHON3_%BIT%_DIR!
:: Racket
set RACKET_VER=3m_9zltds
set RACKET32_URL=https://mirror.racket-lang.org/releases/6.4/installers/racket-minimal-6.4-i386-win32.exe
set RACKET64_URL=https://mirror.racket-lang.org/releases/6.4/installers/racket-minimal-6.4-x86_64-win32.exe
set RACKET_URL=!RACKET%BIT%_URL!
set RACKET32_DIR=%PROGRAMFILES(X86)%\Racket
set RACKET64_DIR=%PROGRAMFILES%\Racket
set RACKET_DIR=!RACKET%BIT%_DIR!
set MZSCHEME_VER=%RACKET_VER%
:: Ruby
set RUBY_VER=22
set RUBY_VER_LONG=2.2.0
set RUBY_BRANCH=ruby_2_2
set RUBY32_DIR=C:\Ruby%RUBY_VER%
set RUBY64_DIR=C:\Ruby%RUBY_VER%-x64
set RUBY_DIR=!RUBY%BIT%_DIR!
:: Tcl
set TCL_VER_LONG=8.6
set TCL_VER=%TCL_VER_LONG:.=%
set TCL32_URL=http://downloads.activestate.com/ActiveTcl/releases/8.6.4.1/ActiveTcl8.6.4.1.299124-win32-ix86-threaded.exe
set TCL64_URL=http://downloads.activestate.com/ActiveTcl/releases/8.6.4.1/ActiveTcl8.6.4.1.299124-win32-x86_64-threaded.exe
set TCL_URL=!TCL%BIT%_URL!
set TCL_DIR=C:\Tcl
:: Gettext
set GETTEXT32_URL=https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.19.6-v1.14/gettext0.19.6-iconv1.14-shared-32.exe
set GETTEXT64_URL=https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.19.6-v1.14/gettext0.19.6-iconv1.14-shared-64.exe
set GETTEXT_URL=!GETTEXT%BIT%_URL!
:: UPX
set UPX_URL=http://upx.sourceforge.net/download/upx391w.zip
:: ----------------------------------------------------------------------

:: Update PATH
path %PERL_DIR%\bin;%path%;%LUA_DIR%;%TCL_DIR%\bin;%RUBY_DIR%\bin;%RACKET_DIR%;%RACKET_DIR%\lib

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
:: Work around for Python 2.7.11
reg copy HKLM\SOFTWARE\Python\PythonCore\2.7 HKLM\SOFTWARE\Python\PythonCore\2.7-32 /s /reg:32
reg copy HKLM\SOFTWARE\Python\PythonCore\2.7 HKLM\SOFTWARE\Python\PythonCore\2.7-32 /s /reg:64

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
7z x downloads\perl.zip -oC:\ > nul || exit 1
for /d %%i in (C:\ActivePerl*) do move %%i C:\Perl%PERL_VER%

:: Tcl
call :downloadfile %TCL_URL% downloads\tcl.exe
start /wait downloads\tcl.exe --directory %TCL_DIR%

:: Ruby
:: RubyInstaller is built by MinGW, so we cannot use header files from it.
:: Download the source files and generate config.h for MSVC.
git clone https://github.com/ruby/ruby.git -b %RUBY_BRANCH% --depth 1 -q ../ruby
pushd ..\ruby
call win32\configure.bat
echo on
nmake .config.h.time
xcopy /s .ext\include %RUBY_DIR%\include\ruby-%RUBY_VER_LONG%
popd

:: Racket
call :downloadfile %RACKET_URL% downloads\racket.exe
start /wait downloads\racket.exe /S

:: Install libintl.dll and iconv.dll
call :downloadfile %GETTEXT_URL% downloads\gettext.exe
start /wait downloads\gettext.exe /verysilent /dir=c:\gettext
:: libwinpthread is needed on Win64 for localizing messages
::copy c:\gettext\libwinpthread-1.dll ..\runtime

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
:: Remove progress bar from the build log
sed -e "s/\$(LINKARGS2)/\$(LINKARGS2) | sed -e 's#.*\\\\r.*##'/" Make_mvc.mak > Make_mvc2.mak
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
	WINVER=0x500 ^
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
	WINVER=0x500 ^
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

:: Build both 64- and 32-bit versions of gvimext.dll for the installer
start /wait cmd /c "setenv /x64 && cd GvimExt && nmake clean all"
move GvimExt\gvimext.dll GvimExt\gvimext64.dll
start /wait cmd /c "setenv /x86 && cd GvimExt && nmake clean all"
:: Create zip packages
7z a ..\..\gvim_%APPVEYOR_REPO_TAG_NAME:v=%_%ARCH%_pdb.zip *.pdb
copy /Y ..\README.txt ..\runtime
copy /Y ..\vimtutor.bat ..\runtime
copy /Y *.exe ..\runtime\
copy /Y xxd\*.exe ..\runtime
copy /Y tee\*.exe ..\runtime
mkdir ..\runtime\GvimExt
copy /Y GvimExt\gvimext*.dll ..\runtime\GvimExt\
copy /Y GvimExt\README.txt   ..\runtime\GvimExt\
copy /Y GvimExt\*.inf        ..\runtime\GvimExt\
copy /Y GvimExt\*.reg        ..\runtime\GvimExt\
copy /Y ..\..\diff.exe ..\runtime\
copy /Y c:\gettext\libiconv*.dll ..\runtime\
copy /Y c:\gettext\libintl-8.dll ..\runtime\
:: libwinpthread is needed on Win64 for localizing messages
if exist c:\gettext\libwinpthread-1.dll copy /Y c:\gettext\libwinpthread-1.dll ..\runtime\
set dir=vim%APPVEYOR_REPO_TAG_NAME:~1,1%%APPVEYOR_REPO_TAG_NAME:~3,1%
mkdir ..\vim\%dir%
xcopy ..\runtime ..\vim\%dir% /Y /E /V /I /H /R /Q
7z a ..\..\gvim_%APPVEYOR_REPO_TAG_NAME:v=%_%ARCH%.zip ..\vim

:: Create x86 installer (Skip x64 installer)
if /i "%ARCH%"=="x64" goto :eof
c:\cygwin\bin\bash -lc "cd `cygpath '%APPVEYOR_BUILD_FOLDER%'`/vim/runtime/doc && touch ../../src/auto/config.mk && make uganda.nsis.txt"
copy gvim.exe gvim_ole.exe
copy vim.exe vimw32.exe
copy xxd\xxd.exe xxdw32.exe
copy install.exe installw32.exe
copy uninstal.exe uninstalw32.exe
pushd ..\nsis
"C:\Program Files (x86)\NSIS\makensis" /DVIMRT=..\runtime gvim.nsi "/XOutFile ..\..\gvim_%APPVEYOR_REPO_TAG_NAME:v=%_%ARCH%.exe"
popd

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
goto :eof
