# Load configuration
load_config() {
	if [[ -f "config" ]] ; then
		source config
		return 0
	fi

	local pattern='^(init|config)$'
	[[ "${COMMAND[0]}" =~ ${pattern} ]] || log "http-rpc has not been initialized, run $0 init or $0 config"
}

# Edit configuration
edit_config() {
	init
	edit "config"
}

# Initialize configuration
init() {
	create_config
	create_templates
}

# Create intitial configuration
create_config() {
	if [[ -e "config" ]] ; then
		return 0
	fi

	cat <<- EOF > config
			# http-rpc configuration
			# Beautifiers, by mimetype
			BEAUTIFIERS[text/plain]=print # Print plaintext, always ending with a newline
			BEAUTIFIERS[text/html]=print
		EOF
}
