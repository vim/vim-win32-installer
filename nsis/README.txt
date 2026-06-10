This builds a one-click installer for Vim for MS Windows using the Nullsoft
Installation System (NSIS), available at http://nsis.sourceforge.net/

The installer is automatically built by the vim-win32-installer CI.
However, if you want to build it locally (e.g. for debugging), follow the
steps below.

Assuming you have already cloned the vim-win32-installer repository into your
local directory, say $WORKDIR.
Run the following commands in GitBash unless otherwise stated.

1. Clone the Vim repository into $WORKDIR using the git command:

	cd $WORKDIR
	git clone https://github.com/vim/vim.git

2. Clone the NsisMultiUser plugin (https://github.com/Drizin/NsisMultiUser)
   into $WORKDIR.
   We are using the forked version instead of the original one.

	git clone https://github.com/k-takata/NsisMultiUser.git

3. Download and unpack the EnVar plugin
   (https://nsis.sourceforge.io/EnVar_plug-in)

	curl -O https://nsis.sourceforge.io/mediawiki/images/7/7f/EnVar_plugin.zip
	unzip EnVar_plugin.zip -d EnVar_plugin

4. Download a zip package from the release page of the vim-win32-installer
   repository.

   For example, download the 9.2.0623 package for x64 and unpack it to
   $WORKDIR/package/vim-package-x64:

	cd $WORKDIR/package
	curl -LO https://github.com/vim/vim-win32-installer/releases/download/v9.2.0623/gvim_9.2.0623_x64.zip
	unzip gvim_9.2.0623_x64.zip -d vim-package-x64

5. Create the license files for the installer package.

	cd $WORKDIR
	./scripts/create_nsis_lic_files.sh ./vim

6. Build the Vim launcher
   Open a Visual Studio Command Prompt for the target you want to build, then:

	cd %WORKDIR%\vim-launcher
	nmake -f Make_mvc.mak

7. Build the installer
   Now the directory structure should be like this:

	<vim-win32-installer directory> ($WORKDIR)
	    + EnVar_plugin/
	    + NsisMultiUser/
	    + nsis/
	    |	README.txt (This file)
	    |	gvim.nsi
	    |
	    + package/
	    |	vim-package-x64/
	    |	    vim/
	    |		vim92/
	    + vim/
	    |	lang/
	    |	    LICENSE.*.nsis.txt
	    |
	    + vim-launcher/
		gvim.exe
		vim.exe

   Run the following command in a Command Prompt:

	set PKG=..\package\vim-package-x64\vim\vim92
	"%ProgramFiles(x86)%\NSIS\makensis" ^
		/INPUTCHARSET UTF8 ^
		/DVIMBIN=%PKG% ^
		/DVIMRT=%PKG% ^
		/DINCLUDE_LIBGCC=0 ^
		/DWIN64=1 ^
		/DARM64=0 ^
		/DDEBUG ^
		gvim.nsi

   If you build an x86 or arm64 package, set PKG, /DWIN64, and /DARM64
   correctly.

   If /DDEBUG is specified, the installer will be built in debug mode.
   The DebugPrint macro can be used for debug print. E.g.:

	!insertmacro DebugPrint "debug message"

   The debug message can be seen in DebugView (or DebugView++).
   Also, it turns off LZMA compression to build faster.


If you want to build an installer without using a zip package, see the
following scripts in this repository:

	.github/workflow/build-vim.yml
	scripts/prepare_package_dir.bat



----- OLD VERSION -----

To build the installable .exe file:

Preparatory stage

1.  Clone using the git tool the Vim repository or download its zip file
    available at:
	https://github.com/vim/vim

2.  Go to the "/src" directory and build the Vim editor, making sure to use the
    following variable values: "GUI=yes"; "OLE=yes"; "VIMDLL=yes". See
    INSTALLpc.txt and Make_mvc.mak for details.

3.  Go to the GvimExt directory and build gvimext.dll (or get it from a binary
    archive).  Both 64- and 32-bit versions are needed and should be placed
    as follows:
	64-bit: src/GvimExt/gvimext64.dll
	32-bit: src/GvimExt/gvimext.dll

4.  Get a "diff.exe" program.  If you skip this the built-in diff will always
    be used (which is fine for most users).
    You can find one in previous Vim versions or in this archive:
	https://www.mediafire.com/file/9edk4g3xvfgzby0/diff4Vim.zip/file
    When will you have "diff.exe" put it in the "../.." directory (above the
    "vim91" directory, it's the same for all Vim versions).  However, you can
    specify a different directory by specifying the appropriate makefile value.
    How to do this is described below.

5.  For the terminal window to work in Vim, the library winpty is required.
    You can get it at the following url:
	https://github.com/rprichard/winpty/releases/download/0.4.3/winpty-0.4.3-msvc2015.zip
    For the 32-bit version, rename "winpty.dll" from ia32/bin to "winpty32.dll",
    and for the 64-bit version — "winpty.dll" from x64/bin to "winpty64.dll".
    Put the renamed file and "winpty-agent.exe" in "../.." (above the "vim91"
    directory).  However, you can specify a different directory by specifying
    the appropriate makefile value. How to do this is described below.

6.  To use stronger encryption, add the Sodium library.  You can get it here:
	https://github.com/jedisct1/libsodium/releases/download/1.0.19-RELEASE/libsodium-1.0.19-msvc.zip
    Unpack the archive.  Put the "libsodium.dll" from
    path/to/libsodium/Win32/Release/v143/dynamic for the 32‐bit version or
    path/to/libsodium/X64/Release/v143/dynamic for the 64‐bit version in the
    "../.." directory (above the "vim91" directory, where "diff.exe" and
    "winpty{32|64}.dll").

7.  Get gettext and iconv DLLs from the following site:
	https://github.com/mlocati/gettext-iconv-windows/releases
    Both 64- and 32-bit versions are needed.
    Download the files gettextX.X.X.X-iconvX.XX-shared-{32,64}.zip, extract
    DLLs and place them as follows:

	<GETTEXT directory>
	    |
	    + gettext32/
	    |	libintl-8.dll
	    |	libiconv-2.dll
	    |	libgcc_s_sjlj-1.dll
	    |
	    + gettext64/
		libintl-8.dll
		libiconv-2.dll

    The default <GETTEXT directory> is "../..".  However, you can specify a
    different directory by specifying the appropriate makefile value. How to do
    this is described below.

8.  Install NSIS if you didn't do that already.
    Download Unicode version the ShellExecAsUser plug-in for NSIS from:
	https://nsis.sourceforge.io/ShellExecAsUser_plug-in
    and put "ShellExecAsUser.dll" to path\to\NSIS\Plugins\x86-unicode

Installer assembly stage

    On MS Windows, open the Developer Command Prompt for VS and go to the
    "/nsis" directory and type the command
	    nmake.exe -lf Make_mvc.mak [variables] all

    After the installer is created and you copy it to the desired location, run
    the following command in the "/nsis" directory
	    nmake.exe -lf Make_mvc.mak clean

    On UNIX-like systems, go to the "/nsis" directory and type the command
	    make -f Makefile [variables] all

    After the installer is created and you copy it to the desired location, run
    the following command in the "/nsis" directory
	    make -f Makefile clean

Variables and their values available for building the installer (not mandatory):

    "VIMSRC=<dir>"	— directory where location of gvim_ole.exe, vimw32.exe,
			    GvimExt/*, etc.
    "VIMRT=<dir>"	— directory where location of runtime files.
    "VIMTOOLS=<dir>"    — directory where location of extra tools: diff.exe,
			    winpty{32|64}.dll, winpty-agent.exe, libsodium.dll.
    "GETTEXT=<dir>"     — directory where location of gettext libraries.
    "HAVE_UPX=1"	— additional compression of the installer.  UPX program
			    must be installed.
    "HAVE_NLS=0"	— do not add native language support.
    "HAVE_MULTI_LANG=0" — to create an English-only the installer.
    "WIN64=1"		— to create a 64-bit the installer.
    "ARM64=1"		— to create the installer for ARM64. The WIN64 variable
			    must be set to 1.
    "X=<scriptcmd>"	— executes scriptcmd in script.  If multiple scriptcmd
			    are specified, they are separated by a semicolon.
			    Example "X=OutFile MyVim.exe;XPMode on"
    "MKNSIS=<dir>"	— the directory where the "makensis.exe" program is
			    located.

Note: for icons used in the installer, see the README.txt in the icons.zip
