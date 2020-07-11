if [[ ! -v "HTTP_RPC_VARS_ONLY" ]] ; then
	trap cleanup EXIT

	parse_options
	load_config

	if [[ -v OPTIONS["${OPTION_VERSION}"] ]] ; then
		echo "${HTTP_RPC_VERSION}"
		exit 0
	elif [[ "${#COMMAND[@]}" == 0 || -z "${COMMANDS[${COMMAND[0]}]}" ]] ; then
		print_help
	else
		if [[ -n "${OPTIONS[${OPTION_HELP}]}" ]] ; then
			${COMMANDS[${COMMAND[0]}]}_help_verbose
			exit 0
		fi

		${COMMANDS[${COMMAND[0]}]}
	fi
fi
