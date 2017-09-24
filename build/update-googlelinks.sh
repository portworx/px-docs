#!/bin/bash
# This is the cron script required to update the Google known link cache
# this script should be ran on interval and the CACHEPATH should be accessible at
# https://portworx.com/.doclink-cache.json for use with `test-google.sh` 

APIKEY="xxx"
CX='014138606599756990118%3Axxlvk9kidsa'
DOMAIN='docs.portworx.com'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="${DIR}/../html"

CACHEPATH="${BASE}/.doclink-cache.json"
HTTPDOMAIN="http://${DOMAIN}"
HTTPSDOMAIN="https://${DOMAIN}"
INDEX=1
PAGE=1
RUN=true

echo '{}' | /usr/bin/jq ".links=[]" | /usr/bin/jq ".runTime=$(date +%s)" > ${CACHEPATH}

while ${RUN}; do
    echo "Fetching Google results for page ${PAGE}"
    JSON=$(/usr/bin/curl -s "https://www.googleapis.com/customsearch/v1?key=${APIKEY}&cx=${CX}&q=site:${DOMAIN}&num=10&start=${INDEX}")

    if [[ $(echo $JSON | /usr/bin/jq .queries.nextPage) == "null" ]]; then
        RUN=false
    else
        PAGE=$(expr $PAGE + 1)
        INDEX=$(expr $INDEX + 10)

        for URL in $(echo $JSON | /usr/bin/jq -r .items[].link); do
            # Strip the domain from the URL
            URL=${URL#$HTTPDOMAIN}
            URL=${URL#$HTTPSDOMAIN}

            # Prepend index.html if there's a trailing slash
            if [[ "${URL}" == */ ]]; then
                URL="${URL}index.html"
            fi

            cat ${CACHEPATH} | /usr/bin/jq --arg URL "${URL}" '.links+=[$URL]' > "${CACHEPATH}.2"
            mv -f "${CACHEPATH}.2" "${CACHEPATH}"
        done

        # Let's not spam Google
        sleep 2
    fi
done
