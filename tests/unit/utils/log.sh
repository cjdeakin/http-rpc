source "${SRCDIR}/src/utils/log.sh"

log -e 2> "${stderr}"
[[ "-e" == "$(< "${stderr}")" ]]


log2 <<< "-n" 2> "${stderr}"
[[ "-n" == "$(< "${stderr}")" ]]


if error 2> "${stderr}" ; then
	exit 1
fi

[[ "ERROR: " == "$(< "${stderr}")" ]]
