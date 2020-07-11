command_edit() {
	if [[ ${#VARIABLES[@]} > 0 ]] ; then
		edit_variables "${VARIABLES[${#VARIABLES[@]} - 1]}" || { command_edit_help_verbose; return 1; }
		return 0
	elif [[ -n "${OPTIONS[${OPTION_BODY}]}" ]] ; then
		edit_body "${OPTIONS[${OPTION_BODY}]}" || { command_edit_help_verbose; return 1; }
		return 0
	elif [[ -n "${OPTIONS[${OPTION_TEMPLATE}]}" ]] ; then
		edit_template "${OPTIONS[${OPTION_TEMPLATE}]}" || { command_edit_help_verbose; return 1; }
		return 0
	elif [[ ${#COMMAND[@]} == 2 ]] ; then
		edit_service "${COMMAND[1]}" || { command_edit_help_verbose; return 1; }
		return 0
	elif [[ ${#COMMAND[@]} > 2 ]] ; then
		edit_request "${COMMAND[1]}" "${COMMAND[2]}" || { command_edit_help_verbose; return 1; }
	else
		error "Nothing to edit" || command_edit_help_verbose
		return 1
	fi
}

command_edit_help() {
	log "edit: Create or edit a request, service, or variables group"
}

command_edit_help_verbose() {
	log2 <<- EOF
			usage: edit (--${OPTION_BODY} | --${OPTION_TEMPLATE} | --${OPTION_VARIABLES} | service | service request)
			Create or edit a body, request, service, or variables group

			If --${OPTION_VARIABLES} is passed, edit the last variables file passed
			If --${OPTION_BODY} is passed, edit the specified body
			If --${OPTION_TEMPLATE} is passed, edit the specified template
			Otherwise, edit the service or request that was passed
		EOF
}

COMMANDS["edit"]=command_edit
