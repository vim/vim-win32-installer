#!/bin/bash

if [ $# -eq 0 ]; then
  echo "No URL argument supplied";
  exit 2;
fi

# Get latest version from winget package repository
# then filter through jq to get the latest released version
# and return a numeric release number (by stripping the '.')
curl -L \
  -s \
  -o - \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "$1" |
jq -c 'map(select(.name | contains("nightly")|not))' | 
jq -r '.|last |.name'
