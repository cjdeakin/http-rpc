EDITOR="cat"

source "${SRCDIR}/src/utils/log.sh"
source "${SRCDIR}/src/utils/edit.sh"

edit 2> "${stderr}" && exit 1

[[ $(cat "${stderr}" | wc -l) == 1 ]]
grep "^ERROR: File is a required parameter" "${stderr}" > /dev/null


edit "${TMPDIR}" 2> "${stderr}" && exit 1

[[ $(cat "${stderr}" | wc -l) == 1 ]]
grep "^ERROR: Can not edit a directory" "${stderr}" > /dev/null


edit "${HTTP_RPC_BASEDIR}/config" > "${stdout}" 2> "${stderr}"
[[ $(cat "${stderr}" | wc -l) == 0 ]]
diff "${HTTP_RPC_BASEDIR}/config" "${stdout}"

EDITOR="touch"
edit "${TMPDIR}/editdir/edit" > "${stdout}" 2> "${stderr}"

[[ $(cat "${stdout}" | wc -l) == 0 ]]
[[ $(cat "${stderr}" | wc -l) == 0 ]]
[[ -f "${TMPDIR}/editdir/edit" ]]
