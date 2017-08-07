#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="${DIR}/.."

cd "${BASE}"

# Build the documentation and run htmlproofer
rm -rf "${BASE}/_site/"
bundle exec jekyll build
bundle exec rake


# EXIT ON FAIL?


# Check for references to redirects
HTMLFILES=$(find "${BASE}/_site" -name '*.html')
for FILE in ${HTMLFILES}; do
    ISREDIRECT=$(grep 'Click here if you are not redirected.' ${FILE} > /dev/null; echo $?)

    if [[ ${ISREDIRECT} -eq 0 ]]; then
echo ${FILE}
#        grep -ir "${FILE}" "${BASE}/_/site/"
    fi
done
