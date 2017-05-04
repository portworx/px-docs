#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="${DIR}/.."

if [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "gh-pages" ]; then
    cd ${BASE}
    rm -rf "${BASE}/_site"

    mv ${BASE}/_layouts/amp.html ${BASE}/_layouts/page.html

    sed -i'' 's/docs.portworx.com/amp-docs.portworx.com/' ${BASE}/_config.yml

    bundle exec jekyll build

    cd "${BASE}/_site"

    echo "amp-docs.portworx.com" > CNAME

    git init

    git config --global user.email "no-reply@portworx.com"
    git config --global user.name "Build Slave"

    git add .
    git commit -am 'AMP generated site'

    echo -n ${RSAKEY} | base64 -d > ${BASE}/deploy_key
    echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
    chmod 0600 ${BASE}/deploy_key

    eval `ssh-agent -s`
    ssh-add ${BASE}/deploy_key

    git push git@github.com:portworx/px-docs-amp.git master --force

fi
