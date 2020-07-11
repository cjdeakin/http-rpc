source "${SRCDIR}/src/utils/log.sh"
source "${SRCDIR}/src/utils/prompt.sh"
source "${SRCDIR}/src/utils/validate_true_false.sh"
source "${SRCDIR}/src/utils/rm.sh"

args=()
while [[ ${#args[@]} < 4 ]] ; do
	if rm_file_or_folder "${args[@]}" 2> "${stderr}" ; then
		exit 1
	fi

	[[ $(cat "${stderr}" | wc -l) == 1 ]]
	grep "^ERROR: At least 4 parameters are required" "${stderr}" > /dev/null

	args+=("")
done

declare -i i
for((i = 0; i < 2; i++)); do
	case "$i" in
		0)
			arg="${TMPDIR}/rm"
			name="base path"
			;;
		1)
			arg="file"
			name="file prompt"
			;;
	esac

	if rm_file_or_folder "${args[@]}" 2> "${stderr}" ; then
		exit 1
	fi

	[[ $(cat "${stderr}" | wc -l) == 1 ]]
	grep "^ERROR: ${name} is a required parameter" "${stderr}" > /dev/null

	args[i]="${arg}"
done

mkdir "${TMPDIR}/rm"
echo "Y" | rm_file_or_folder "${args[@]}" 2> "${stderr}"
[[ ! -e "${TMPDIR}/rm" ]]

touch "${TMPDIR}/rm"
if echo "n" | rm_file_or_folder "${args[@]}" 2> "${stderr}" ; then
	exit 1
fi

[[ -f "${TMPDIR}/rm" ]]
rm "${TMPDIR}/rm"
