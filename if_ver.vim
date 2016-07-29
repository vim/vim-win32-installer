" Print all interface versions and write the result into if_ver.txt.

redir! > if_ver.txt
echo "*** Interface versions ***"
echo "\nLua:"
lua print(_VERSION)
" echo "\nLuaJIT:"
" lua print(jit.version)
echo "\nMzScheme:"
mzscheme (display (version))
echo "\nPerl:"
perl print $^V
echo "\nPython 2:"
python import sys; print sys.version
echo "\nPython 3:"
python3 import sys; print(sys.version)
echo "\nRuby:"
ruby print RUBY_VERSION
echo "\nTcl:"
tcl puts [info patchlevel]
echo "\n"
echo "\n $VIMRUNTIME"
echo $VIMRUNTIME
echo "\n"
redir END
