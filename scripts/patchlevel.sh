#!/bin/sh

PATCHLEVEL_STR=`echo $PATCHLEVEL | sed "s/^0*\\([^0].*\\)/\\1/"`
sed -i "s/# *define VIM_VERSION_PATCHLEVEL[^_].*/#define VIM_VERSION_PATCHLEVEL ${PATCHLEVEL_STR}\n/" ./version.h
sed -i "s/#define VIM_VERSION_PATCHLEVEL_STR.*/#define VIM_VERSION_PATCHLEVEL_STR \"$PATCHLEVEL\"\n/" ./version.h
