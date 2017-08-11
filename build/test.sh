#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="${DIR}/.."

cd "${BASE}"

# Build the documentation and run htmlproofer
rm -rf "${BASE}/_site/"
bundle exec jekyll build


# Check for references to redirects by removing them
HTMLFILES=$(find "${BASE}/_site" -name '*.html')
for FILE in ${HTMLFILES}; do
    ISREDIRECT=$(grep 'Click here if you are not redirected.' ${FILE} > /dev/null; echo $?)

    if [[ ${ISREDIRECT} -eq 0 ]]; then
         rm -rf "${FILE}"
    fi
done

bundle exec rake
