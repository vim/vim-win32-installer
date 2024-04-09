@echo off
setlocal
@set "PS=powershell.exe"
@set "PSFLAGS=-NoLogo -NoProfile -Command"

%PS% %PSFLAGS% (([System.IO.File]::ReadAllText('.\version.h')) ^
-replace '# define VIM_VERSION_PATCHLEVEL\s+0', ^
\"# define VIM_VERSION_PATCHLEVEL`t`t$([decimal]$env:PATCHLEVEL)\") ^| New-Item ^
-Path . -Name 'version.h' -ItemType file -Force
endlocal
@goto:EOF

@rem %PS% %PSFLAGS% (([System.IO.File]::ReadAllText('.\version.h')) ^
@rem -replace '# define VIM_VERSION_PATCHLEVEL\s+0', ^
@rem \"# define VIM_VERSION_PATCHLEVEL`t`t$([decimal]$env:PATCHLEVEL)\" ^
@rem -replace '#define VIM_VERSION_PATCHLEVEL_STR\s+VIM_TOSTR.+', ^
@rem \"#define VIM_VERSION_PATCHLEVEL_STR`tVIM_TOSTR($($env:PATCHLEVEL))\") ^| ^
@rem New-Item -Path . -Name 'version.h' -ItemType file -Force
