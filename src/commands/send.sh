 command_send() {
	local service="${COMMAND[1]}"
	local request="${COMMAND[2]}"

	if [[ -z "${service}" ]] ; then
		error "No service specified" || command_send_help_verbose
		return 1
	elif [[ -z "${request}" ]] ; then
		error "No request specified" || command_send_help_verbose
		return 1
	fi

	load_all_variables

	send "${service}" "${request}"
	local -r tmp="${TMPDIRS[-1]}"
	cat "${tmp}/body"
}

command_send_help() {
	log "send: send a request"
}

command_send_help_verbose() {
	log2 <<- EOF
			usage: send service request
			Send a request

			if --${OPTION_BODY} is passed, it will override the body set in the request file.
		EOF
}

COMMANDS["send"]=command_send
