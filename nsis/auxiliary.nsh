# -*- coding: utf-8 -*-
# NSIS helper file for creating a self-installing exe for Vim.
# Contains service macros and functions.
# Last Change:	2026-06-10
#

!ifndef __AUXILIARY__NSH__
  !define __AUXILIARY__NSH__

# See https://nsis.sourceforge.io/LogicLib
;FileExists is already part of LogicLib, but returns true for directories
;as well as files
  !macro _FileExists2 _a _b _t _f
    !insertmacro _LOGICLIB_TEMP
    StrCpy $_LOGICLIB_TEMP "0"
;if path is not blank, continue to next check
    StrCmp `${_b}` `` +4 0
;if path exists, continue to next check (IfFileExists returns true if this
;is a directory)
    IfFileExists `${_b}` `0` +3
;if path is not a directory, continue to confirm exists
    IfFileExists `${_b}\*.*` +2 0
    StrCpy $_LOGICLIB_TEMP "1" ;file exists
;now we have a definitive value - the file exists or it does not
    StrCmp $_LOGICLIB_TEMP "1" `${_t}` `${_f}`
  !macroend
  !undef FileExists
  !define FileExists `"" FileExists2`
  !macro _DirExists _a _b _t _f
    !insertmacro _LOGICLIB_TEMP
    StrCpy $_LOGICLIB_TEMP "0"
;if path is not blank, continue to next check
    StrCmp `${_b}` `` +3 0
;if directory exists, continue to confirm exists
    IfFileExists `${_b}\*.*` 0 +2
    StrCpy $_LOGICLIB_TEMP "1"
    StrCmp $_LOGICLIB_TEMP "1" `${_t}` `${_f}`
  !macroend
  !define DirExists `"" DirExists`

# Get home directory
  !macro GetHomeDir un
    Function ${un}GetHomeDir
      Push $0
      Push $1
      ReadEnvStr $0 "HOME"
      ${If} $0 == ""
	ReadEnvStr $0 "HOMEDRIVE"
	ReadEnvStr $1 "HOMEPATH"
	StrCpy $0 "$0$1"
	${If} $0 == ""
	  ReadEnvStr $0 "USERPROFILE"
	${EndIf}
      ${EndIf}
      Pop $1
      Exch $0  ; put $0 on top of stack, restore $0 to original value
    FunctionEnd
  !macroend

  !insertmacro GetHomeDir ""
  !insertmacro GetHomeDir "un."

# Saving the status of sections of the current installation in the registry
  !macro SaveSectionSelection suffix section_id reg_value
    ${If} ${SectionIsSelected} ${section_id}
      WriteRegDWORD SHCTX "${UNINST_REG_KEY_VIM}${suffix}" ${reg_value} 1
    ${Else}
      WriteRegDWORD SHCTX "${UNINST_REG_KEY_VIM}${suffix}" ${reg_value} 0
    ${EndIf}
  !macroend

# Reading the status of sections from the registry of the previous installation
  !macro LoadSectionSelection suffix section_id reg_value
    ClearErrors
    ReadRegDWORD $3 SHCTX "${UNINST_REG_KEY_VIM}${suffix}" ${reg_value}
    ${IfNot} ${Errors}
      ${If} $3 <> 0
	!insertmacro SelectSection ${section_id}
      ${Else}
	!insertmacro UnselectSection ${section_id}
      ${EndIf}
    ${EndIf}
  !macroend

# Reading the settings for _vimrc from the registry of a previous installation
  !macro LoadDefaultVimrc suffix out_var reg_value default_value
    ClearErrors
    ReadRegStr ${out_var} SHCTX "${UNINST_REG_KEY_VIM}${suffix}" ${reg_value}
    ${If} ${Errors}
    ${OrIf} ${out_var} == ""
      StrCpy ${out_var} ${default_value}
    ${EndIf}
  !macroend

# Parse the command line option and set the section status
  !macro ParseCmdSectionSelection cmdline cmdopt section_id
    ClearErrors
    ${GetOptions} ${cmdline} ${cmdopt} $4
    ${IfNot} ${Errors}
      ${If} $4 <> 0
	!insertmacro SelectSection ${section_id}
      ${Else}
	!insertmacro UnselectSection ${section_id}
      ${EndIf}
    ${EndIf}
  !macroend

# Parse the command line option for _vimrc
  !macro ParseCmdVimrc cmdline cmdopt out_var
    ClearErrors
    ${GetOptions} ${cmdline} ${cmdopt} $4
    ${IfNot} ${Errors}
      StrCpy ${out_var} $4
    ${EndIf}
  !macroend


!endif # __AUXILIARY__NSH__
# vi:set ts=8 sw=2 sts=2 tw=79 wm=0 ft=nsis:
