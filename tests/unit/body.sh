source "${SRCDIR}/src/utils/edit.sh"
source "${SRCDIR}/src/utils/log.sh"
source "${SRCDIR}/src/utils/rm.sh"
source "${SRCDIR}/src/utils/prompt.sh"
source "${SRCDIR}/src/utils/tmp.sh"
source "${SRCDIR}/src/utils/validate_true_false.sh"
source "${SRCDIR}/src/template.sh"
source "${SRCDIR}/src/body.sh"

cd "${HTTP_RPC_BASEDIR}"

export EDITOR="cat"

if edit_body 2> "${stderr}" ; then
	exit 1
fi

[[ $(wc -l < "${stderr}") == 1 ]]
grep "^ERROR: A body must be specified" "${stderr}" > /dev/null

edit_body "testbody" > "${stdout}" 2> "${stderr}"
[[ -f "bodies/testbody" ]]

declare -a TMPFILES=()
var="BLARGH"

generate_body "testbody"

[[ -f "${TMPFILES[-1]}" ]]
grep "BLARGH" "${TMPFILES[-1]}" > /dev/null
rm "${TMPFILES[-1]}"

[[ -z $(get_body) ]]

REQUEST_BODY="testbody"
[[ $(get_body) == "bodies/testbody" ]]

generate_body

[[ -f "${TMPFILES[-1]}" ]]
grep "BLARGH" "${TMPFILES[-1]}" > /dev/null
rm "${TMPFILES[-1]}"

OPTIONS["body"]="other"
[[ $(get_body) == "bodies/other" ]]

REQUEST_BODY_FORCE="/force"
[[ $(get_body) == "/force" ]]
