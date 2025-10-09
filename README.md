[![Build status](https://ci.appveyor.com/api/projects/status/0x8kevh62dkdt7mu?svg=true)](https://ci.appveyor.com/project/chrisbra/vim-win32-installer)
[![GitHub All Releases](https://img.shields.io/github/downloads/vim/vim-win32-installer/total)](https://github.com/vim/vim-win32-installer/releases)
[![Latest GitHub Release](https://img.shields.io/github/v/release/vim/vim-win32-installer)](https://github.com/vim/vim-win32-installer/releases/latest)


# Vim Installer and Vim Zip-Archives (Win32, Win64, ARM64)

This is a project for building Nightly and Stable Vim Windows build snapshots
automatically ([more information](https://vim.fandom.com/wiki/Where_to_download_Vim)).

[Download](https://github.com/vim/vim-win32-installer/releases/latest) and execute the
most recent `gvim_x.y.pppp_x86.exe` file to install Vim (where `x.y` is the
release version and `pppp` is the patch number). The exe files contain the
(32bit) installer while the .zip files contain an archive of the 32bit (`_x86`)
or 64bit versions (`_x64`). To install it, extract the archive and update your
PATH variable. The installer will do that automatically and provide some
additional extensions (e.g. Edit with Vim menu).
The `gvim...pdb.zip` file only contains the corresponding pdb files for debugging the binaries.

## ARM64
ARM64 builds is currently being worked on. Will occassionally be provided until it is fully automatic.

If you need a dynamic interface to Perl, Python2, Python3, Ruby, <del>TCL,</del> Lua or
Racket/MzScheme, make sure you also install the following. Vim will work
without it, but some Plugin might need this additional dependency. (e.g.
[Gundo](https://github.com/sjl/gundo.vim) needs a working Python2 installation,
[Command-T](https://github.com/wincent/command-t) needs a working Ruby
installation and [Neocomplete](https://github.com/Shougo/neocomplete.vim) needs
a working Lua installation). This means, those interpreters have to be
installed in addition to Vim. Without it Vim won't be able to use that feature!
You can find those interperters here:

* [Strawberry Perl](http://strawberryperl.com/) 5.32
* <del>[ActiveTcl](http://www.activestate.com/activetcl/downloads) 8.6.6</del> (currently disabled)
* [LuaBinaries](http://luabinaries.sourceforge.net/download.html) 5.4
* [Python](https://www.python.org/downloads/) 2.7
* [Python 3](https://www.python.org/downloads/) 3.8 or later
* [Racket](https://download.racket-lang.org/) 8.7 (BC)
* [RubyInstaller](http://rubyinstaller.org/downloads/) 3.3

Make sure that you install the same architecture (32bit/64bit) for those
libraries that matches your Vim installation.

For Python 3, Vim is compiled against Python 3.12 using [Stable
ABI](https://docs.python.org/3.12/c-api/stable.html), and this allows you to
use Python 3.8 or any later version. See also
[`:help python3-stable-abi`](https://vimhelp.org/if_pyth.txt.html#python3-stable-abi)

Additionally the binaries include the new terminal feature for Vim and
therefore contain the winpty.dll (32bit or 64bit) and the winpty-agent.exe from
the [winpty repository](https://github.com/rprichard/winpty). This feature is
currently considered experimental. Read the help at [:h
terminal.txt](http://vimhelp.appspot.com/terminal.txt.html) for more
information.

For supporting better encryption, it comes with the libsodium.dll from the
[libsodium repository](https://github.com/jedisct1/libsodium/releases/1.0.19-RELEASE)
See the help at [:h 'cryptmethod'](https://vimhelp.org/options.txt.html#%27cryptmethod%27)
for more details.

Note: The zip archive might be considered unsecure in Windows, causing Windows
to display a dialog box "These files might be harmful to your computer...". If
you want to disable this warning, you need to "unblock" the zip file. Do that
in the properties dialog of the zip file, first tab General and look for the
security section and click on "Unblock". However using a signed release might
prevent that behaviour in Windows eventually (see also next paragraph).

See: [Vim Repository](https://github.com/vim/vim) for the Vim source.

## Custom Patches
Note: If you want to test some patches, place them in the patch directory with
the extension `.patch`. They will be applied before building Vim and the binary
will then be tested against the test suite.

## Signed Builds
Creating a signed binary and installer still requires manual effort, therefore
not every release will be signed. They will be provided on a best effort basis
occasionaly. If there haven't been any signed
releases for a long time, feel free to request a new one by creating an
[issue](https://github.com/vim/vim-win32-installer/issues) here.

Thanks to
[SignPath.io](https://signpath.io?utm_source=foundation&utm_medium=github&utm_campaign=vim)
for providing a free code signing service and to the [SignPath
Foundation](https://signpath.org?utm_source=foundation&utm_medium=github&utm_campaign=vim)
for a free code signing certificate to sign the builds.

## Winget 
The nightly builds will be automatically uploaded and submitted to the [winget
repository](https://github.com/microsoft/winget-pkgs/). So you can use the
[winget](https://docs.microsoft.com/en-us/windows/package-manager/winget/)
command line tool to update your vim installation and do not have to download
and install new releases manually.

This is only done for the unsigned builds, because the signed builds currently
still require some manual steps to complete.

There will be 2 different types of Releases submitted to the winget Repository:

### 1) `vim.vim.nightly` Releases
Every build will be uploaded to the winget package repository as
`vim.vim.nightly` (nightly) build. You need to search for `vim.vim.nightly`.

### 2) `vim.vim` (stable) Releases
In addition, approximately every 100 releases, a new stable release will be
uploaded to the winget repository using the 'vim.vim' identifier. This should
happen approximately every month.


# License & Copyright

Most work was done by Ken Takata (@k-takata) and Christian Brabandt (@chrisbra).

The Vim license applies (see [:h
license](http://vimhelp.appspot.com/uganda.txt.html#license)) to all the build
scripts in this repository. Note, that Vim is included as a submodule and comes
with its own license (although is also released under the Vim license).
