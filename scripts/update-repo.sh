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

# Get the latest vim source code
cd vim
vimoldver=$(git rev-parse HEAD)
git checkout master
git pull
vimver=$(git describe --tags --abbrev=0)
#vimlog=$(git log --oneline $vimoldver..HEAD | sed -e 's/^\S\+ //')
# pretty print the shortlog:
# - squeeze spaces
# - drop 'patch '
# - drop 'Problem: '
# - format to 100 chars
vimlog=$(git log --decorate --graph --pretty=format:%s $vimoldver..HEAD |sed \
    -e 's/^\(. \)patch /\1/' \
    -e 's/ \+/ /g' \
    -e 's/\([0-9]\+ \)Problem: \+/\1/' \
    -e 's/\(.\{100\}\).*/\1/g')
cd -

# Check if it is updated
if git diff --exit-code > /dev/null; then
	echo "No changes found."
	exit 0
fi

# Commit the change and push it
# replace newline by \n
echo "$vimlog" | sed \
    -e 's#^\* *\([0-9]\.[0-9]\.[0-9]\+\) #* [\1](https://github.com/vim/vim/releases/tag/v\1) #g' | sed \
    -e ':a;N;$!ba;s/\n/\\n/g' > gitlog.txt
git commit -a -m "vim: Import $vimver" -m "$vimlog"
git tag $vimver
git push origin master --tags
