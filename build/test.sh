#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE="${DIR}/.."

cd "${BASE}"

containsElement () {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}

# Build the documentation and run htmlproofer
rm -rf "${BASE}/_site/"
bundle exec jekyll build

# Test Google Links all work
source "${BASE}/build/test-google.sh"

# Check for references to redirects by removing them
# Also check for duplicate H1 tags
H1TAGS=()
H1FAILS=()
H1FAIL=0

HTMLFILES=$(find "${BASE}/_site" -name '*.html')
for FILE in ${HTMLFILES}; do
    ISREDIRECT=$(grep 'Click here if you are not redirected.' ${FILE} > /dev/null; echo $?)
    if [[ ${ISREDIRECT} -eq 0 ]]; then
         rm -rf "${FILE}"
    else
        H1TAG=$(cat "${FILE}" | pup 'h1 text{}' | awk '{$1=$1};1' | tr -d '\n')
        if containsElement "${H1TAG}" "${H1TAGS[@]}"; then
            H1FAILS+=("${H1TAG}")
            H1FAIL=1
        else
            H1TAGS+=("${H1TAG}")
        fi
    fi
done

# If there was a H1 match, fail the test
if [[ ${H1FAIL} -eq 1 ]]; then
    echo -en '\033[0;31mFAIL '
    echo "The following H1s are used more than once"
    printf '%s\n' "${H1FAILS[@]}"
    exit 1
fi

bundle exec rake
