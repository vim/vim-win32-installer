[![Build status](https://ci.appveyor.com/api/projects/status/0x8kevh62dkdt7mu?svg=true)](https://ci.appveyor.com/project/chrisbra/vim-win32-installer)
[![Github All Releases](https://img.shields.io/github/downloads/vim/vim-win32-installer/total.svg?maxAge=2592000)](https://github.com/vim/vim-win32-installer)
[![GitHub tag](https://img.shields.io/github/tag/vim/vim-win32-installer.svg?maxAge=2592000)](https://github.com/vim/vim-win32-installer)


# Vim Installer and Archives (Win32 and Win64)

This is a project for building Nightly Vim Windows build snapshots
automatically ([more information](http://vim.wikia.com/wiki/Where_to_download_Vim)).

[Download](https://github.com/vim/vim-win32-installer/releases) and execute the
most recent `gvim_8.._x86.exe` file to install Vim. The exe file contains the
(32bit) installer while the .zip files contain an archive of the 32bit (`_x86`)
or 64bit versions (`_x64`). To install it, extract the archive and update your
PATH variable. The installer will do that automatically and provide some
additional extensions (e.g. Edit with Vim menu).

If you need a dynamic interface to Perl, Python2, Python3, Ruby, TCL, Lua or
Racket/MzScheme, make sure you also install the following. Vim will work
without it, but some Plugin might need this additional dependency. (e.g.
[Gundo](https://github.com/sjl/gundo.vim) needs a working Python2 installation,
[Command-T](https://github.com/wincent/command-t) needs a working Ruby
installation and [Neocomplete](https://github.com/Shougo/neocomplete.vim) needs
a working Lua installation). This means, those interpreters have to be
installed in addition to Vim. Without it Vim won't be able to use that feature!
You can find those interperters here:

* [Strawberry Perl](http://strawberryperl.com/) 5.28
* [ActiveTcl](http://www.activestate.com/activetcl/downloads) 8.6.6
* [LuaBinaries](http://luabinaries.sourceforge.net/download.html) 5.3
* [Python](https://www.python.org/downloads/) 2.7
* [Python 3](https://www.python.org/downloads/) 3.6
* [Racket](https://download.racket-lang.org/) 6.10.1
* [RubyInstaller2](http://rubyinstaller.org/downloads/) 2.4

Make sure that you install the same architecture (32bit/64bit) for those
libraries that matches your Vim installation.

Additionally the binaries include the new terminal feature for Vim and
therefore contain the winpty.dll (32bit or 64bit) and the winpty-agent.exe from
the [winpty repository](https://github.com/rprichard/winpty). This feature is
currently considered experimental. Read the help at [:h
terminal.txt](http://vimhelp.appspot.com/terminal.txt.html) for more
information.

Note: The zip archive might be considered unsecure in Windows, causing Windows
to display a dialog box "These files might be harmful to your computer...". If
you want to disable this warning, you need to "unblock" the zip file. Do that
in the properties dialog of the zip file, first tab General and look for the
security section and click on "Unblock".

Note: If you want to test some patches, place them in the patch directory with
the extension `.patch`. They will be applied before building Vim and the binary
will then be tested against the test suite.

See: [Vim Repository](https://github.com/vim/vim) for the Vim source.

# License & Copyright

Most work was done by Ken Takata (@k-takata) and Christian Brabandt (@chrisbra).

The Vim license applies (see [:h license](http://vimhelp.appspot.com/uganda.txt.html#license)) to all the build scripts in this repository.
Note, that Vim is included as a submodule and comes with its own license (although is also released under the Vim license).
