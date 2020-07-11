# Edit a file
#
# $1: File to edit
edit() {
	if [[ $# != 1 ]] ; then
		error "File is a required parameter"
		return 1
	elif [[ -d "$1" ]] ; then
		error "Can not edit a directory"
		return 1
	fi

	local dir="$(dirname "${1}")"

	[[ "${dir}" != "." ]] && mkdir -p "${dir}"
	${EDITOR} "${1}"
}
