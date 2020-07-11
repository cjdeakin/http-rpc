# Load a service file
#
# $1: service to laod
load_service() {
	source "services/$1/service"
}

# Delete services
#
# $@: services to delete
rm_services() {
	rm_file_or_folder "services" "service" " and all requests" "$@"
}

# Edit a service
#
# $1: File to edit
edit_service() {
	if [[ -z "$1" ]] ; then
		error "A service must be specified"
	fi

	local path="services/$1/service"
	if [[ ! -e "${path}" ]] ; then
		template_generate "service" "${path}"
	fi

	edit "${path}"
}
