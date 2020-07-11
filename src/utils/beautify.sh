# Beautify a file
#
# $1: file
# $2: mimetype
beautify() {
	local file="$1"
	local mimetype="$2"

	[[ -z "${file}" || ! -f "${file}" ]] && error "No file to beautify"

	$(get_beautifier "${mimetype}") "${file}"
}

# Get the beautifier for a mimetype
#
# $1: mimetype
get_beautifier() {
	[[ -z "$1" ]] && echo print && return 0

	echo "${BEAUTIFIERS["$1"]:-print}"
}

# Print a file to stdout.
# Missing final newline will be added.
#
# $1: file to print
print() {
	cat <<< "$(< "$1")"
}
