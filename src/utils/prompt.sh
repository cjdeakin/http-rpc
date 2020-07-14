# Prompt user for yes or no input
#
# $1: default to yes, true or false
# $@: message to prompt with
prompt_yesno() {
	validate_true_false "$1" || return 1

	local default="$1"
	shift

	local prompt="$@"
	[[ -z "${prompt}" ]] && prompt="Are you sure?"

	${default} && prompt="${prompt} [Y/n] " || prompt="${prompt} [y/N] "

	local input
	while true ; do
		read -p "${prompt}" input >&2
		if [[ -z "${input}" ]] ; then
			${default}
			return $?
		fi

		case "${input}" in
			[yY]*)
				return 0
				;;
			[nN]*)
				return 1
				;;
			*)
				log "Invalid input, enter yes or no"
				;;
		esac
	done
}

# Prompt user to select an option.
# Selected option will be output to stdout.
#
# $1: prompt
# $@: options
prompt_selection() {
	local prompt="$1"
	shift

	local -i i
	local input
	local -a options=("$@" "cancel")
	while true ; do
		log "${prompt}"
		for((i = 1; i <= ${#options[@]}; i++)); do
			log "$i) ${options[i - 1]}"
		done

		read -p "#? " -r input >&2
		if [[ -z "${input}" || "${input}" -le "0" || "${input}" > "${#options[@]}" || -z "${options[input - 1]}" ]] ; then
			log "Invalid selection: ${input}"
			continue
		fi

		input="${options[input - 1]}"
		[[ "${input}" == "cancel" ]] && return 1
		printf '%s\n' "${input}"
		break
	done
}
