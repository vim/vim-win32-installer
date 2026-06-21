#!/bin/sh

set -e

if [ -z "$1" ]; then
  echo "usage: $0 <vimdir>"
  exit 1
fi

VIMSRC=$1

cd "$VIMSRC/lang"
rm -f LICENSE.*.nsis.txt

for i in LICENSE.*.txt ../LICENSE; do
  # Convert to UTF-8 with BOM, CRLF
  name=${i##*/}
  target=${name%%.txt}.nsis.txt
  echo "Creating ${target}"
  vim -es -c 'setl bomb ff=dos' -c "wq! ++enc=utf-8 $target" "$i"
done
