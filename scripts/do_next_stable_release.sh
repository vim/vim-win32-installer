#!/bin/bash


# Checks the latest stable release for vim.vim at
# https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/v/vim/vim/
# and if the release number is smaller than the current Tag name + 100
# return true, else false

if [[ -z "$REF_NAME" ]]; then
  echo "not run in Github Actions CI, quitting"
  exit 2
fi

if [ $# -eq 0 ]; then
  URL="https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/v/vim/vim/"
else
  URL="$1"
fi

DIR="$(dirname $0)"

LAST_STABLE_RELEASE=$(${DIR}/get_last_windows_release.sh "$URL" | tr -d '.')
LAST_STABLE_RELEASE=$(( $LAST_STABLE_RELEASE + 100))

TAG_NAME=$(echo ${REF_NAME} |tr -d '.v')

if [[ ${TAG_NAME} -ge ${LAST_STABLE_RELEASE} ]]; then
  echo "true"
else
  echo "false"
fi
