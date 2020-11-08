#!/usr/bin/env bash

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "${_DIR}/data" \
  && rm -rf *;
cd - ;

echo "Local data was cleaned up!"
