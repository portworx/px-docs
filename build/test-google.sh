#!/bin/bash

APIKEY='AIzaSyBw1k291he4wdm3fagkAT6TQ-sTH4Jy2u8'
CX='014138606599756990118%3Axxlvk9kidsa'
DOMAIN='docs.portworx.com'

HTTPDOMAIN="http://${DOMAIN}"
HTTPSDOMAIN="https://${DOMAIN}"
RUN=true
INDEX=1
PAGE=1
TESTLINKS=()

while ${RUN}; do
    echo "Fetching Google results for page ${PAGE}"
    JSON=$(curl -s "https://www.googleapis.com/customsearch/v1?key=${APIKEY}&cx=${CX}&q=site:${DOMAIN}&num=10&start=${INDEX}")
ECHO $JSON
    if [[ $(echo $JSON | jq .queries.nextPage) == "null" ]]; then
        RUN=false
    else
        PAGE=$(expr $PAGE + 1)
        INDEX=$(expr $INDEX + 10)

        for URL in $(echo $JSON | jq -r .items[].link); do
            # Strip the domain from the URL
            URL=${URL#$HTTPDOMAIN}
            URL=${URL#$HTTPSDOMAIN}

            # Prepend index.html if there's a trailing slash
            if [[ "${URL}" == */ ]]; then
                URL="${URL}index.html"
            fi

            TESTLINKS+=("${URL}")
        done

        # Let's not spam Google
        sleep 2
    fi
done

FAIL=0
for ADDRESS in "${TESTLINKS[@]}"; do
    if [ ! -f "../_site${ADDRESS}" ]; then
        echo ${ADDRESS} FILE DOES NOT EXIST
        FAIL=1
    fi
done

if [[ ${FAIL} -eq 1 ]]; then
    exit 1
fi
