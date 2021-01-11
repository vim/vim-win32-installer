[![Build status](https://ci.appveyor.com/api/projects/status/0x8kevh62dkdt7mu?svg=true)](https://ci.appveyor.com/project/chrisbra/vim-win32-installer)
[![Github All Releases](https://img.shields.io/github/downloads/vim/vim-win32-installer/total.svg?maxAge=2592000)](https://github.com/vim/vim-win32-installer/releases)
[![GitHub tag](https://img.shields.io/github/tag/vim/vim-win32-installer.svg?maxAge=2592000)](https://github.com/vim/vim-win32-installer)


# Vim Installer and Archives (Win32 and Win64)

This is a project for building Nightly Vim Windows build snapshots
automatically ([more information](https://vim.fandom.com/wiki/Where_to_download_Vim)).

[Download](https://github.com/vim/vim-win32-installer/releases/latest) and execute the
most recent `gvim_x.y.pppp_x86.exe` file to install Vim (where `x.y` is the
release version and `pppp` is the patch number). The exe files contain the
(32bit) installer while the .zip files contain an archive of the 32bit (`_x86`)
or 64bit versions (`_x64`). To install it, extract the archive and update your
PATH variable. The installer will do that automatically and provide some
additional extensions (e.g. Edit with Vim menu).
The `gvim...pdb.zip` file only contains the corresponding pdb files for debugging the binaries.

The `gvim.<version>.yml` contains the corresponding winget manifest (as yaml)
which might in the future be used to upload to the winget package repository.
Currently (12/2020), there does not seem to exist an automatic workflow, so you
can use this to contribute to [winget](https://github.com/microsoft/winget-pkgs),
but you may want to replace the URL and hash of the unsigned 64bit installer by
the signed one, if it exists (this is currently not automated).

Note: Due to the expiration of the old certificate, a new certificate to sign the binaries has
been created and will be used starting with the next release after April 14th, 2020.
This may cause a SmartScreen warning by Windows because the certificate is new. Hopefully this
warning will vanish, once the certificate has been used more widely.
If you want to avoid this warning, you can use the latest release with the old certificate
[v8.2.577](https://github.com/vim/vim-win32-installer/releases/tag/v8.2.0577).

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
* [Python 3](https://www.python.org/downloads/) 3.9
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
security section and click on "Unblock". However using a signed release might
prevent that behaviour in Windows eventually (see also next paragraph).

Creating a signed binary and installer still requires manual effort, therefore
not every release will be signed. They will be provided on a best effort basis
occasionaly. Signing the releases is provided by
[SignPath](https://about.signpath.io/). If there haven't been any signed
releases for a long time, feel free to request a new one by creating an
[issue](https://github.com/vim/vim-win32-installer/issues) here.

Note: If you want to test some patches, place them in the patch directory with
the extension `.patch`. They will be applied before building Vim and the binary
will then be tested against the test suite.

See: [Vim Repository](https://github.com/vim/vim) for the Vim source.

# License & Copyright

Most work was done by Ken Takata (@k-takata) and Christian Brabandt (@chrisbra).

The Vim license applies (see [:h license](http://vimhelp.appspot.com/uganda.txt.html#license)) to all the build scripts in this repository.
Note, that Vim is included as a submodule and comes with its own license (although is also released under the Vim license).
