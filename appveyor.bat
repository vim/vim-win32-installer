@echo off
:: This batch file was supposed to be used to build Vim for Windows on Appveyor.
:: However, now it will also be used for building an ARM64 version on Github CI,
:: so the name is no longer hundert percent correct.  Oh well....

SetLocal

if defined APPVEYOR_BUILD_FOLDER (
  cd %APPVEYOR_BUILD_FOLDER%
  set "DEPENDENCIES=%APPVEYOR_BUILD_FOLDER%\dependencies"
)

if not defined APPVEYOR_REPO_TAG_NAME (
  for /F %%I in ('git describe --tags --always --abbrev^=0') do set "TAG_NAME=%%I"
) else (
  set "TAG_NAME=%APPVEYOR_REPO_TAG_NAME%"
)
:: Strip the first "v" from the tag name.
set "VER_NUM=%TAG_NAME:~1%"

:: Split the version into each component.
for /F "delims=.-+ tokens=1-3" %%I in ("%VER_NUM%") do (
  set "MAJOR=%%I"
  set "MINOR=%%J"
  set "PATCHLEVEL=%%K"
)

if /I "%ARCH%"=="x64" (
  set "BIT=64"
) else (
  set "BIT=32"
)
:: -------- setting variables ----------------------------------------------
:: Download URLs, local dirs and versions

@rem Lua
set "LUA_VER=54"
set "LUA_RELEASE=5.4.2"
set "LUA_URL=https://downloads.sourceforge.net/luabinaries/lua-%LUA_RELEASE%_Win%BIT%_dllw6_lib.zip"
set "LUA_DIR=%DEPENDENCIES%\Lua%LUA_VER%-%ARCH%"

@rem Perl
set "PERL_VER=532"
set "PERL_RELEASE=5.32.1.1"
set "PERL_URL=https://strawberryperl.com/download/%PERL_RELEASE%/strawberry-perl-%PERL_RELEASE%-%BIT%bit-portable.zip"
set "PERL_DIR=%DEPENDENCIES%\perl%PERL_VER%-%ARCH%"

@rem Python2
set "PYTHON_VER=27"
set "PYTHON_RELEASE=2.7.18"
@rem To test on a local machine if Python 2.7 is not installed
set "PYTHON_32_URL=https://www.python.org/ftp/python/%PYTHON_RELEASE%/python-%PYTHON_RELEASE%.msi"
set "PYTHON_64_URL=https://www.python.org/ftp/python/%PYTHON_RELEASE%/python-%PYTHON_RELEASE%.amd64.msi"
set "PYTHON_32_DIR=C:\python%PYTHON_VER%"
set "PYTHON_64_DIR=C:\python%PYTHON_VER%-x64"
SetLocal EnableDelayedExpansion
set "PYTHON_URL=!PYTHON_%BIT%_URL!"
set "PYTHON_DIR=!PYTHON_%BIT%_DIR!"
EndLocal & (
  set "PYTHON_URL=%PYTHON_URL%"
  set "PYTHON_DIR=%PYTHON_DIR%"
)

@rem Python3
set "PYTHON3_VER=312"
set "PYTHON3_RELEASE=3.12.0"
set "PY3CORE_32_URL=https://www.python.org/ftp/python/%PYTHON3_RELEASE%/win32/core.msi"
set "PY3DEV_32_URL=https://www.python.org/ftp/python/%PYTHON3_RELEASE%/win32/dev.msi"
set "PY3EXE_32_URL=https://www.python.org/ftp/python/%PYTHON3_RELEASE%/win32/exe.msi"
set "PY3LIB_32_URL=https://www.python.org/ftp/python/%PYTHON3_RELEASE%/win32/lib.msi"
set "PY3CORE_64_URL=https://www.python.org/ftp/python/%PYTHON3_RELEASE%/amd64/core.msi"
set "PY3DEV_64_URL=https://www.python.org/ftp/python/%PYTHON3_RELEASE%/amd64/dev.msi"
set "PY3EXE_64_URL=https://www.python.org/ftp/python/%PYTHON3_RELEASE%/amd64/exe.msi"
set "PY3LIB_64_URL=https://www.python.org/ftp/python/%PYTHON3_RELEASE%/amd64/lib.msi"
set "PYTHON3_32_DIR=C:\python%PYTHON3_VER%"
set "PYTHON3_64_DIR=C:\python%PYTHON3_VER%-x64"
SetLocal EnableDelayedExpansion
set "PY3CORE_URL=!PY3CORE_%BIT%_URL!"
set "PY3DEV_URL=!PY3DEV_%BIT%_URL!"
set "PY3EXE_URL=!PY3EXE_%BIT%_URL!"
set "PY3LIB_URL=!PY3LIB_%BIT%_URL!"
set "PYTHON3_DIR=!PYTHON3_%BIT%_DIR!"
EndLocal & (
  set "PY3CORE_URL=%PY3CORE_URL%"
  set "PY3DEV_URL=%PY3DEV_URL%"
  set "PY3EXE_URL=%PY3EXE_URL%"
  set "PY3LIB_URL=%PY3LIB_URL%"
  set "PYTHON3_DIR=%PYTHON3_DIR%"
)

@rem Racket
set "RACKET_VER=3m_dcgt6o"
set "RACKET_RELEASE=8.7"
set "RACKET_32_URL=https://users.cs.utah.edu/plt/installers/%RACKET_RELEASE%/racket-minimal-%RACKET_RELEASE%-i386-win32-bc.tgz"
set "RACKET_64_URL=https://users.cs.utah.edu/plt/installers/%RACKET_RELEASE%/racket-minimal-%RACKET_RELEASE%-x86_64-win32-bc.tgz"
SetLocal EnableDelayedExpansion
set "RACKET_URL=!RACKET_%BIT%_URL!"
EndLocal & set "RACKET_URL=%RACKET_URL%"
set "RACKET_DIR=%DEPENDENCIES%\racket%RACKET_VER%-%ARCH%"
set "MZSCHEME_VER=%RACKET_VER%"

@rem Ruby
set "RUBY_VER=32"
set "RUBY_API_VER_LONG=3.2.0"
set "RUBY_BRANCH=ruby_3_2"
set "RUBY_RELEASE=3.2.2-1"
set "RUBY_SRC_URL=https://github.com/ruby/ruby/archive/%RUBY_BRANCH%.zip"
set "RUBY_URL=https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-%RUBY_RELEASE%/rubyinstaller-%RUBY_RELEASE%-%ARCH%.7z"
set "RUBY_DIR=%DEPENDENCIES%\Ruby%RUBY_VER%-%ARCH%"

@rem Tcl
set "TCL_VER_LONG=8.6"
set "TCL_VER=%TCL_VER_LONG:.=%"
@rem See the “:install” section
rem set "TCL_32_URL=https://sourceforge.net/projects/magicsplat/files/barebones-tcl/tcltk-%TCL_VER_LONG%.10-barebones-x86.zip/download"
rem set "TCL_64_URL=https://sourceforge.net/projects/magicsplat/files/barebones-tcl/tcltk-%TCL_VER_LONG%.10-barebones-x64.zip/download"
rem SetLocal EnableDelayedExpansion
rem set "TCL_URL=!TCL_%BIT%_URL!"
rem EndLocal & set "TCL_URL=%TCL_URL%"
set "TCL_DIR=%DEPENDENCIES%\Tcl%TCL_VER%-%ARCH%"
set "TCL_DLL=tcl%TCL_VER%t.dll"
set "TCL_LIBRARY=%TCL_DIR%\lib\tcl%TCL_VER_LONG%"

@rem Gettext
set "GETTEXT_32_URL=https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.23-v1.17/gettext0.23-iconv1.17-shared-32.zip"
set "GETTEXT_64_URL=https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.23-v1.17/gettext0.23-iconv1.17-shared-64.zip"
set "INTL_VCPKG=%VCPKG_ROOT%\packages\gettext-libintl_arm64-windows"
set "ICONV_VCPKG=%VCPKG_ROOT%\packages\libiconv_arm64-windows"

@rem winpty
set "WINPTY_URL=https://github.com/rprichard/winpty/releases/download/0.4.3/winpty-0.4.3-msvc2015.zip"
set "WINPTY_DIR=%DEPENDENCIES%\winpty"
set "WINPTY_VCPKG=%VCPKG_ROOT%\packages\winpty_arm64-windows"

@rem UPX
@rem set "UPX_URL=https://github.com/upx/upx/releases/download/v3.94/upx394w.zip"

@rem ShellExecAsUser
set "SHELLEXECASUSER_URL=https://nsis.sourceforge.io/mediawiki/images/1/1d/ShellExecAsUserUnicodeUpdate.zip"

@rem Libsodium
set "LIBSODIUM_URL=https://github.com/jedisct1/libsodium/releases/download/1.0.20-RELEASE/libsodium-1.0.20-msvc.zip"
set "LIBSODIUM_SOURCE=https://github.com/jedisct1/libsodium/archive/refs/tags/1.0.20-RELEASE.zip"
set "SODIUM_DIR=%DEPENDENCIES%\libsodium"

@rem Cygwin
set "CYGWIN_URL=https://cygwin.com/setup-x86_64.exe"
set "CYGWIN_DIR=c:\cygwin64"

:: ----------------------------------------------------------------------

@rem Update PATH
path %PYTHON_DIR%;%PYTHON3_DIR%;%PERL_DIR%\bin;%LUA_DIR%;%RUBY_DIR%\bin;^
%RUBY_DIR%\bin\ruby_builtin_dlls;%RACKET_DIR%;%RACKET_DIR%\lib;%TCL_DIR%;^
%TCL_LIBRARY%;%Path%

if /I "%1"=="" (
  set "target=build"
) else (
  set "target=%1"
)

goto %target%_%ARCH%
echo:Unknown build target.
exit 1


:install_x86
:install_x64
:: ----------- installing dependencies ------------------------------------------
echo TAG_NAME: %TAG_NAME%

@rem Get Vim source code
git submodule update --init --depth 20
git submodule update --remote

@rem Apply experimental patches
pushd vim
for %%I in (..\patch\*.patch) do git apply -v %%I
popd

if not exist downloads mkdir downloads
if not exist dependencies mkdir dependencies

where vcpkg >nul 2>&1
if %errorlevel% equ 0 goto :skipvcpkg

@rem Install vcpkg for ARM64
if /I "%PLATFORM%" == "arm64" (
  if not exist %DEPENDENCIES%\vcpkg (
    pushd %DEPENDENCIES%
    git clone --depth 1 https://github.com/microsoft/vcpkg.git
    call vcpkg\bootstrap-vcpkg.bat
    popd
  )
  set "VCPKG_ROOT=%DEPENDENCIES%\vcpkg"
)
:skipvcpkg

goto :skipcygwin
@rem It's not necessary right now
@rem Update cygwin and add dependencies
rem if not exist %CYGWIN_DIR% mkdir %CYGWIN_DIR%
rem call :downloadfile %CYGWIN_URL% %CYGWIN_DIR%\setup-x86_64.exe
rem %CYGWIN_DIR%\setup-x86_64.exe -qnNdO -P jq,make,gettext-devel
@rem Initialise the new bash profile, just in case it is a new install.
rem %CYGWIN_DIR%\bin\bash -lc true > nul
:skipcygwin

@rem Lua
call :downloadfile "%LUA_URL%" downloads\lua-%BIT%.zip
7z.exe x -y downloads\lua-%BIT%.zip -o%LUA_DIR%\ > nul || exit 1

@rem Perl
call :downloadfile "%PERL_URL%" downloads\perl-%BIT%.zip
@rem Extract only the "perl" folder.
7z.exe x -y downloads\perl-%BIT%.zip perl -o%DEPENDENCIES%\ > nul || exit 1
move /Y %DEPENDENCIES%\perl %PERL_DIR%

goto :skiptcl
@rem Tcl
@rem In VS2019 and VS2022 32-bit builds normally.
@rem In VS2022 64-bit one generates an error:
@rem "fatal error C1047: The object or library file
@rem 'C:\VimInstaller\dependencies\Tcl86-x64\lib\tclstub86.lib' was created by
@rem a different version of the compiler..."
@rem It's necessary to figure out what to do about it.
@rem It's possible, for example, to remove the “/GL” switch when building the
@rem 64-bit one.
@rem In general, it must be solved somehow.
rem call :downloadfile "%TCL_URL%" downloads\tcl-%BIT%.zip
rem 7z.exe x downloads\tcl-%BIT%.zip -o%DEPENDENCIES%\ > nul || exit 1
rem move /Y %DEPENDENCIES%\tcltk-%TCL_VER_LONG%.10-barebones-%ARCH% %TCL_DIR%
rem call :mklink "vim\src\%TCL_DLL%" "%TCL_DIR%\bin\%TCL_DLL%"
:skiptcl

@rem Python2
IF exist %PYTHON_DIR% goto :skippython2
@rem only install if it is not installed
call :downloadfile "%PYTHON_URL%" downloads\python-%BIT%.msi
start "" /W downloads\python-%BIT%.msi ^
  /qn TARGETDIR=%PYTHON_DIR% ADDLOCAL=DefaultFeature,PrependPath
:skippython2

@rem Python3
call :downloadfile "%PY3CORE_URL%" downloads\python3core-%BIT%.msi
call :downloadfile "%PY3EXE_URL%" downloads\python3exe-%BIT%.msi
call :downloadfile "%PY3LIB_URL%" downloads\python3lib-%BIT%.msi
call :downloadfile "%PY3DEV_URL%" downloads\python3dev-%BIT%.msi

start "" /W downloads\python3core-%BIT%.msi /qn TARGETDIR=%PYTHON3_DIR%
start "" /W downloads\python3exe-%BIT%.msi /qn TARGETDIR=%PYTHON3_DIR%
start "" /W downloads\python3lib-%BIT%.msi /qn TARGETDIR=%PYTHON3_DIR%
start "" /W downloads\python3dev-%BIT%.msi /qn TARGETDIR=%PYTHON3_DIR%

@rem Ruby
if /I "%PLATFORM%" == "arm64" goto :skipruby
@rem Download RubyInstaller binary
call :downloadfile "%RUBY_URL%" downloads\ruby-%BIT%.7z
7z.exe x -y downloads\ruby-%BIT%.7z -o%DEPENDENCIES%\ > nul || exit 1
move %DEPENDENCIES%\rubyinstaller-%RUBY_RELEASE%-%ARCH% %RUBY_DIR% > nul || exit 1

@rem RubyInstaller is built by MinGW, so we cannot use header files from it.
@rem Download the source files and generate config.h for MSVC.
call :downloadfile "%RUBY_SRC_URL%" downloads\ruby_src.zip
@rem Extract the files only we needed to reduce the building time.
7z.exe x -y downloads\ruby_src.zip */bin */include */enc/Makefile.in */win32 ^
  */common.mk -ir!version.h -xr!README.* -xr!*/win32/*.c -xr!*/win32/*.h ^
  -o.. > nul || exit 1
move ..\ruby-%RUBY_BRANCH% ..\ruby > nul || exit 1
pushd ..\ruby
call win32\configure.bat
nmake.exe -l .config.h.time || exit 1
xcopy /S /Y .ext\include %RUBY_DIR%\include\ruby-%RUBY_API_VER_LONG%
popd
:skipruby

@rem Racket
if /I "%PLATFORM%" == "arm64" goto :skipracket
call :downloadfile "%RACKET_URL%" downloads\racket-%BIT%.tgz
7z.exe x -tgzip -so downloads\racket-%BIT%.tgz | 7z.exe x -y -aoa -si -ttar ^
  -o%DEPENDENCIES%\
move %DEPENDENCIES%\racket %RACKET_DIR%
type NUL > %RACKET_DIR%\include\bc_suffix.h

@rem Install additional packages for Racket
raco.exe pkg install -i --auto r5rs-lib
:skipracket

@rem Install libintl.dll and iconv.dll
call :downloadfile "%GETTEXT_32_URL%" downloads\gettext32.zip
7z.exe e -y downloads\gettext32.zip ^
  -o%DEPENDENCIES%\gettext32 > nul || exit 1

call :downloadfile "%GETTEXT_64_URL%" downloads\gettext64.zip
7z.exe e -y downloads\gettext64.zip ^
  -o%DEPENDENCIES%\gettext64 > nul || exit 1

if /I "%PLATFORM%" == "arm64" (
  call :vcpkg gettext
)

@rem Install winpty
if /I "%PLATFORM%" == "arm64" (
  call :vcpkg winpty
  call :mklink "vim\src\winpty64.dll" "%WINPTY_VCPKG%\bin\winpty.dll"
  call :mklink "vim\src\winpty-agent.exe" "%WINPTY_VCPKG%\tools\winpty\winpty-agent.exe"
) else (
  call :downloadfile "%WINPTY_URL%" downloads\winpty.zip
  7z.exe x -y downloads\winpty.zip -o%WINPTY_DIR% > nul || exit 1
  if /I "%ARCH%"=="x64" (
    call :mklink "vim\src\winpty64.dll" "%WINPTY_DIR%\x64\bin\winpty.dll"
    call :mklink "vim\src\winpty-agent.exe" "%WINPTY_DIR%\x64\bin\winpty-agent.exe"
  ) else (
    call :mklink "vim\src\winpty32.dll" "%WINPTY_DIR%\ia32\bin\winpty.dll"
    call :mklink "vim\src\winpty-agent.exe" "%WINPTY_DIR%\ia32\bin\winpty-agent.exe"
  )
)

@rem Install UPX
@rem This is disabled, because UPX is known to be flagged as
@rem supsicious by AV vendors
rem call :downloadfile %UPX_URL% downloads\upx.zip
rem 7z.exe e -y downloads\upx.zip *\upx.exe -ovim\nsis > nul || exit 1

@rem Install ShellExecAsUser
call :downloadfile "%SHELLEXECASUSER_URL%" downloads\shellexecasuser.zip
7z.exe x -y downloads\shellexecasuser.zip ^
  -o%DEPENDENCIES%\shellexecasuser > nul || exit 1
call :mklink "%ProgramFiles(x86)%\NSIS\Plugins\x86-unicode\ShellExecAsUser.dll" "%DEPENDENCIES%\shellexecasuser\unicode\ShellExecAsUser.dll"

@rem Install Libsodium
if /I NOT "%PLATFORM%" == "arm64" (
  call :downloadfile "%LIBSODIUM_URL%" downloads\libsodium.zip
  7z.exe x -y downloads\libsodium.zip -o%DEPENDENCIES%\ > nul || exit 1
  if /I "%ARCH%"=="x64" (
    call :mklink "vim\src\libsodium.dll" "%SODIUM_DIR%\x64\Release\v143\dynamic\libsodium.dll"
  ) else (
    call :mklink "vim\src\libsodium.dll" "%SODIUM_DIR%\Win32\Release\v143\dynamic\libsodium.dll"
  )
) else (
  @rem "Compile Libsodium"
  call :downloadfile "%LIBSODIUM_SOURCE%" downloads\libsodium.zip
  7z.exe x -y downloads\libsodium.zip -o%DEPENDENCIES%\ > nul
  move /Y %DEPENDENCIES%\libsodium-1.0.20-RELEASE %DEPENDENCIES%\libsodium
  pushd %SODIUM_DIR%\builds\msvc\build\
  msbuild /m /v:q /p:Configuration=DynRelease /p:Platform=ARM64 ..\vs2022\libsodium.sln
  popd
  xcopy /E /I /H /Y %SODIUM_DIR%\src\libsodium\include %SODIUM_DIR%\include > nul
  call :mklink "vim\src\libsodium.dll" "%SODIUM_DIR%\bin\ARM64\Release\v143\dynamic\libsodium.dll"
)

@echo off
goto :eof

:build_x86
:build_x64
:: -------- building the program -------------------------------------------
cd vim\src

@ if not exist .\auto\nmake mkdir .\auto\nmake
@ copy /Y ..\..\vimdll-huge.cfg .\auto\nmake\
@ echo:"PERL_VER=%PERL_VER%">> .\auto\nmake\vimdll-huge.cfg
@ echo:"PERL=%PERL_DIR%">> .\auto\nmake\vimdll-huge.cfg
@ echo:"PYTHON=%PYTHON_DIR%">> .\auto\nmake\vimdll-huge.cfg
@ echo:"PYTHON3_VER=%PYTHON3_VER%">> .\auto\nmake\vimdll-huge.cfg
@ echo:"PYTHON3=%PYTHON3_DIR%">> .\auto\nmake\vimdll-huge.cfg
@ echo:"LUA_VER=%LUA_VER%">> .\auto\nmake\vimdll-huge.cfg
@ echo:"LUA=%LUA_DIR%">> .\auto\nmake\vimdll-huge.cfg
@rem Not supported for ARM64
if /I NOT "%PLATFORM%" == "arm64" (
  @ echo:"RUBY_VER=%RUBY_VER%">> .\auto\nmake\vimdll-huge.cfg
  @ echo:"RUBY_API_VER_LONG=%RUBY_API_VER_LONG%">> .\auto\nmake\vimdll-huge.cfg
  @ echo:"RUBY=%RUBY_DIR%">> .\auto\nmake\vimdll-huge.cfg
  @ echo:"MZSCHEME_VER=%MZSCHEME_VER%">> .\auto\nmake\vimdll-huge.cfg
  @ echo:"MZSCHEME=%RACKET_DIR%">> .\auto\nmake\vimdll-huge.cfg
)
@ echo:"SODIUM=%SODIUM_DIR%">> .\auto\nmake\vimdll-huge.cfg
@ echo:>> .\auto\nmake\vimdll-huge.cfg

@rem Build GUI/CUI version
nmake.exe -lf Make_mvc.mak @auto\nmake\vimdll-huge.cfg || exit 1

@rem Build translations
pushd po

nmake.exe -lf Make_mvc.mak "GETTEXT_PATH=%DEPENDENCIES%\gettext%BIT%" ^
  "VIMRUNTIME=..\..\runtime" install-all || exit 1

popd

:check_executable
:: ----------------------------------------------------------------------
start "" /W .\gvim.exe -silent -register
start "" /W .\gvim.exe -u NONE -c "redir @a | ver | 0put a | wq!" ver.txt
type ver.txt
.\vim.exe --version

@rem Print interface versions
start "" /W .\gvim.exe -u NONE -S ..\..\if_ver.vim -c quit
type if_ver.txt

goto :eof

:package_x86
:package_x64
:: -------- creating packages ----------------------------------------------
if defined APPVEYOR_BUILD_FOLDER ( cd %APPVEYOR_BUILD_FOLDER% )

@rem Check if we need to copy libgcc_s_sjlj-1.dll.
if /I NOT "%PLATFORM%"=="arm64" (
"%VCToolsInstallDir%bin\HostX86\x86\dumpbin.exe" ^
  /DEPENDENTS %DEPENDENCIES%\gettext32\libintl-8.dll | findstr ^
  /LC:"libgcc_s_sjlj-1.dll" && set "INCLUDE_LIBGCC=1" || set "INCLUDE_LIBGCC=0"
) else set "INCLUDE_LIBGCC=0"

mkdir vim\runtime\GvimExt64
mkdir vim\runtime\GvimExt32

if /I "%PLATFORM%"=="arm64" (
  @rem Building ARM64 version of gvimext.dll for the installer
  pushd vim\src\GvimExt
  nmake.exe -lf Make_mvc.mak clean all > ..\gvimext.log"
  popd
  type vim\src\gvimext.log
  call :mklink "vim\runtime\GvimExt64\gvimext.dll" "vim\src\GvimExt\gvimext.dll"
  call :mklink "vim\runtime\GvimExt64\README.txt" "vim\src\GvimExt\README.txt"
  call :mklink "vim\runtime\GvimExt64\gvimext.inf" "vim\src\GvimExt\gvimext.inf"
  call :mklink "vim\runtime\GvimExt64\GvimExt.reg" "vim\src\GvimExt\GvimExt.reg"
  copy /Y vim\src\GvimExt\gvimext.dll vim\src\GvimExt\gvimext64.dll

  copy /y %ICONV_VCPKG%\bin\iconv-2.dll vim\runtime\libiconv-2.dll
  copy /y %INTL_VCPKG%\bin\intl-8.dll vim\runtime\libintl-8.dll
  call :mklink "vim\runtime\GvimExt64\libiconv-2.dll" "vim\runtime\libiconv-2.dll"
  call :mklink "vim\runtime\GvimExt64\libintl-8.dll" "vim\runtime\libintl-8.dll"

) else (
  @rem Build both 64- and 32-bit versions of gvimext.dll for the installer
  start "" /W cmd /C "%VCVARSALL% x64 && cd vim\src\GvimExt && nmake.exe -lf Make_mvc.mak CPU=AMD64 clean all > ..\gvimext.log"
  type vim\src\gvimext.log
  call :mklink "vim\runtime\GvimExt64\gvimext.dll" "vim\src\GvimExt\gvimext.dll"
  call :mklink "vim\runtime\GvimExt64\README.txt" "vim\src\GvimExt\README.txt"
  call :mklink "vim\runtime\GvimExt64\gvimext.inf" "vim\src\GvimExt\gvimext.inf"
  call :mklink "vim\runtime\GvimExt64\GvimExt.reg" "vim\src\GvimExt\GvimExt.reg"
  ren vim\src\GvimExt\gvimext.dll gvimext64.dll

  start "" /W cmd /C "%VCVARSALL% x86 && cd vim\src\GvimExt && nmake.exe -lf Make_mvc.mak CPU=i386 clean all > ..\gvimext.log"
  type vim\src\gvimext.log
  call :mklink "vim\runtime\GvimExt32\gvimext.dll" "vim\src\GvimExt\gvimext.dll"
  call :mklink "vim\runtime\GvimExt32\README.txt" "vim\src\GvimExt\README.txt"
  call :mklink "vim\runtime\GvimExt32\gvimext.inf" "vim\src\GvimExt\gvimext.inf"
  call :mklink "vim\runtime\GvimExt32\GvimExt.reg" "vim\src\GvimExt\GvimExt.reg"

  call :mklink "vim\runtime\libiconv-2.dll" "%DEPENDENCIES%\gettext%BIT%\libiconv-2.dll"
  call :mklink "vim\runtime\libintl-8.dll" "%DEPENDENCIES%\gettext%BIT%\libintl-8.dll"
  if "%INCLUDE_LIBGCC%-%BIT%"=="1-32" (
    call :mklink "vim\runtime\libgcc_s_sjlj-1.dll" "%DEPENDENCIES%\gettext32\libgcc_s_sjlj-1.dll"
  )

  call :mklink "vim\runtime\GvimExt32\libiconv-2.dll" "%DEPENDENCIES%\gettext32\libiconv-2.dll"
  call :mklink "vim\runtime\GvimExt32\libintl-8.dll" "%DEPENDENCIES%\gettext32\libintl-8.dll"
  if "%INCLUDE_LIBGCC%"=="1" (
    call :mklink "vim\runtime\GvimExt32\libgcc_s_sjlj-1.dll" "%DEPENDENCIES%\gettext32\libgcc_s_sjlj-1.dll"
  )
)

call :mklink "vim\runtime\README.txt" "vim\README.txt"
call :mklink "vim\runtime\LICENSE.txt" "vim\LICENSE"
call :mklink "vim\runtime\uninstall.txt" "vim\uninstall.txt"
call :mklink "vim\runtime\vimtutor.bat" "vim\vimtutor.bat"
call :mklink "vim\runtime\vim.ico" "vim\src\vim.ico"
call :mklink "vim\runtime\gvim.exe" "vim\src\gvim.exe"
call :mklink "vim\runtime\install.exe" "vim\src\install.exe"
call :mklink "vim\runtime\tee.exe" "vim\src\tee\tee.exe"
call :mklink "vim\runtime\vim%BIT%.dll" "vim\src\vim%BIT%.dll"
call :mklink "vim\runtime\vim.exe" "vim\src\vim.exe"
call :mklink "vim\runtime\vimrun.exe" "vim\src\vimrun.exe"
call :mklink "vim\runtime\uninstall.exe" "vim\src\uninstall.exe"
call :mklink "vim\runtime\xxd.exe" "vim\src\xxd\xxd.exe"
call :mklink "vim\runtime\libsodium.dll" "vim\src\libsodium.dll"
call :mklink "vim\runtime\diff.exe" ".\diff.exe"
call :mklink "vim\runtime\winpty%BIT%.dll" "vim\src\winpty%BIT%.dll"
call :mklink "vim\runtime\winpty-agent.exe" "vim\src\winpty-agent.exe"

set "VIM_DIR=vim%MAJOR%%MINOR%"
ren vim\runtime %VIM_DIR%

if /I "%PLATFORM%"=="arm64" (
  set CUSTOM=arm64
) else (
  set CUSTOM=%ARCH%
)

@rem Create zip packages, but skip pdb package for ARM64
if /I NOT "%PLATFORM%"=="arm64" (
  7z.exe a -mx=9 gvim_%VER_NUM%_%CUSTOM%_pdb.zip vim\src\*.pdb
)

7z.exe a -r -mx=9 -xr@exclist.txt gvim_%VER_NUM%_%CUSTOM%.zip vim\%VIM_DIR%

ren vim\%VIM_DIR% runtime


@rem Create installer

mklink /J vim\runtime\GvimExt vim\src\GvimExt

pushd vim\nsis

if /I "%ARCH%"=="x64" (
  set WIN64=1
) else (
  set WIN64=0
)

nmake.exe -lf Make_mvc.mak "X=OutFile ..\..\gvim_%VER_NUM%_%CUSTOM%.exe" ^
  "GETTEXT=%DEPENDENCIES%" "VIMSRC=..\runtime" "VIMRT=..\runtime" ^
  "INCLUDE_LIBGCC=%INCLUDE_LIBGCC%" "SRC=..\runtime" "WIN64=%WIN64%" ^
  "VIMTOOLS=..\runtime" || exit 1

popd

@rem Create zipfile for signing with signpath.io
@rem This will create a single zip file that should be uploaded to signpath
@rem signpath can then sign each artifact inside the zip file
@rem (the Vim zip archive as well as the installer)
echo:Creating Signpath Zip Archive
7z.exe a -mx=1 unsigned-gvim_%VER_NUM%_%CUSTOM%.zip ^
  gvim_%VER_NUM%_%CUSTOM%.zip gvim*.exe

@echo off
goto :eof

:test_x86
:test_x64
:: -------- testing the build ----------------------------------------------

set "PLTCOLLECTS=%RACKET_DIR%\collects"
set "PLTCONFIGDIR=%RACKET_DIR%\etc"
cd vim\src\testdir
nmake.exe -lf Make_mvc.mak "VIMPROG=..\gvim.exe" || exit 1
nmake.exe -lf Make_mvc.mak clean
nmake.exe -lf Make_mvc.mak "VIMPROG=..\vim.exe" || exit 1

@echo off
goto :eof


:onsuccess_x64
goto :eof
:onsuccess_x86
:: ----------------------------------------------------------------------
@rem Turn off the draft status of the release when x86 is successfully finished.

if not defined APPVEYOR_REPO_TAG_NAME goto :eof

call :get_release_id

@rem Turn off the draft status.
curl -# -X PATCH -H "Authorization: token %auth_token%" ^
  -H "Accept: application/vnd.github.v3+json" ^
  "https://api.github.com/repos/%APPVEYOR_REPO_NAME%/releases/%REL_ID%" ^
  -d "{\"draft\": false}"
goto :eof


:onfailure_x64
goto :eof
:onfailure_x86
:: ----------------------------------------------------------------------
@rem Delete the release when x86 is failed.

if not defined APPVEYOR_REPO_TAG_NAME goto :eof

call :get_release_id

@rem Delete the release.
curl -# -X DELETE -H "Authorization: token %auth_token%" ^
  -H "Accept: application/vnd.github.v3+json" ^
  "https://api.github.com/repos/%APPVEYOR_REPO_NAME%/releases/%REL_ID%"
goto :eof


:get_release_id
:: ----------------------------------------------------------------------
@rem Get the ID of the release. Set the result to %REL_ID%.

set "PS=powershell.exe"
set "PSFLAGS=-NoLogo -NoProfile -Command"

curl -# -H "Authorization: token %auth_token%" ^
  -H "Accept: application/vnd.github.v3+json" ^
  "https://api.github.com/repos/%APPVEYOR_REPO_NAME%/releases" > releases.json
1> nul %PS% %PSFLAGS% ((Get-Content .\releases.json -Raw ^| ^
  ConvertFrom-Json) ^| Where-Object name -EQ '%TAG_NAME%').id ^| ^
  New-Item .\release_id.txt -Force"

type release_id.txt
for /F "delims=" %%I in (release_id.txt) do set "REL_ID=%%I"
goto :eof

:clean_x64
:clean_x86
:: ----------------------------------------------------------------------
@rem clean up artifacts
pushd %DEPENDENCIES%
rd /s /q *
popd
pushd vim
git clean -xdf
git reset --hard
popd
git reset --hard
goto :eof

:downloadfile
:: ----------------------------------------------------------------------
@rem call :downloadfile <URL> <localfile>
if exist %2 exit /B
curl -# -f -L %~1 -o %2 && exit /B

if ERRORLEVEL 1 (
  rem Retry once.
  curl -f -L %~1 -o %2 || exit 1
)
@goto :eof

:vcpkg
@rem call :vcpkg package
vcpkg --vcpkg-root="%VCPKG_ROOT%" install %1:arm64-windows && exit /B
@goto :eof

:mklink
@rem call :mklink "linkname" "target"
if exist %1 exit /B
mklink /H %1 %2
@goto :eof
EndLocal

@rem vim:ft=dosbatch:ts=8:sts=2:sw=2:noet:
