#!/bin/bash

if [ $(uname -s) == 'Darwin' ]; then
    if [[ $(which gsed > /dev/null; echo $?) -ne 0 ]]; then
        echo -n "MacOS comes with a version of sed which is not GNU compliant. "
        echo -n "To test locally, you must install GNU coreutils, this can be "
        echo    "done with 'brew install coreutils'."
        exit 1
    fi
    SED='gsed'
else
    SED='sed'
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="${DIR}/.."

cd "${BASE}"
rm -rf "${BASE}/_site"


# Build the AMP version of the documentation
mv -f "${BASE}/_layouts/page.html" "${BASE}/_layouts/page.bak.html"
cp "${BASE}/_layouts/amp.html" "${BASE}/_layouts/page.html"
${SED} -i'.bak' 's/docs.portworx.com/amp-docs.portworx.com/' "${BASE}/_config.yml"
bundle exec jekyll build

# Cleanup
mv -f "${BASE}/_layouts/page.bak.html" "${BASE}/_layouts/page.html"
mv -f "${BASE}/_config.yml.bak" "${BASE}/_config.yml"


# Kramdown table cell aligning uses 'text-align:' inline, inline styles are
# not valid AMP. Replace these with a text-center (bootstrap) class.
HTMLFILES=$(find "${BASE}/_site" -name '*.html')
for FILE in ${HTMLFILES}; do
    ${SED} -i 's%<td style="text-align: center">%<td class="text-center">%g' ${FILE}
    ${SED} -i 's%<th style="text-align: center">%<th class="text-center">%g' ${FILE}

    ${SED} -i 's%<td style="text-align: left">%<td class="text-left">%g' ${FILE}
    ${SED} -i 's%<th style="text-align: left">%<th class="text-left">%g' ${FILE}

    ${SED} -i 's%<td style="text-align: right">%<td class="text-right">%g' ${FILE}
    ${SED} -i 's%<th style="text-align: right">%<th class="text-right">%g' ${FILE}
done

# Fetch the validator JS file
wget https://cdn.ampproject.org/v0/validator.js -O ${DIR}/validator.js


# Ensure every page is passes AMP validation
testAMP() {
    amphtml-validator --validator_js ${DIR}/validator.js $1
    exit $?
}
PIDS=""

HTMLFILES=$(find _site -name '*.html')
for FILE in ${HTMLFILES}; do
    ISREDIRECT=$(grep 'Click here if you are not redirected.' ${FILE} > /dev/null; echo $?)

    if [[ ${ISREDIRECT} -eq 1 ]]; then
        ( testAMP ${FILE} ) &
        PIDS+=" $!"
    else
        echo "${FILE} is a redirect - not testing AMP validity"
    fi
done

# Ensure everything exited with 0
FAIL=0
for p in $PIDS; do
    if ! wait $p; then
        FAIL=1
    fi
done

rm -rf ${DIR}/validator.js
if [[ ${FAIL} -eq 1 ]]; then
    echo "At least one page failed AMP validation"
    exit 1
fi
