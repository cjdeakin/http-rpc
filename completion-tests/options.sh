source "${SRCDIR}/src/utils/options.sh"

__http_rpc_complete "test" "--"

declare -a allOptions=(-- $(printf -- '--%s\n' "${OPTIONS_LONG[@]}" "${OPTIONS_LONG_ARGS[@]}"))
[[ ${#allOptions[@]} == ${#COMPREPLY[@]} ]]
for((i = 0; i < ${#allOptions[@]}; i++)); do
	[[ "${allOptions[i]}" == "${COMPREPLY[i]}" ]]
done

for option in "${allOptions[@]}" ; do
	matched=false
	part="${option:0:3}"
	__http_rpc_complete "test" "${part}"
	for comp in "${COMPREPLY[@]}" ; do
		[[ "${comp}" == "${option}" ]] && matched=true
	done

	${matched} || exit 1
done

mkdir -p bodies services/testservice/requests variables
touch bodies/body services/testservice/requests/request variables/variables

for option in "${OPTIONS_LONG_ARGS[@]}" ; do
	case "${option}" in
		body)
			arg="bo"
			match="body"
			;;
		host)
			# Can't control /etc/hosts, so just assume it works
			continue
			;;
		template)
			arg="req"
			match="request"
			;;
		variables)
			arg="var"
			match="variables"
			;;
		*)
			>&2 echo "Untested option ${option}"
			exit 1
	esac

	__http_rpc_complete "test" "${arg}" "--${option}"
	[[ ${#COMPREPLY[@]} == 1  && "${COMPREPLY[0]}" == "${match}" ]]
done
