@echo off
:: Batch file for building/testing Vim on AppVeyor

if /i "%ARCH%.%appveyor_repo_tag%"=="x86.false" (
  echo Skip this build.
  exit 0
)

if /I "%1"=="" (
  set target=build
) else (
  set target=%1
)
goto %target%_%ARCH%
echo Unknown build target.
exit 1


:install_x86
:: ----------------------------------------------------------------------
@echo on
:: Work around for Python 2.7.11
reg copy HKLM\SOFTWARE\Python\PythonCore\2.7 HKLM\SOFTWARE\Python\PythonCore\2.7-32 /s /reg:32
:: Lua
:: Appveyor command doesn't seem to work well when downloading from sf.net.
curl -f -L "http://downloads.sourceforge.net/project/luabinaries/5.3.2/Windows%%20Libraries/Dynamic/lua-5.3.2_Win32_dllw4_lib.zip" -o lua.zip
7z x lua.zip -oC:\Lua > nul
:: Perl
appveyor DownloadFile http://downloads.activestate.com/ActivePerl/releases/5.22.0.2200/ActivePerl-5.22.0.2200-MSWin32-x86-64int-299195.zip -FileName perl.zip
7z x perl.zip -oC:\ > nul
for /d %%i in (C:\ActivePerl*) do move %%i C:\Perl522
:: Tcl
appveyor DownloadFile http://downloads.activestate.com/ActiveTcl/releases/8.6.4.1/ActiveTcl8.6.4.1.299124-win32-ix86-threaded.exe -FileName tcl.exe
start /wait tcl.exe --directory C:\Tcl
:: Ruby
:: RubyInstaller is built by MinGW, so we cannot use header files from it.
:: Download the source files and generate config.h for MSVC.
git clone https://github.com/ruby/ruby.git -b ruby_2_2 --depth 1 -q ../ruby
pushd ..\ruby
call win32\configure.bat
echo on
nmake .config.h.time
xcopy /s .ext\include C:\Ruby22\include\ruby-2.2.0
popd
:: Racket
:: Need a patch to install gvim with dynamic racket
curl -f -L https://mirror.racket-lang.org/releases/6.3/installers/racket-minimal-6.3-i386-win32.exe -o racket.exe
start /wait racket.exe /S

if /i "%appveyor_repo_tag%"=="true" (
  :: Install binary diff.exe and libintl.dll and iconv.dll
  curl -f -L -O ftp://ftp.vim.org/pub/vim/pc/gvim74.exe
  7z e gvim74.exe $0\diff.exe -o..
  curl -f -L "https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.19.6-v1.14/gettext0.19.6-iconv1.14-shared-32.exe" -o gettext.exe
  start /wait gettext.exe /verysilent /dir=c:\gettext
  :: Install NSIS and UPX
  curl -f -L -O http://downloads.sourceforge.net/project/nsis/NSIS%%202/2.50/nsis-2.50.zip
  7z x nsis-2.50.zip -oc:\ > nul
  curl -f -L http://upx.sourceforge.net/download/upx391w.zip -o upx.zip
  7z e upx.zip *\upx.exe -onsis > nul
)

:: Update PATH
path C:\Perl522\perl\bin;%path%;C:\Lua;C:\Tcl\bin;C:\Ruby22\bin;C:\Program Files (x86)\Racket;C:\Program Files (x86)\Racket\lib

:: Install additional packages for Racket
raco pkg install --auto r5rs-lib
@echo off
goto :eof


:install_x64
:: ----------------------------------------------------------------------
@echo on
:: Work around for Python 2.7.11
reg copy HKLM\SOFTWARE\Python\PythonCore\2.7 HKLM\SOFTWARE\Python\PythonCore\2.7-32 /s /reg:64
:: Lua
:: Appveyor command doesn't seem to work well when downloading from sf.net.
curl -f -L "http://downloads.sourceforge.net/project/luabinaries/5.3.2/Windows%%20Libraries/Dynamic/lua-5.3.2_Win64_dllw4_lib.zip" -o lua.zip
7z x lua.zip -oC:\Lua > nul
:: Perl
appveyor DownloadFile http://downloads.activestate.com/ActivePerl/releases/5.22.0.2200/ActivePerl-5.22.0.2200-MSWin32-x64-299195.zip -FileName perl.zip
7z x perl.zip -oC:\ > nul
for /d %%i in (C:\ActivePerl*) do move %%i C:\Perl522
:: Tcl
appveyor DownloadFile http://downloads.activestate.com/ActiveTcl/releases/8.6.4.1/ActiveTcl8.6.4.1.299124-win32-x86_64-threaded.exe -FileName tcl.exe
start /wait tcl.exe --directory C:\Tcl
:: Ruby
:: RubyInstaller is built by MinGW, so we cannot use header files from it.
:: Download the source files and generate config.h for MSVC.
git clone https://github.com/ruby/ruby.git -b ruby_2_2 --depth 1 -q ../ruby
pushd ..\ruby
call win32\configure.bat
echo on
nmake .config.h.time
xcopy /s .ext\include C:\Ruby22-x64\include\ruby-2.2.0
popd
:: Racket
:: Need a patch to install gvim with dynamic racket
curl -f -L https://mirror.racket-lang.org/releases/6.3/installers/racket-minimal-6.3-x86_64-win32.exe -o racket.exe
start /wait racket.exe /S

if /i "%appveyor_repo_tag%"=="true" (
  :: Install binary diff.exe and libintl.dll and iconv.dll
  curl -f -L -O ftp://ftp.vim.org/pub/vim/pc/gvim74.exe
  7z e gvim74.exe $0\diff.exe -o..
  curl -f -L "https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.19.6-v1.14/gettext0.19.6-iconv1.14-shared-64.exe" -o gettext.exe
  start /wait gettext.exe /verysilent /dir=c:\gettext
  :: libwinpthread is needed on Win64 for localizing messages
  ::copy c:\gettext\libwinpthread-1.dll ..\runtime
  :: Install NSIS and UPX
  curl -f -L -O http://downloads.sourceforge.net/project/nsis/NSIS%%202/2.50/nsis-2.50.zip
  7z x nsis-2.50.zip -oc:\ > nul
  curl -f -L http://upx.sourceforge.net/download/upx391w.zip -o upx.zip
  7z e upx.zip *\upx.exe -onsis > nul
)

:: Update PATH
path C:\Perl522\perl\bin;%path%;C:\Lua;C:\Tcl\bin;C:\Ruby22-x64\bin;C:\Program Files\Racket;C:\Program Files\Racket\lib

:: Install additional packages for Racket
raco pkg install --auto r5rs-lib
@echo off
goto :eof


:build_x86
:: ----------------------------------------------------------------------
@echo on
:: Remove progress bar from the build log
sed -e "s/\$(LINKARGS2)/\$(LINKARGS2) | sed -e 's#.*\\\\r.*##'/" Make_mvc.mak > Make_mvc2.mak
:: Build GUI version
nmake -f Make_mvc2.mak CPU=i386 ^
	GUI=yes OLE=yes DIRECTX=yes ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	PERL_VER=522 DYNAMIC_PERL=yes PERL=C:\Perl522\perl ^
	PYTHON_VER=27 DYNAMIC_PYTHON=yes PYTHON=C:\Python27 ^
	PYTHON3_VER=34 DYNAMIC_PYTHON3=yes PYTHON3=C:\Python34 ^
	LUA_VER=53 DYNAMIC_LUA=yes LUA=C:\Lua ^
	TCL_VER=86 TCL_VER_LONG=8.6 DYNAMIC_TCL=yes TCL=C:\Tcl ^
	RUBY=C:\Ruby22 DYNAMIC_RUBY=yes RUBY_VER=22 RUBY_VER_LONG=2.2.0 ^
	RUBY_MSVCRT_NAME=msvcrt ^
	"MZSCHEME=C:\Program Files (x86)\Racket" DYNAMIC_MZSCHEME=yes MZSCHEME_VER=3m_9z0ds0 ^
	WINVER=0x500 ^
	|| exit 1
@if /i "%appveyor_repo_tag%"=="false" goto check_executable
:: Build CUI version
nmake -f Make_mvc2.mak CPU=i386 ^
	GUI=no OLE=no DIRECTX=no ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	PERL_VER=522 DYNAMIC_PERL=yes PERL=C:\Perl522\perl ^
	PYTHON_VER=27 DYNAMIC_PYTHON=yes PYTHON=C:\Python27 ^
	PYTHON3_VER=34 DYNAMIC_PYTHON3=yes PYTHON3=C:\Python34 ^
	LUA_VER=53 DYNAMIC_LUA=yes LUA=C:\Lua ^
	TCL_VER=86 TCL_VER_LONG=8.6 DYNAMIC_TCL=yes TCL=C:\Tcl ^
	RUBY=C:\Ruby22 DYNAMIC_RUBY=yes RUBY_VER=22 RUBY_VER_LONG=2.2.0 ^
	RUBY_MSVCRT_NAME=msvcrt ^
	"MZSCHEME=C:\Program Files (x86)\Racket" DYNAMIC_MZSCHEME=yes MZSCHEME_VER=3m_9z0ds0 ^
	WINVER=0x500 ^
	|| exit 1
:: Build translations
pushd po
nmake -f Make_mvc.mak GETTEXT_PATH=C:\cygwin\bin VIMRUNTIME=..\..\runtime install-all || exit 1
popd
goto check_executable

@echo off
goto :eof


:build_x64
:: ----------------------------------------------------------------------
@echo on
:: Remove progress bar from the build log
sed -e "s/\$(LINKARGS2)/\$(LINKARGS2) | sed -e 's#.*\\\\r.*##'/" Make_mvc.mak > Make_mvc2.mak
:: Build GUI version
nmake -f Make_mvc2.mak CPU=AMD64 ^
	GUI=yes OLE=yes DIRECTX=yes ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	PERL_VER=522 DYNAMIC_PERL=yes PERL=C:\Perl522\perl ^
	PYTHON_VER=27 DYNAMIC_PYTHON=yes PYTHON=C:\Python27-x64 ^
	PYTHON3_VER=34 DYNAMIC_PYTHON3=yes PYTHON3=C:\Python34-x64 ^
	LUA_VER=53 DYNAMIC_LUA=yes LUA=C:\Lua ^
	TCL_VER=86 TCL_VER_LONG=8.6 DYNAMIC_TCL=yes TCL=C:\Tcl ^
	RUBY=C:\Ruby22-x64 DYNAMIC_RUBY=yes RUBY_VER=22 RUBY_VER_LONG=2.2.0 ^
	RUBY_MSVCRT_NAME=msvcrt ^
	"MZSCHEME=C:\Program Files\Racket" DYNAMIC_MZSCHEME=yes MZSCHEME_VER=3m_9z0ds0 ^
	WINVER=0x500 ^
	|| exit 1
@if /i "%appveyor_repo_tag%"=="false" goto check_executable
:: Build CUI version
nmake -f Make_mvc2.mak CPU=AMD64 ^
	GUI=no OLE=no DIRECTX=no ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	PERL_VER=522 DYNAMIC_PERL=yes PERL=C:\Perl522\perl ^
	PYTHON_VER=27 DYNAMIC_PYTHON=yes PYTHON=C:\Python27-x64 ^
	PYTHON3_VER=34 DYNAMIC_PYTHON3=yes PYTHON3=C:\Python34-x64 ^
	LUA_VER=53 DYNAMIC_LUA=yes LUA=C:\Lua ^
	TCL_VER=86 TCL_VER_LONG=8.6 DYNAMIC_TCL=yes TCL=C:\Tcl ^
	RUBY=C:\Ruby22-x64 DYNAMIC_RUBY=yes RUBY_VER=22 RUBY_VER_LONG=2.2.0 ^
	RUBY_MSVCRT_NAME=msvcrt ^
	"MZSCHEME=C:\Program Files\Racket" DYNAMIC_MZSCHEME=yes MZSCHEME_VER=3m_9z0ds0 ^
	WINVER=0x500 ^
	|| exit 1
:: Build translations
pushd po
nmake -f Make_mvc.mak GETTEXT_PATH=C:\cygwin\bin VIMRUNTIME=..\..\runtime install-all || exit 1
popd
goto check_executable


:check_executable
:: ----------------------------------------------------------------------
.\gvim -silent -register
.\gvim -u NONE -c "redir @a | ver | 0put a | wq!" ver.txt
type ver.txt
if /i "%appveyor_repo_tag%"=="true" (
  .\vim --version
)
@echo off
goto :eof


:package_x86
:package_x64
:: ----------------------------------------------------------------------
if /i "%appveyor_repo_tag%"=="false" goto :eof
@echo on

:: Build both 64- and 32-bit versions of gvimext.dll for the installer
start /wait cmd /c "setenv /x64 && cd GvimExt && nmake clean all"
move GvimExt\gvimext.dll GvimExt\gvimext64.dll
start /wait cmd /c "setenv /x86 && cd GvimExt && nmake clean all"
:: Create zip packages
copy /Y ..\README.txt ..\runtime
copy /Y ..\vimtutor.bat ..\runtime
copy /Y *.exe ..\runtime\
copy /Y xxd\*.exe ..\runtime
mkdir ..\runtime\GvimExt
copy /Y GvimExt\gvimext*.dll ..\runtime\GvimExt\
copy /Y GvimExt\README.txt   ..\runtime\GvimExt\
copy /Y GvimExt\*.inf        ..\runtime\GvimExt\
copy /Y GvimExt\*.reg        ..\runtime\GvimExt\
copy /Y c:\projects\diff.exe ..\runtime\
copy /Y c:\gettext\libiconv*.dll ..\runtime\
copy /Y c:\gettext\libintl-8.dll ..\runtime\
:: libwinpthread is needed on Win64 for localizing messages
if exist c:\gettext\libwinpthread-1.dll copy /Y c:\gettext\libwinpthread-1.dll ..\runtime\
7z a ..\gvim_%ARCH%.zip ..\runtime\*

:: Create x86 installer
if /i "%ARCH%"=="x64" goto :eof
c:\cygwin\bin\bash -lc "cd /cygdrive/c/projects/vim/runtime/doc && touch ../../src/auto/config.mk && make uganda.nsis.txt"
copy gvim.exe gvim_ole.exe
copy vim.exe vimw32.exe
copy xxd\xxd.exe xxdw32.exe
copy install.exe installw32.exe
copy uninstal.exe uninstalw32.exe
pushd ..\nsis && c:\nsis-2.50\makensis /DVIMRT=..\runtime gvim.nsi "/XOutFile ..\gvim_%ARCH%.exe" && popd

@echo off
goto :eof


:test_x86
:test_x64
:: ----------------------------------------------------------------------
@echo on
cd testdir
nmake -f Make_dos.mak VIMPROG=..\gvim || exit 1
if /i "%appveyor_repo_tag%"=="true" (
  nmake -f Make_dos.mak clean
  nmake -f Make_dos.mak VIMPROG=..\vim || exit 1
)

@echo off
goto :eof
