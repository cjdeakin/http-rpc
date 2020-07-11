# Prompt to delete files or folders
#
# $1: Base path
# $2: File prompt
# $3: Prompt postfix
# $@: Sub paths
rm_file_or_folder() {
	if [[ $# < 4 ]] ; then
		error "At least 4 parameters are required"
		return 1
	fi

	local base="$1"
	local filePrompt="$2"
	local postfix="$3"

	if [[ -z "${base}" ]] ; then
		error "base path is a required parameter"
		return 1
	elif [[ -z "${filePrompt}" ]] ; then
		error "file prompt is a required parameter"
		return 1
	fi

	shift 3

	local prompt=""
	local -a del=()

	if [[ -v "OPTIONS[${OPTION_FORCE}]" ]] ; then
		del=("$@")
	else
		while [[ $# > 0 ]] ; do
			local file="$1"
			shift

			local path="${base}/${file}"
			if [[ -d "${path}" ]] ; then
				prompt="folder"
			elif [[ -f "${path}" ]] ; then
				prompt="${filePrompt}"
			else
				error="${file} does not exist" || continue
			fi

			if prompt_yesno false "Delete ${prompt} ${file}${postfix}?" ; then
				del+=("${path}")
			fi
		done
	fi

	[[ ${#del[@]} > 0 ]] && rm --interactive=never -r -- "${del[@]}"
}
