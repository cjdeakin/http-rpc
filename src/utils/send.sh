# Send a request.
# After execution, results are stored in TMPDIRS[-1]
#
# These files are available:
# body - contains beautified response body
# headers - contains response headers
# raw_body - contains raw response body
# response_code - contains numeric http response code
#
# $1: service
# $2: request
send() {
	if [[ $# != 2 ]] ; then
		error "2 parameters required, service and request"
		return 1
	elif [[ -z "$1" ]] ; then
		error "No service specified"
		return 1
	elif [[ -z "$2" ]] ; then
		error "No request specified"
		return 1
	fi

	local service="$1"
	local request="$2"

	local -a options=()
	load_service "${service}"
	load_request "${service}" "${request}"

	local url="${OPTIONS[${OPTION_HOST}]:-${SERVICE_HOST}}${REQUEST_PATH}"

	[[ -v "OPTIONS[${OPTION_INSECURE}]" ]] && options+=(-k)

	local body="$(get_body)"
	[[ -n "${body}" ]] && options+=("--data-binary" "@${body}")

	for header in "${HEADERS[@]}" ; do
		options+=("-H" "${header}")
	done

	tmpdir
	local -r tmp="${TMPDIRS[-1]}"

	curl -v -s -X "${REQUEST_METHOD}" "${url}" -o "${tmp}/raw_body" -D "${tmp}/headers" "${options[@]}" -w '%{http_code}\n' > "${tmp}/response_code"

	local mimetype="$(grep "Content-Type" "${tmp}/headers" | sed -e 's/Content-Type: //' | tr -c -d '[:alnum:][:punct:]')"
	beautify "${tmp}/raw_body" "${mimetype}" > "${tmp}/body"
}

