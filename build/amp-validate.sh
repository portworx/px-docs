#!/bin/bash

# TODO: Install AMP validator

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
