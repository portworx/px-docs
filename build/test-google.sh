#!/bin/bash
# This is the CI script part of the Google link checking
# the links need to exist at https://portworx.com/.doclink-cache.json
# Check the cron script at `update-googlelinks.sh`

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="${DIR}/.."
CACHEPATH="${BASE}/.doclink-cache.json"

HTTPDOMAIN="http://${DOMAIN}"
HTTPSDOMAIN="https://${DOMAIN}"

curl -o ${CACHEPATH} https://portworx.com/.doclink-cache.json

echo "Testing pages exist locally"
FAIL=0
for ADDRESS in $(cat "${CACHEPATH}" | jq -r .links[]); do
    if [ ! -f "${BASE}/_site${ADDRESS}" ]; then
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
