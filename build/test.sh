#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="${DIR}/.."

cd "${BASE}"

# Build the documentation and run htmlproofer
rm -rf "${BASE}/_site/"
bundle exec jekyll build
bundle exec rake
