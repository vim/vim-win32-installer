@echo off
:: Batch file for building/testing Vim on AppVeyor

setlocal ENABLEDELAYEDEXPANSION

cd %APPVEYOR_BUILD_FOLDER%

if "%APPVEYOR_REPO_TAG_NAME%"=="" (
	for /f %%i in ('git describe --tags --abbrev^=0') do set TAG_NAME=%%i
) else (
	set TAG_NAME=%APPVEYOR_REPO_TAG_NAME%
)
FOR /f "delims=. tokens=1-3" %%i in ("%TAG_NAME%") do set PATCHLEVEL=%%k

if /I "%ARCH%"=="x64" (
	set BIT=64
) else (
	set BIT=32
)
set DEPENDENCIES=%APPVEYOR_BUILD_FOLDER%\dependencies

:: ----------------------------------------------------------------------
:: Download URLs, local dirs and versions
:: Lua
set LUA_VER=54
set LUA_RELEASE=5.4.2
set LUA_URL=https://downloads.sourceforge.net/luabinaries/lua-%LUA_RELEASE%_Win%BIT%_dllw6_lib.zip
set LUA_DIR=%DEPENDENCIES%\Lua
:: Perl
set PERL_VER=532
set PERL_RELEASE=5.32.1.1
set PERL_URL=https://strawberryperl.com/download/%PERL_RELEASE%/strawberry-perl-%PERL_RELEASE%-%BIT%bit-portable.zip
set PERL_DIR=%DEPENDENCIES%\Strawberry\perl
:: Python2
set PYTHON_VER=27
set PYTHON_32_DIR=C:\python%PYTHON_VER%
set PYTHON_64_DIR=C:\python%PYTHON_VER%-x64
set PYTHON_DIR=!PYTHON_%BIT%_DIR!
:: Python3
set PYTHON3_VER=312
set PYTHON3_RELEASE=3.12.0
set PYTHON3_32_URL=https://www.python.org/ftp/python/%PYTHON3_RELEASE%/python-%PYTHON3_RELEASE%.exe
set PYTHON3_64_URL=https://www.python.org/ftp/python/%PYTHON3_RELEASE%/python-%PYTHON3_RELEASE%-amd64.exe
set PYTHON3_URL=!PYTHON3_%BIT%_URL!
set PYTHON3_32_DIR=C:\python%PYTHON3_VER%
set PYTHON3_64_DIR=C:\python%PYTHON3_VER%-x64
set PYTHON3_DIR=!PYTHON3_%BIT%_DIR!
:: Racket
set RACKET_VER=3m_dcgt6o
set RACKET_RELEASE=8.7
set RACKET32_URL=https://users.cs.utah.edu/plt/installers/%RACKET_RELEASE%/racket-minimal-%RACKET_RELEASE%-i386-win32-bc.tgz
set RACKET64_URL=https://users.cs.utah.edu/plt/installers/%RACKET_RELEASE%/racket-minimal-%RACKET_RELEASE%-x86_64-win32-bc.tgz
set RACKET_URL=!RACKET%BIT%_URL!
set RACKET_DIR=%DEPENDENCIES%\racket
set MZSCHEME_VER=%RACKET_VER%
:: Ruby
set RUBY_VER=32
set RUBY_API_VER_LONG=3.2.0
set RUBY_BRANCH=ruby_3_2
set RUBY_RELEASE=3.2.2-1
set RUBY_SRC_URL=https://github.com/ruby/ruby/archive/%RUBY_BRANCH%.zip
set RUBY_URL=https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-%RUBY_RELEASE%/rubyinstaller-%RUBY_RELEASE%-%ARCH%.7z
set RUBY32_DIR=%DEPENDENCIES%\Ruby%RUBY_VER%
set RUBY64_DIR=%DEPENDENCIES%\Ruby%RUBY_VER%-x64
set RUBY_DIR=!RUBY%BIT%_DIR!
:: Tcl
set TCL_VER_LONG=8.6
set TCL_VER=%TCL_VER_LONG:.=%
set TCL32_URL=http://dl.activestate.com/org/vim-win32/Tcl-8.6.6/latest/artifact/ActiveTcl-8.6.6.8607-MSWin32-x86-403667.exe
set TCL64_URL=http://dl.activestate.com/org/vim-win32/Tcl-8.6.6/latest/artifact/ActiveTcl-8.6.6.8606-MSWin32-x64-401995.exe
set TCL_URL=!TCL%BIT%_URL!
set TCL_DIR=%DEPENDENCIES%\Tcl
set TCL_DLL=tcl%TCL_VER%t.dll
set TCL_LIBRARY=%TCL_DIR%\lib\tcl%TCL_VER_LONG%
:: Gettext
set GETTEXT32_URL=https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.21-v1.16/gettext0.21-iconv1.16-shared-32.zip
set GETTEXT64_URL=https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.21-v1.16/gettext0.21-iconv1.16-shared-64.zip
:: winpty
set WINPTY_URL=https://github.com/rprichard/winpty/releases/download/0.4.3/winpty-0.4.3-msvc2015.zip
:: UPX
::set UPX_URL=https://github.com/upx/upx/releases/download/v3.94/upx394w.zip
:: ShellExecAsUser
set SHELLEXECASUSER_URL=https://nsis.sourceforge.io/mediawiki/images/1/1d/ShellExecAsUserUnicodeUpdate.zip
:: Libsodium
set LIBSODIUM_URL=https://github.com/jedisct1/libsodium/releases/download/1.0.18-RELEASE/libsodium-1.0.18-msvc.zip
set SODIUM_DIR=%DEPENDENCIES%\libsodium

:: Cygwin
set CYGWIN_URL=https://cygwin.com/setup-x86_64.exe
set CYGWIN_DIR=c:\cygwin64
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
echo TAG_NAME: %TAG_NAME%
@echo on

:: Get Vim source code
git submodule update --init
git submodule update --remote

:: Apply experimental patches
pushd vim
for %%i in (..\patch\*.patch) do git apply -v %%i
popd

if not exist downloads mkdir downloads
if not exist dependencies mkdir dependencies

:: Update cygwin and add dependencies
if not exist %CYGWIN_DIR% mkdir %CYGWIN_DIR%
call :downloadfile %CYGWIN_URL% %CYGWIN_DIR%\setup-x86_64.exe
%CYGWIN_DIR%\setup-x86_64.exe -qnNdO -P jq,make,gettext-devel
:: Initialise the new bash profile, just in case it is a new install.
%CYGWIN_DIR%\bin\bash -lc true > nul

:: Lua
call :downloadfile %LUA_URL% downloads\lua.zip
7z x downloads\lua.zip -o%LUA_DIR% > nul || exit 1

:: Perl
call :downloadfile %PERL_URL% downloads\perl.zip
:: Extract only the "perl" folder.
7z x downloads\perl.zip perl -o%PERL_DIR%\.. > nul || exit 1

:: Tcl
goto skiptcl

call :downloadfile %TCL_URL% downloads\tcl.exe
mkdir %DEPENDENCIES%\ActiveTclTemp
start /wait downloads\tcl.exe /extract:%DEPENDENCIES%\ActiveTclTemp /exenoui /exenoupdates /quiet /norestart
for /d %%i in (%DEPENDENCIES%\ActiveTclTemp\*) do move %%i %TCL_DIR%
copy %TCL_DIR%\bin\%TCL_DLL% vim\src\

:skiptcl

:: Python 3
call :downloadfile %PYTHON3_URL% downloads\python3.exe
cmd /c start /wait downloads\python3.exe /quiet TargetDir=%PYTHON3_DIR%  Include_pip=0 Include_tcltk=0 Include_test=0 Include_tools=0 AssociateFiles=0 Shortcuts=0 Include_doc=0 Include_launcher=0 InstallLauncherAllUsers=0

:: Ruby
:: Download RubyInstaller binary
call :downloadfile %RUBY_URL% downloads\ruby.7z
7z x downloads\ruby.7z -o%DEPENDENCIES%\ > nul || exit 1
move %DEPENDENCIES%\rubyinstaller-%RUBY_RELEASE%-%ARCH% %RUBY_DIR% > nul || exit 1
:: RubyInstaller is built by MinGW, so we cannot use header files from it.
:: Download the source files and generate config.h for MSVC.
rem git clone https://github.com/ruby/ruby.git -b %RUBY_BRANCH% --depth 1 -q ../ruby
call :downloadfile %RUBY_SRC_URL% downloads\ruby_src.zip
:: Extract the files only we needed to reduce the building time.
:: We need to use `^^` to escape `!` because we enable delayed expansion.
7z x downloads\ruby_src.zip */bin */include */enc/Makefile.in */win32 */common.mk -ir^^!version.h -xr^^!README.* -xr^^!*/win32/*.c -xr^^!*/win32/*.h -o.. > nul || exit 1
move ..\ruby-%RUBY_BRANCH% ..\ruby > nul || exit 1
pushd ..\ruby
call win32\configure.bat
echo on
nmake .config.h.time || exit 1
xcopy /s .ext\include %RUBY_DIR%\include\ruby-%RUBY_API_VER_LONG%
popd

:: Racket
call :downloadfile %RACKET_URL% downloads\racket.tgz
7z x -tgzip -so downloads/racket.tgz | 7z x -aoa -si -ttar -o%DEPENDENCIES%
type NUL > %RACKET_DIR%\include\bc_suffix.h

:: Install libintl.dll and iconv.dll
call :downloadfile %GETTEXT32_URL% downloads\gettext32.zip
7z e -y downloads\gettext32.zip -o%DEPENDENCIES%\gettext32 > nul || exit 1
call :downloadfile %GETTEXT64_URL% downloads\gettext64.zip
7z e -y downloads\gettext64.zip -o%DEPENDENCIES%\gettext64 > nul || exit 1

:: Install winpty
call :downloadfile %WINPTY_URL% downloads\winpty.zip
7z x -y downloads\winpty.zip -o%DEPENDENCIES%\winpty > nul || exit 1
if /i "%ARCH%"=="x64" (
	copy /Y %DEPENDENCIES%\winpty\x64_xp\bin\winpty.dll        vim\src\winpty64.dll
	copy /Y %DEPENDENCIES%\winpty\x64_xp\bin\winpty-agent.exe  vim\src\
) else (
	copy /Y %DEPENDENCIES%\winpty\ia32_xp\bin\winpty.dll       vim\src\winpty32.dll
	copy /Y %DEPENDENCIES%\winpty\ia32_xp\bin\winpty-agent.exe vim\src\
)

:: Install UPX
::
:: This is disabled, because UPX is known to be flagged as
:: supsicious by AV vendors
::
::call :downloadfile %UPX_URL% downloads\upx.zip
::7z e downloads\upx.zip *\upx.exe -ovim\nsis > nul || exit 1

:: Install ShellExecAsUser
call :downloadfile %SHELLEXECASUSER_URL% downloads\shellexecasuser.zip
7z x downloads\shellexecasuser.zip -o%DEPENDENCIES%\shellexecasuser > nul || exit 1
copy /Y %DEPENDENCIES%\shellexecasuser\unicode\ShellExecAsUser.dll "%ProgramFiles(x86)%\NSIS\Plugins\x86-unicode"

:: Install Libsodium
call :downloadfile %LIBSODIUM_URL% downloads\libsodium.zip
7z x downloads\libsodium.zip -o%DEPENDENCIES%\ > nul || exit 1
if /i "%ARCH%"=="x64" (
	copy /Y %DEPENDENCIES%\libsodium\x64\Release\v140\dynamic\libsodium.dll        vim\src\libsodium.dll
) else (
	copy /Y %DEPENDENCIES%\libsodium\Win32\Release\v140\dynamic\libsodium.dll      vim\src\libsodium.dll
)

:: Show PATH for debugging
path

:: Install additional packages for Racket
raco pkg install -i --auto r5rs-lib

@echo off
goto :eof


:build_x86
:build_x64
:: ----------------------------------------------------------------------
@echo on
cd vim\src

:: Replace VIM_VERSION_PATCHLEVEL in version.h with the actual patchlevel
%CYGWIN_DIR%\bin\bash -lc "cd $(cygpath '%APPVEYOR_BUILD_FOLDER%')/vim/src && ../../scripts/patchlevel.sh"
type version.h

:: Build GUI version
nmake -f Make_mvc.mak ^
	GUI=yes OLE=yes DIRECTX=yes ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	DYNAMIC_PERL=yes PERL=%PERL_DIR% ^
	DYNAMIC_PYTHON=yes PYTHON=%PYTHON_DIR% ^
	DYNAMIC_PYTHON3=yes PYTHON3=%PYTHON3_DIR% DYNAMIC_PYTHON3_STABLE_ABI=yes ^
	DYNAMIC_LUA=yes LUA=%LUA_DIR% ^
	DYNAMIC_RUBY=yes RUBY=%RUBY_DIR% RUBY_MSVCRT_NAME=msvcrt ^
	DYNAMIC_MZSCHEME=yes MZSCHEME_VER=%RACKET_VER% "MZSCHEME=%RACKET_DIR%" ^
	TERMINAL=yes SODIUM=%SODIUM_DIR% ^
	|| exit 1
:: Build CUI version
nmake -f Make_mvc.mak ^
	GUI=no OLE=no DIRECTX=no ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=yes DEBUG=no ^
	DYNAMIC_PERL=yes PERL=%PERL_DIR% ^
	DYNAMIC_PYTHON=yes PYTHON=%PYTHON_DIR% ^
	DYNAMIC_PYTHON3=yes PYTHON3=%PYTHON3_DIR% DYNAMIC_PYTHON3_STABLE_ABI=yes ^
	DYNAMIC_LUA=yes LUA=%LUA_DIR% ^
	DYNAMIC_RUBY=yes RUBY=%RUBY_DIR% RUBY_MSVCRT_NAME=msvcrt ^
	DYNAMIC_MZSCHEME=yes MZSCHEME_VER=%RACKET_VER% "MZSCHEME=%RACKET_DIR%" ^
	TERMINAL=yes SODIUM=%SODIUM_DIR% ^
	|| exit 1
:: Build translations
pushd po
nmake -f Make_mvc.mak GETTEXT_PATH=%CYGWIN_DIR%\bin VIMRUNTIME=..\..\runtime install-all || exit 1
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
start /wait cmd /c "%VCVARSALL% x64 && cd GvimExt && nmake -f Make_mvc.mak CPU=AMD64 clean all > ..\gvimext.log"
type gvimext.log
copy GvimExt\gvimext.dll   GvimExt\gvimext64.dll
move GvimExt\gvimext.dll   GvimExt64\gvimext.dll
copy /Y GvimExt\README.txt GvimExt64\
copy /Y GvimExt\*.inf      GvimExt64\
copy /Y GvimExt\*.reg      GvimExt64\
start /wait cmd /c "%VCVARSALL% x86 && cd GvimExt && nmake -f Make_mvc.mak CPU=i386 clean all > ..\gvimext.log"
type gvimext.log
copy GvimExt\gvimext.dll   GvimExt32\gvimext.dll
copy /Y GvimExt\README.txt GvimExt32\
copy /Y GvimExt\*.inf      GvimExt32\
copy /Y GvimExt\*.reg      GvimExt32\

:: Create zip packages
7z a ..\..\gvim_%TAG_NAME:~1%_%ARCH%_pdb.zip *.pdb
copy /Y ..\README.txt ..\runtime
copy /Y ..\vimtutor.bat ..\runtime
copy /Y *.exe ..\runtime\
copy /Y libsodium.dll ..\runtime\
copy /Y xxd\*.exe ..\runtime
copy /Y tee\*.exe ..\runtime
mkdir ..\runtime\GvimExt64
mkdir ..\runtime\GvimExt32
copy /Y GvimExt64\*.*                    ..\runtime\GvimExt64\
copy /Y %DEPENDENCIES%\gettext64\libiconv-2.dll      ..\runtime\GvimExt64\
copy /Y %DEPENDENCIES%\gettext64\libintl-8.dll       ..\runtime\GvimExt64\
copy /Y GvimExt32\*.*                    ..\runtime\GvimExt32\
copy /Y %DEPENDENCIES%\gettext32\libiconv-2.dll      ..\runtime\GvimExt32\
copy /Y %DEPENDENCIES%\gettext32\libintl-8.dll       ..\runtime\GvimExt32\
rem copy /Y c:\gettext32\libgcc_s_sjlj-1.dll ..\runtime\GvimExt32\
rem libgcc_s_sjlj-1.dll is not needed anymore. Don't include it in the installer.
if exist %DEPENDENCIES%\gettext32\libgcc_s_sjlj-1.dll del %DEPENDENCIES%\gettext32\libgcc_s_sjlj-1.dll
copy /Y ..\..\diff.exe ..\runtime\
copy /Y %DEPENDENCIES%\gettext%BIT%\libiconv-2.dll   ..\runtime\
copy /Y %DEPENDENCIES%\gettext%BIT%\libintl-8.dll    ..\runtime\
rem if exist c:\gettext%BIT%\libgcc_s_sjlj-1.dll copy /Y c:\gettext%BIT%\libgcc_s_sjlj-1.dll ..\runtime\
copy /Y winpty* ..\runtime\
copy /Y winpty* ..\..\
set dir=vim%TAG_NAME:~1,1%%TAG_NAME:~3,1%
mkdir ..\vim\%dir%
xcopy ..\runtime ..\vim\%dir% /Y /E /V /I /H /R /Q
7z a ..\..\gvim_%TAG_NAME:~1%_%ARCH%.zip ..\vim

:: Create installer
%CYGWIN_DIR%\bin\bash -lc "cd $(cygpath '%APPVEYOR_BUILD_FOLDER%')/vim/runtime/doc && touch ../../src/auto/config.mk && make uganda.nsis.txt"
copy gvim.exe gvim_ole.exe
copy vim.exe vimw32.exe
copy tee\tee.exe teew32.exe
copy xxd\xxd.exe xxdw32.exe
copy install.exe installw32.exe
copy uninstall.exe uninstallw32.exe
pushd ..\nsis

:: Disable UPX
sed -i '/^\(!define HAVE_UPX\)/d' gvim.nsi

7z x icons.zip > nul
if /i "%ARCH%"=="x64" (
	"%ProgramFiles(x86)%\NSIS\makensis" /DVIMRT=..\runtime /DGETTEXT=%DEPENDENCIES% /DWIN64=1 /DPATCHLEVEL=%PATCHLEVEL% gvim.nsi "/XOutFile ..\..\gvim_%TAG_NAME:~1%_%ARCH%.exe"
) else (
	"%ProgramFiles(x86)%\NSIS\makensis" /DVIMRT=..\runtime /DGETTEXT=%DEPENDENCIES% /DPATCHLEVEL=%PATCHLEVEL%  gvim.nsi "/XOutFile ..\..\gvim_%TAG_NAME:~1%_%ARCH%.exe"
)
popd

:: Create zipfile for signing with signpath.io
:: This will create a single zip file that should be uploaded to signpath
:: signpath can then sign each artifact inside the zip file
:: (the Vim zip archive as well as the installer)
echo Creating Signpath Zip Archive
cd %APPVEYOR_BUILD_FOLDER%
7z a unsigned-gvim_%TAG_NAME:~1%_%ARCH%.zip gvim_%TAG_NAME:~1%_%ARCH%.zip gvim*.exe

@echo off
goto :eof


:test_x86
:test_x64
:: ----------------------------------------------------------------------
@echo on
set PLTCOLLECTS=%RACKET_DIR%\collects
set PLTCONFIGDIR=%RACKET_DIR%\etc
cd vim\src\testdir
nmake -f Make_mvc.mak VIMPROG=..\gvim || exit 1
nmake -f Make_mvc.mak clean
nmake -f Make_mvc.mak VIMPROG=..\vim || exit 1

@echo off
goto :eof


:onsuccess_x64
goto :eof
:onsuccess_x86
:: ----------------------------------------------------------------------
:: Turn off the draft status of the release when x86 is successfully finished.

if "%APPVEYOR_REPO_TAG_NAME%"=="" goto :eof

call :get_release_id

:: Turn off the draft status.
curl -X PATCH -H "Authorization: token %auth_token%" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/%APPVEYOR_REPO_NAME%/releases/%REL_ID%" -d "{\"draft\": false}"
goto :eof


:onfailure_x64
goto :eof
:onfailure_x86
:: ----------------------------------------------------------------------
:: Delete the release when x86 is failed.

if "%APPVEYOR_REPO_TAG_NAME%"=="" goto :eof

call :get_release_id

:: Delete the release.
curl -X DELETE -H "Authorization: token %auth_token%" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/%APPVEYOR_REPO_NAME%/releases/%REL_ID%"
goto :eof


:get_release_id
:: ----------------------------------------------------------------------
:: Get the ID of the release. Set the result to %REL_ID%.
path %PATH%;%CYGWIN_DIR%\bin

curl -H "Authorization: token %auth_token%" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/%APPVEYOR_REPO_NAME%/releases" > releases.json
type releases.json | jq ".[] | {name, id} | select(.name == \"%TAG_NAME%\") | {id}[]" > release_id.txt
type release_id.txt
for /f "delims=" %%i in (release_id.txt) do set REL_ID=%%i
goto :eof


:downloadfile
:: ----------------------------------------------------------------------
:: call :downloadfile <URL> <localfile>
if not exist %2 (
	curl -f -L %1 -o %2
)
if ERRORLEVEL 1 (
	rem Retry once.
	curl -f -L %1 -o %2 || exit 1
)
@goto :eof
