#!/bin/sh
#set -x

# Work directory of this repository.
if [ "$1" != "" ]; then
	workdir=$1
else
	workdir=.
fi

cd $workdir
if [ ! -f appveyor.yml ]; then
	echo "Wrong directory."
	exit 1
fi

# older git does not know about --no-edit for git-pull
# e.g. 1.7.9.5
# git pull --no-edit
git pull

if [ ! -d vim/src ]; then
	git submodule init
fi
git submodule update
# get the last released tag name from this repo
vimoldver=$(curl -s https://api.github.com/repos/vim/vim-win32-installer/releases/latest  | python -c 'import sys; from json import loads as l; print(l(sys.stdin.read())["tag_name"])')

# Get the latest vim source code
cd vim
#vimoldver=$(git rev-parse HEAD)
git checkout master
git pull
vimver=$(git describe --tags --abbrev=0)
# pretty print the shortlog:
# - drop 'patch '
# - escape special characters
# - add link to the commit
commiturl=https://github.com/vim/vim/commit/
vimlog_md=$(git log --pretty='format:%H %s' $vimoldver..HEAD | sed \
    -e 's/[][_*^<`\\]/\\&/g' \
    -e "s#^\([0-9a-f]*\) patch \([0-9.a-z]*\)#* [\2]($commiturl\1)#" \
    -e "s#^\([0-9a-f]*\) \(.*\)#* [\2]($commiturl\1)#")
vimlog_plain=$(git log --pretty='format:* %s' $vimoldver..HEAD | sed \
    -e 's/^\* patch /* /g')
cd -

# Check if it is updated
if git diff --exit-code > /dev/null; then
	echo "No changes found."
	exit 0
fi

# Commit the change and push it
# replace newline by \n
echo "$vimlog_md" | sed -e ':a;N;$!ba;s/\n/\\n/g' > gitlog.txt
git commit -a -m "vim: Import $vimver" -m "$vimlog_plain"
git tag $vimver
git push origin master --tags
