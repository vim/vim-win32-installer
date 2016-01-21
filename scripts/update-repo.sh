#!/bin/sh

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

if [ ! -d vim/src ]; then
	git submodule update --init
fi

# Get the latest vim source code
cd vim
git checkout master
git pull
vimver=$(git describe --tags --abbrev=0)
cd -

# Check if it is updated
if git diff --exit-code > /dev/null; then
	echo "No changes found."
	exit 0
fi

# Commit the change and push it
git commit -a -m "vim: Import $vimver"
git tag $vimver
git push origin master --tags
