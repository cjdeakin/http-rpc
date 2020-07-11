# This is run on script exit
cleanup() {
	[[ ${#TMPFILES[@]} > 0 ]] && rm -- "${TMPFILES[@]}" || true
	[[ ${#TMPDIRS[@]} > 0 ]] && rm -r -- "${TMPDIRS[@]}" || true
}
