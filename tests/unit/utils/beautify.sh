source "${SRCDIR}/src/utils/beautify.sh"

echo -n "No newline" > "${TMPDIR}/beautify"

declare -i len=$(cat "${TMPDIR}/beautify" | wc -c)
(( ${len}+1 == $(print "${TMPDIR}/beautify" | wc -c) ))


declare -A BEAUTIFIERS=([a]=cat)
[[ "$(get_beautifier a)" == "${BEAUTIFIERS[a]}" ]]
[[ "$(get_beautifier b)" == "print" ]]


(( ${len} == $(beautify "${TMPDIR}/beautify" a | wc -c) ))
(( ${len} + 1 == $(beautify "${TMPDIR}/beautify" b | wc -c) ))
