# All options
declare -r OPTION_BODY="body"
declare -r OPTION_HELP="help"
declare -r OPTION_FORCE="force"
declare -r OPTION_HOST="host"
declare -r OPTION_INSECURE="insecure"
declare -r OPTION_TEMPLATE="template"
declare -r OPTION_VARIABLES="variables"
declare -r OPTION_VERSION="version"

# Array of long form options without arguments
declare -r OPTIONS_LONG=("${OPTION_FORCE}" "${OPTION_HELP}" "${OPTION_INSECURE}" "${OPTION_VERSION}")

# Array of long form options with arguments
declare -r OPTIONS_LONG_ARGS=("${OPTION_BODY}" "${OPTION_HOST}" "${OPTION_TEMPLATE}" "${OPTION_VARIABLES}")

# Map short option to long form
declare -r -A OPTIONS_SHORT=(
	["b"]="${OPTION_BODY}"
	["f"]="${OPTION_FORCE}"
	["h"]="${OPTION_HELP}"
	["H"]="${OPTION_HOST}"
	["k"]="${OPTION_INSECURE}"
	["t"]="${OPTION_TEMPLATE}"
	["v"]="${OPTION_VARIABLES}"
	["V"]="${OPTION_VERSION}"
)

# Map long option to description
declare -r -A OPTIONS_DESC=(
	["${OPTION_BODY}"]="set body file to use"
	["${OPTION_FORCE}"]="skip user validation"
	["${OPTION_HELP}"]="print this message, if a command is specified more information will be printed"
	["${OPTION_HOST}"]="set host to send request to"
	["${OPTION_INSECURE}"]="ignore TLS certificate problems"
	["${OPTION_TEMPLATE}"]="template to edit"
	["${OPTION_VARIABLES}"]="variables to use, can appear multiple times"
	["${OPTION_VERSION}"]="print version and exit"
)

# Check if an option exists
#
# $1: The option to check, long form
# $2: Only check no arg options, (true|false) only
#
# Returns 1 if it does not exist, 0 otherwise
option_exists() {
	local o
	for o in "${OPTIONS_LONG[@]}" ; do
		if [[ "$1" == "$o" ]] ; then
			return 0
		fi
	done

	if $2 ; then
		return 1
	fi

	for o in "${OPTIONS_LONG_ARGS[@]}" ; do
		if [[ "$1" == "$o" ]] ; then
			return 0
		fi
	done

	return 1
}

# Check if an option requires an argument
#
# $1: The option to check, long form
option_requires_arg() {
	local o
	for o in "${OPTIONS_LONG_ARGS[@]}" ; do
		if [[ "$1" == "$o" ]] ; then
			return 0
		fi
	done

	return 1
}

parse_command() {
	if [[ ${#COMMAND[@]} == 0 && -z "${COMMANDS[$1]}" ]] ; then
		error "No such option $1" || print_help
		return 1
	fi

	COMMAND+=("$1")
}

parse_options() {
	local option
	local -i max="${#COMMAND_LINE[@]}"
	local -i last=max-1
	local -i i
	for((i = 0; i < ${max}; i++)) ; do
		option="${COMMAND_LINE[i]}"
		case "${option}" in
			--)
				for((i+= 1; i < ${max}; i++)); do
					parse_command "${COMMAND_LINE[i]}"
				done
				;;
			-?)
				local long="${OPTIONS_SHORT[${option:1}]}"
				if [[ -z "${long}" ]] ; then
					error "No such option ${option}" || print_help
					return 1
				fi

				option="--${long}"
				;&
			--*)
				option="${option:2}"
				if option_requires_arg "${option}" ; then
					i+=1
					if (($i < $max)) ; then
						local arg="${COMMAND_LINE[$i]}"

						if [[ "${option}" == "${OPTION_VARIABLES}" ]] ; then
							VARIABLES+=("${arg}")
						else
							OPTIONS[${option}]="${arg}"
						fi
					else
						error "${COMMAND_LINE[$i - 1]} requires an argument"
					fi
				elif option_exists "${option}" true ; then
					# Set no arg option
					OPTIONS["${option}"]=true
				else
					error "No such option --${option}" || print_help
					return 1
				fi
				;;
			*)
				parse_command "${option}"
				;;
		esac
	done
}

print_options_help() {
	local option
	local -A map
	for option in "${!OPTIONS_SHORT[@]}" ; do
		map[${OPTIONS_SHORT[${option}]}]="${option}"
	done

	local short
	local help
	local IFS=$'\n'
	local all=( "${OPTIONS_LONG[@]}" "${OPTIONS_LONG_ARGS[@]}" )
	for option in $(printf '%s\0' "${all[@]}" | sort -z | xargs -0n1) ; do
		help=""
		short="${map[${option}]}"
		if [[ -n "${short}" ]] ; then
			help+="-${short}, "
		fi

		help+="--${option}: ${OPTIONS_DESC[${option}]}"
		log "${help}"
	done
}
