# Load all variables on the command line
load_all_variables() {
	if((${#VARIABLES[@]} > 0)); then
		load_variables "${VARIABLES[@]}"
	fi
}

# Load variables files
#
# $@: Files to load
load_variables() {
	local -a variables=()
	while [[ $# > 0 ]] ; do
		local v="variables/$1"
		if [[ ! -f "$v" ]] ; then
			error "Variables file $1 does not exist"
			return 1
		fi

		variables+=("$v")
		shift
	done

	source "${variables[@]}"
}

# Edit a variables file
#
# $1: File to edit
edit_variables() {
	if [[ -z "$1" ]] ; then
		error "A variables file must be specified" || command_edit_help_verbose
		return 1
	fi

	local path="variables/$1"
	if [[ ! -e "${path}" ]] ; then
		template_generate "variables" "${path}"
	fi

	edit "${path}"
}

# Remove variables
#
# $@: Variables to remove
rm_variables() {
	rm_file_or_folder "variables" "variables" "" "$@"
}
