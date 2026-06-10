#
# VIM - Vi IMproved	Vim launcher
#

all: gvim.exe vim.exe

CFLAGS=/nologo /c /GS- /GF /O2 /W4
LDFLAGS=/nologo /NODEFAULTLIB /MAP
RCFLAGS=/nologo
LIBS=kernel32.lib advapi32.lib user32.lib


# GUI
gvim.exe: gvim.obj gvim.res
	link $(LDFLAGS) /subsystem:windows /out:$@ $(LIBS) $**

gvim.obj: vim-launcher.c
	$(CC) $(CFLAGS) /DFEAT_GUI /Fo$@ $**

gvim.res: vim-launcher.rc vim-launcher.manifest vim-launcher.ico
	$(RC) $(RCFLAGS) /DFEAT_GUI /Fo$@ vim-launcher.rc


# Console
vim.exe: vim.obj vim.res
	link $(LDFLAGS) /subsystem:console /out:$@ $(LIBS) $**

vim.obj: vim-launcher.c
	$(CC) $(CFLAGS) /Fo$@ $**

vim.res: vim-launcher.rc vim-launcher.manifest vim-launcher.ico
	$(RC) $(RCFLAGS) /Fo$@ vim-launcher.rc


clean:
	-del gvim.exe gvim.map gvim.obj gvim.res
	-del vim.exe vim.map vim.obj vim.res
