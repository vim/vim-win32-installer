[![Build status](https://ci.appveyor.com/api/projects/status/0x8kevh62dkdt7mu?svg=true)](https://ci.appveyor.com/project/chrisbra/vim-win32-installer)


# Vim Win32 Installer and Archives (Win32 and Win64)

This is a project for building Nightly Vim Windows build snapshots automatically ([more information](http://vim.wikia.com/wiki/Where_to_download_Vim)).

[Download](https://github.com/vim/vim-win32-installer/releases) and execute the
most recent `gvim_7.4.X_x86.exe` file to install Vim. The exe file contains the
(32bit) installer while the .zip files contain an archive of the 32bit (`_x86`)
or 64bit versions (`_x64`). To install it, extract the archive and update your
PATH variable. The installer will do that automatically and provide some
additional extensions (e.g. Edit with Vim menu).

If you need a dynamic interface to Perl, Python2, Python3, Ruby, TCL, Lua or
Racket/MzScheme, make sure you also install the following. Vim will work
without it, but some Plugin might need this additional dependency. (e.g. Gundo
needs a working Pyhton2 installation, Command-T needs a working Ruby
installation and Neocomplete needs a working Lua installation). This means,
those interpreters have to be installed in addition to Vim. Without it Vim
won't be able to use that feature! You can find those interperters here:

* [ActivePerl](http://www.activestate.com/activeperl/downloads) 5.22
* [ActiveTcl](http://www.activestate.com/activetcl/downloads) 8.6
* [LuaBinaries](http://luabinaries.sourceforge.net/download.html) 5.3
* [Python](https://www.python.org/downloads/) 2.7
* [Python](https://www.python.org/downloads/) 3.4
* [Racket](https://download.racket-lang.org/) 6.4
* [RubyInstaller](http://rubyinstaller.org/downloads/) 2.2

Make sure that you install the same architecture (32bit/64bit) that matches
your Vim installation.

Note: The zip archive might be considered unsecure in Windows, causing Windows to display a dialog box "These files might be harmful to your computer...". If you want to disable this warning, you need to "unblock" the zip file. Do that in the properties dialog of the zip file, first tab General and look for the security section and click on "Unblock".

Note: If you want to test some patches, place them in the patch directory with the extension `.patch`. They will be applied before building Vim and the binary will then be tested against the test suite.

See: https://github.com/vim/vim
