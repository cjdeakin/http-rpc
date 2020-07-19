# List of all template files
TEMPLATES=( body request service variables )

# Check that something is a valid template
#
# $1: name to check
#
# Returns 0 if valid, 1 otherwise
is_template() {
	local t
	for t in "${TEMPLATES[@]}" ; do
		if [[ "$t" == "$1" ]] ; then
			return 0
		fi
	done

	return 1
}

# Create a file from a template
#
# $1: The template to use
# $2: The file to create
template_generate() {
	if ! is_template "$1" ; then
		error "$1 is not a valid template"
		return 1
	fi

	if [[ -z "$2" ]] ; then
		error "output file is a required parameter"
		return 1
	fi

	local dir=$(dirname "$2")
	mkdir -p "${dir}"

	local template="templates/$1"
	if [[ ! -e "${template}" ]] ; then
		echo > "$2"
		return 0
	fi

	template_output "${template}" "$2"
}

# Run the template engine against a file
#
# $1: The file to input
# $2: The file to output
template_output() {
	[[ ! -f "$1" ]] && error "$1 does not exist"

	(
		ex=($(envsubst -v "$(< "$1" )" | sort -u))
		[[ ${#ex[@]} > 0 ]] && export ${ex[@]}

		export DOLLAR='$'
		envsubst < "$1" > "$2"
	)
}

# Delete templates
#
# $@: templates to delete
rm_templates() {
	rm_file_or_folder "templates" "template" "" "$@"
}

# Edit a template file
#
# $1: File to edit
edit_template() {
	if [[ -z "$1" ]] ; then
		error "A template must be specified" || command_edit_help_verbose
		return 1
	fi

	is_template "$1" || error "$1 is not a valid template"

	create_$1_template
	edit "templates/$1"
}

# Create all templates, if they do not exist
create_templates() {
	for template in "${TEMPLATES[@]}" ; do
		create_${template}_template
	done
}

# Create the body template, if it does not exist
create_body_template() {
	if [[ -e "templates/body" ]] ; then
		return 0
	fi

	mkdir -p "templates"

	cat <<- EOF > "templates/body"
			Sample request body, use \${DOLLAR}{var} for variable substitution.
		EOF
}

# Create the request template, if it does not exist
create_request_template() {
	if [[ -e "templates/request" ]] ; then
		return 0
	fi

	mkdir -p "templates"

	cat <<- EOF > "templates/request"
			# Useful commands:
			# error: print an error and stop
			# load_variables: load variables files
			# log: print all arguments to stderr
			# log2: prints stdin to stderr, for use with <<- EOF notation
			# generate_body: Run template engine against a body, file is stored in TMPFILES[-1]
			# prompt: ask user for input and read a single line from stdin, e.g. input="\$(prompt "Enter a value.")"
			# prompt_selection: ask user to select something from a list of options, e.g. selection="\$(prompt_selection "Choose an option!" "First option" "2")"
			# send: send a different request, results will be located in TMPDIRS[-1] as files body, headers, raw_body, and response_code
			# tmpdir: create a temporary directory that will be deleted on program exit, new dir is stored in TMPDIRS[-1]
			# tmpfile: create a temporary file that will be deleted on program exit, new dir is stored in TMPFILES[-1]
			#
			# Useful variables:
			# options: array of options passed to curl, always empty at this point
			# OPTIONS: associative array of options long form, e.g. OPTIONS[--body] will get the body file passed in on the command line
			# request: name of the request
			# service: name of the service
			#

			REQUEST_PATH="/" # Path of the url this request should go to
			REQUEST_METHOD="GET" # HTTP method of the request
			REQUEST_BODY="body" # Optional body to send as part of the request, --body overrides this.
			generate_body # Run template engine against the selected body.
			REQUEST_BODY_FORCE="\${DOLLAR}{TMPFILES[-1]}" # Optional body to send as part of the request, overrides --body and REQUEST_BODY.
			HEADERS+=("header: value") # Array of headers to send

			# Load some variables
			load_variables "RequestVars1" "Vars2"
		EOF
}

# Create the service template, if it does not exist
create_service_template() {
	if [[ -e "templates/service" ]] ; then
		return 0
	fi

	mkdir -p "templates"

	cat <<- EOF > "templates/service"
			# Useful commands:
			# error: print an error and stop
			# load_variables: load variables files
			# log: print all arguments to stderr
			# log2: prints stdin to stderr, for use with <<- EOF notation
			# generate_body: Run template engine against a body, file is stored in TMPFILES[-1]
			# prompt: ask user for input and read a single line from stdin, e.g. input="\$(prompt "Enter a value.")"
			# prompt_selection: ask user to select something from a list of options, e.g. selection="\$(prompt_selection "Choose an option!" "First option" "2")"
			# send: send a different request, results will be located in TMPDIRS[-1] as files body, headers, raw_body, and response_code
			# tmpdir: create a temporary directory that will be deleted on program exit, new dir is stored in TMPDIRS[-1]
			# tmpfile: create a temporary file that will be deleted on program exit, new dir is stored in TMPFILES[-1]
			#
			# Useful variables:
			# options: array of options passed to curl, always empty at this point
			# OPTIONS: associative array of options long form, e.g. OPTIONS[--body] will get the body file passed in on the command line
			# request: name of the request
			# service: name of the service
			#

			SERVICE_HOST="http://localhost:8080" # Base part of the url to send requests to, --host overrides this

			# Load some variables
			load_variables "ServiceVars1"
		EOF
}

# Create the variables template, if it does not exist
create_variables_template() {
	if [[ -e "templates/variables" ]] ; then
		return 0
	fi

	mkdir -p "templates"

	cat <<- EOF > "templates/variables"
			# Sample variables
			Var1="Value" # Set Var1 to Value
			Var2="\${DOLLAR}{Var1}!" # Set Var2 to Value!
		EOF
}
