#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="${DIR}/.."

cd "${BASE}"
rm -rf "${BASE}/_site"


# Build the AMP version of the documentation
mv "${BASE}/_layouts/page.html" "${BASE}/_layouts/page.bak.html"
cp "${BASE}/_layouts/amp.html" "${BASE}/_layouts/page.html"
sed -i'' 's/docs.portworx.com/amp-docs.portworx.com/' "${BASE}/_config.yml"
bundle exec jekyll build

# Kramdown table cell aligning uses 'text-align:' inline, inline styles are
# not valid AMP. Replace these with a text-center (bootstrap) class.
HTMLFILES=$(find "${BASE}/_site" -name '*.html')
for FILE in ${HTMLFILES}; do
    gsed -i 's%<td style="text-align: center">%<td class="text-center">%g' ${FILE}
    gsed -i 's%<th style="text-align: center">%<th class="text-center">%g' ${FILE}

    gsed -i 's%<td style="text-align: left">%<td class="text-left">%g' ${FILE}
    gsed -i 's%<th style="text-align: left">%<th class="text-left">%g' ${FILE}

    gsed -i 's%<td style="text-align: right">%<td class="text-right">%g' ${FILE}
    gsed -i 's%<th style="text-align: right">%<th class="text-right">%g' ${FILE}
done


# TODO: Install AMP validator
# Ensure every page is passes AMP validation
HTMLFILES=$(find _site -name '*.html')
for FILE in ${HTMLFILES}; do
    ISREDIRECT=$(grep 'Click here if you are not redirected.' ${FILE} > /dev/null; echo $?)

    if [[ ${ISREDIRECT} -eq 1 ]]; then
        amphtml-validator ${FILE}
        if [[ $? -ne 0 ]]; then
            FAILEDTEST=1
        fi
    else
        echo "${FILE} is a redirect - not testing AMP validity"
    fi
done
if [[ ${FAILEDTEST} -eq 1 ]]; then
    echo "Some HTML pages failed the AMP validation test"
    exit 1
else
    echo "AMP Validation fully passed"
fi


# Cleanup
mv "${BASE}/_layouts/page.bak.html" "${BASE}/_layouts/page.html"
