declare -a commands=($(export HTTP_RPC_VARS_ONLY=1; source "${SRCDIR}/http-rpc"; printf '%s\n' "${!COMMANDS[@]}"))

mkdir -p services/dir/service/requests/dir variables/dir bodies/dir
touch services/dir/service/{service,requests/dir/request} variables/dir/variables bodies/dir/bodies

unset COMMAND_LINE
__http_rpc_complete "test"

[[ ${#commands[@]} == ${#COMPREPLY[@]} ]]
for((i = 0; i < ${#commands[@]}; i++)); do
	[[ "${commands[i]}" == "${COMPREPLY[i]}" ]]
done

validate_service_completion() {
	declare -a COMMAND_LINE=("$1")
	__http_rpc_complete "test" "" "$1"
	[[ ${#COMPREPLY[@]} == 1 && "${COMPREPLY[0]}" == "dir/" ]]

	__http_rpc_complete "test" "dir/" "$1"
	[[ ${#COMPREPLY[@]} == 1 && "${COMPREPLY[0]}" == "dir/service" ]]

	COMMAND_LINE+=("dir/service")
	__http_rpc_complete "test" "" "dir/service"
	[[ ${#COMPREPLY[@]} == 1 && "${COMPREPLY[0]}" == "dir/" ]]

	__http_rpc_complete "test" "dir/" "dir/service"
	[[ ${#COMPREPLY[@]} == 1 && "${COMPREPLY[0]}" == "dir/request" ]]
}

test_noarg() {
	declare -a COMMAND_LINE=("$1")
	__http_rpc_complete "test" "" "$1"
	[[ ${#COMPREPLY[@]} == 0 ]]
}

test_edit() {
	validate_service_completion "$1"
}

test_rm() {
	validate_service_completion "$1"
}

test_send() {
	validate_service_completion "$1"
}

for command in "${commands[@]}" ; do
	unset COMMAND_LINE
	case "${command}" in
		config|init)
			test_noarg "${command}"
			;;
		edit)
			test_edit "${command}"
			;;
		rm)
			test_rm "${command}"
			;;
		send)
			test_send "${command}"
			;;
		*)
			>&2 echo "Untested command ${command}"
			exit 1
			;;
	esac
done

unset COMMAND_LINE
