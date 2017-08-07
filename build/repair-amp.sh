#!/bin/bash
# Tools to repair HTML for AMP validity

# Kramdown table cell aligning uses 'text-align:' inline, inline styles are
# not valid AMP. Replace these with a text-center (bootstrap) class.
HTMLFILES=$(find _site -name '*.html')
for FILE in ${HTMLFILES}; do
    gsed -i 's%<td style="text-align: center">%<td class="text-center">%g' ${FILE}
    gsed -i 's%<th style="text-align: center">%<th class="text-center">%g' ${FILE}

    gsed -i 's%<td style="text-align: left">%<td class="text-left">%g' ${FILE}
    gsed -i 's%<th style="text-align: left">%<th class="text-left">%g' ${FILE}

    gsed -i 's%<td style="text-align: right">%<td class="text-right">%g' ${FILE}
    gsed -i 's%<th style="text-align: right">%<th class="text-right">%g' ${FILE}
done


