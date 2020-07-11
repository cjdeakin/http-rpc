command_config() {
	edit_config
}

command_config_help() {
	log "config: edit configuration"
}

command_config_help_verbose() {
	log2 <<- EOF
			usage: config
			Edit configuration
		EOF
}

COMMANDS["config"]=command_config

command_init() {
	init
}

command_init_help() {
	log "init: initialize http-rpc"
}

command_init_help_verbose() {
	log2 <<- EOF
			usage: init
			Perform first time initializtion of http-rpc
		EOF
}

COMMANDS["init"]=command_init
