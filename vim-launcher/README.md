# Vim launcher

This is a very small program to launch Vim.

This retrieves the path of (g)vim.exe from the registry settings for GvimExt:
  - `HKEY_CURRENT_USER\Software\Vim\Gvim`
  - `HKEY_LOCAL_MACHINE\SOFTWARE\Vim\Gvim`

The one-click installer will automatically install this by selecting the "Vim
launchers" option.

If you download a zip package, you can install this manually by copying the
launcher executable files to any directory that is in the PATH environment
variable and setting the registry properly.


## Aliases

If Vim launcher is copied (or hard-linked) with a different name, it can work
as an alias.

* gvim.exe
  - evim.exe or egvim.exe -- Easy mode (gvim -y)
  - gview.exe -- Read-only mode (gvim -R)
  - gvimdiff.exe -- Diff mode (gvim -d)
* vim.exe
  - view.exe -- Read-only mode (vim -R)
  - vimdiff.exe -- Diff mode (vim -d)

The one-click installer automatically creates these hard links.


## Example registry settings

Normally, you don't need to update the registry settings manually. The
one-click installer sets them automatically.
However, if you want to change them manually, see the following examples:

* `example_current_user.reg`
* `example_all_users.reg` (requires admin privileges)


## Build

If you have download the source code, run the following command:

```
nmake -f Make_mvc.mak
```

This will build `gvim.exe` and `vim.exe`.


## Icon

This low-resolution icon file is copied from Vim v9.1.1818 to reduce the file
size.
