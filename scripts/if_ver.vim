" Print all interface versions and write the result into if_ver.txt.

redir! > if_ver.txt
echo "*** Interface versions ***"

echo "\nLua:"
if has('lua')
  lua print(vim.lua_version, jit and "("..jit.version..")" or "")
else
  echo "not available"
endif

echo "\nMzScheme:"
if has('mzscheme')
  mzscheme (display (version))
else
  echo "not available"
endif

echo "\nPerl:"
if has('perl')
  perl print $^V
else
  echo "not available"
endif

echo "\nPython 2:"
if has('python')
  python import sys; print sys.version
else
  echo "not available"
endif

echo "\nPython 3:"
if has('python3')
  python3 import sys; print(sys.version)
else
  echo "not available"
endif

echo "\nRuby:"
if has('ruby')
  ruby print RUBY_VERSION
else
  echo "not available"
endif

echo "\nTcl:"
if has('tcl')
  tcl puts [info patchlevel]
else
  echo "not available"
endif

echo "\n$VIMRUNTIME:"
echo $VIMRUNTIME

echo "\n"
redir END
