# Delete bodies
#
# $@: bodies to delete
rm_bodies() {
	rm_file_or_folder "bodies" "body" "" "$@"
}

# Edit a body file
#
# $1: File to edit
edit_body() {
	if [[ -z "$1" ]] ; then
		error "A body must be specified"
		return 1
	fi

	local path="bodies/$1"
	if [[ ! -e "${path}" ]] ; then
		template_generate "body" "${path}"
	fi

	edit "${path}"
}

# Run the template engine against a body and output the result to a temporary file.
# The name of the temporary file will be output on stdout.
#
# $1: body to run the template engine against
generate_body() {
	local body
	if [[ -n "$1" ]] ; then
		body="$1"
		[[ ! "${body}" =~ ^/ ]] && body="bodies/${body}"
	else
		body="$(get_body)"
	fi

	tmpfile
	local -r tmp="${TMPFILES[-1]}"

	template_output "${body}" "${tmp}"
}

# Get body to use, outputting to stdout
get_body() {
	local body="${REQUEST_BODY_FORCE:-${OPTIONS[${OPTION_BODY}]:-${REQUEST_BODY}}}"
	[[ -n "${body}" && ! "${body}" =~ ^/ ]] && body="bodies/${body}"
	printf '%s\n' "${body}"
}
