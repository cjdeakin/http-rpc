# Load a request
#
# $1: service
# $2: request
load_request() {
	if [[ -z "$1" ]] ; then
		error "service is a required parameter"
	elif [[ -z "$2" ]] ; then
		error "request is a required parameter"
	fi

	source "services/$1/requests/$2"
}

# Delete requests
#
# $1: service
# $@: requests
rm_requests() {
	local service="$1"
	shift

	rm_file_or_folder "services/${service}/requests" "request" " in service ${service}" "$@"
}

# Edit a request
#
# $1: Service the request is in
# $2: File to edit
edit_request() {
	if [[ -z "$1" ]] ; then
		error "A service must be specified"
	elif [[ -z "$2" ]] ; then
		error "A request must be specified"
	fi

	local path="services/$1/requests/$2"
	if [[ ! -e "${path}" ]] ; then
		template_generate "request" "${path}"
	fi

	edit "${path}"
}
