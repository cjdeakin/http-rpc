source "${SRCDIR}/src/utils/log.sh"
source "${SRCDIR}/src/utils/validate_true_false.sh"
source "${SRCDIR}/src/utils/prompt.sh"

if prompt_yesno 2> "${stderr}" > "${stdout}" ; then
	exit 1
fi

[[ $(cat "${stderr}" | wc -l) == 1 ]]
grep "^ERROR:  is not true or false" "${stderr}" > /dev/null

echo | prompt_yesno true 2> "${stderr}" > "${stdout}"

if echo | prompt_yesno false 2> "${stderr}" > "${stdout}" ; then
	exit 1
fi

