#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE='${DIR}/..'

cd ${BASE}
rm -rf "${BASE}/_site"
bundle exec jekyll build

cd "${BASE}/_site"

echo "amp-docs.portworx.com" > CNAME

git init
git add .
git commit -am 'AMP generated site'
git push git@github.com:portworx/px-docs-amp.git master --force
