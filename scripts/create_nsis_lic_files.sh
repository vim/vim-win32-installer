#!/bin/bash

set -e

VIMSRC=$1

cd $VIMSRC/lang

rm -f LICENSE.*.nsis.txt

for i in LICENSE.*.txt ../LICENSE; do
  # Convert to UTF-8 with BOM
  target=$(basename $i .txt).nsis.txt
  echo "Creating ${target}"
  LC_ALL=C sed -e $'1s/^/\xef\xbb\xbf/' $i > ${target}
done
