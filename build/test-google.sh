#!/bin/bash

APIKEY='AIzaSyBw1k291he4wdm3fagkAT6TQ-sTH4Jy2u8'
CX='014138606599756990118%3Axxlvk9kidsa'
DOMAIN='docs.portworx.com'

CACHEPATH='asdasd'
HTTPDOMAIN="http://${DOMAIN}"
HTTPSDOMAIN="https://${DOMAIN}"
INDEX=1
PAGE=1

if [ ! -f "${CACHEPATH}" ] ||
    [[ $(cat ${CACHEPATH} | jq -r .runTime) -lt $(expr $(date +%s) - 86400) ]]; then
    # Create new cache file
    echo '{}' | jq ".links=[]" | jq ".runTime=$(date +%s)" > ${CACHEPATH}
    RUN=true
else
    # A cache file was generated within the last 24 hours
    RUN=false
fi

while ${RUN}; do
    echo "Fetching Google results for page ${PAGE}"
    JSON=$(curl -s "https://www.googleapis.com/customsearch/v1?key=${APIKEY}&cx=${CX}&q=site:${DOMAIN}&num=10&start=${INDEX}")

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

            cat ${CACHEPATH} | jq --arg URL "${URL}" '.links+=[$URL]' > "${CACHEPATH}.2"
            mv -f "${CACHEPATH}.2" "${CACHEPATH}"
        done

        # Let's not spam Google
        sleep 2
    fi
done

echo "Testing pages exist locally"
FAIL=0
for ADDRESS in $(cat "${CACHEPATH}" | jq -r .links[]); do
    if [ ! -f "../_site${ADDRESS}" ]; then
        echo "ERROR: Google result ${ADDRESS} does not exist"
        FAIL=1
    fi
done

if [[ ${FAIL} -eq 1 ]]; then
    echo "Fail! One or more Google results do not exist"
    exit 1
else
    echo "Pass: Google link check successful"
fi
