# Vim launcher

This is a very small program to launch Vim.

This retrieves the path of (g)vim.exe from the registry for GvimExt:
    - `HKEY_CURRENT_USER\Software\Vim\Gvim`
    - `HKEY_LOCAL_MACHINE\Software\Vim\Gvim`


## Build

```
nmake -f Make_mvc.mak
```

This will build `gvim.exe` and `vim.exe`.


## Aliases

If Vim launcher is copied with a different name, it can work as an alias.

* gvim.exe
  - evim.exe or egvim.exe -- Easy mode (gvim -y)
  - gview.exe -- Read-only mode (gvim -R)
  - gvimdiff.exe -- Diff mode (gvim -d)
* vim.exe
  - view.exe -- Read-only mode (vim -R)
  - vimdiff.exe -- Diff mode (vim -d)


## Icon

The icon file is copied from Vim v9.1.1818 to reduce the file size.
