source "${SRCDIR}/src/utils/tmp.sh"

declare -a TMPFILES=()
declare -a TMPDIRS=()

tmpfile
[[ ${#TMPFILES[@]} == 1  && -f "${TMPFILES[0]}" ]]
[[ ${#TMPDIRS[@]} == 0 ]]

tmpdir
[[ ${#TMPFILES[@]} == 1 ]]
[[ ${#TMPDIRS[@]} == 1 && -d "${TMPDIRS[0]}" ]]

rm -r -- "${TMPFILES[@]}" "${TMPDIRS[@]}"
