print_help() {
	log2 <<- EOF
			usage: $0 <command> <options>
			options:
		EOF

	print_options_help

	log2 <<- EOF

			commands:
		EOF

	local IFS=$'\n'
	for c in $(printf '%s\n' "${!COMMANDS[@]}" | sort) ; do
		${COMMANDS[$c]}_help
	done
	
	exit 0
}
