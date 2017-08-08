#!/bin/bash

if [ $(uname -s) == 'Darwin' ]; then
    SED='gsed'
else
    SED='sed'
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="${DIR}/.."

cd "${BASE}"
rm -rf "${BASE}/_site"


# Build the AMP version of the documentation
mv "${BASE}/_layouts/page.html" "${BASE}/_layouts/page.bak.html"
cp "${BASE}/_layouts/amp.html" "${BASE}/_layouts/page.html"
${SED} -i'.bak' 's/docs.portworx.com/amp-docs.portworx.com/' "${BASE}/_config.yml"
bundle exec jekyll build

# Cleanup
mv "${BASE}/_layouts/page.bak.html" "${BASE}/_layouts/page.html"
mv "${BASE}/_config.yml.bak" "${BASE}/_config.yml"


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



# TODO: Install AMP validator
# Ensure every page is passes AMP validation
testAMP() {
    amphtml-validator $1
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

if [[ ${FAIL} -eq 1 ]]; then
    echo "At least one page failed AMP validation"
    exit 1
fi
