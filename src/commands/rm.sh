command_rm() {
	local print_usage=true
	local error_usage=false

	if [[ ${#VARIABLES[@]} > 0 ]] ; then
		print_usage=false
		rm_variables "${VARIABLES[@]}" || error_usage=true
	fi

	local body="${OPTIONS[${OPTION_BODY}]}"
	if [[ -n "${body}" ]] ; then
		print_usage=false
		rm_bodies "${body}" || error_usage=true
	fi

	local template="${OPTIONS[${OPTION_TEMPLATE}]}"
	if [[ -n "${template}" ]] ; then
		print_usage=false
		rm_templates "${template}" || error_usage=true
	fi

	local service="${COMMAND[1]}"
	if [[ ${#COMMAND[@]} == 2 ]] ; then
		print_usage=false
		rm_services "${service}" || error_usage=true
	elif [[ ${#COMMAND[@]} > 2 ]] ; then
		print_usage=false
		rm_requests "${service}" "${COMMAND[@]:2}" || error_usage=true
	fi

	if ${print_usage} ; then
		error "Nothing to delete" || command_rm_help_verbose
		return 1
	elif ${error_usage} ; then
		command_rm_help_verbose
		return 1
	fi
}

command_rm_help() {
	log "rm: delete anything"
}

command_rm_help_verbose() {
	log2 <<- EOF
			usage: rm (--${OPTION_BODY} | --${OPTION_TEMPLATE} | --${OPTION_VARIABLES} | service | service (request | folder) [requests|folder...])
			Delete a body, request, service, or variables group

			If --${OPTION_FORCE} is passed, confirmation prompt will not be used

			If --${OPTION_VARIABLES} is passed, delete all variables passed
			If --${OPTION_BODY} is passed, deleted the specified body
			If --${OPTION_TEMPLATE} is passed, delete the specified template
			If service is passed, delete the service and all requests.
			If service and request is passed, delete all specified requests. Request can be a folder, in which case request will be recursively deleted.
		EOF
}

COMMANDS["rm"]=command_rm
