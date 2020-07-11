#!/bin/bash
set -e -o pipefail

[[ -v "DEBUG" ]] && set -x

cd "$(dirname "$(realpath "$0")")"

export HTTP_RPC_VARS_ONLY=1
source "http-rpc"

declare -r OUTPUT="http-rpc-completion.sh"
declare -r TMP="$(mktemp)"

trap "rm \"${TMP}\"" ERR

declare -r -a OPTIONS_LONG_ALL=("${OPTIONS_LONG[@]}" "${OPTIONS_LONG_ARGS[@]}")

declare -A OPTIONS_SHORT_REVERSE=()
for key in "${!OPTIONS_SHORT[@]}" ; do
	OPTIONS_SHORT_REVERSE["${OPTIONS_SHORT[${key}]}"]="${key}"
done

declare -r OPTIONS_SHORT_REVERSE

exec {stdout}>&1
exec 1> "${TMP}"

# Log a message to stderr and quit
error() {
	printf "\033[0;31mERROR:\033[0;0m $@\n" >&2
	exit 1
}

# Print function definitions or error
print_functions() {
	while [[ $# > 0 ]] ; do
		declare -f "$1" || error "No such function $1"
		shift
	done
}

start_reply() {
	pwd
	printf '%s\n' "$@" '--'
}

cat << EOF
__http_rpc_complete() {
	local CWORD_ARG_ONLY=false
	local -a COMMAND_LINE=()
	local -i i
	for((i = 1; i < COMP_CWORD; i++)); do
		if [[ "\${COMP_WORDS[\$i]}" == "--" ]] ; then
			CWORD_ARG_ONLY=true
		fi
		
		COMMAND_LINE+=("\${COMP_WORDS[\$i]}")
	done
	
	local -r COMMAND_LINE CWORD_ARG_ONLY
	local -r -a TEMPLATES=(${TEMPLATES[@]})

	local -r current="\$2"
	local -r previous="\$3"
	
	local -r config_home="\${XDG_CONFIG_HOME:-\${HOME}/.config}"
	local -r basedir="\${HTTP_RPC_BASEDIR:-\${config_home}/http-rpc}"
	
	local IFS=\$'\n'
	local -r -a reply=(\$(
		set -e
$(print_functions start_reply | sed -e 's/^ \{4\}/\t/g' -e 's/^/\t\t/')

		cd "\${basedir}"
		case "\${previous}" in
EOF

complete_arg_body() {
	cd bodies
	start_reply "mark_dirs"
	compgen -f -- "${current}"
}

complete_arg_host() {
	start_reply
	compgen -A hostname -- "${current}"
}

complete_arg_template() {
	start_reply
	compgen -W '"${TEMPLATES[@]}"' -- "${current}"
}

complete_arg_variables() {
	cd variables
	start_reply "mark_dirs"
	compgen -f -- "${current}"
}

for option in "${OPTIONS_LONG_ARGS[@]}" ; do
	pattern="--${option}"
	[[ -n "${OPTIONS_SHORT_REVERSE[${option}]}" ]] && pattern+="|-${OPTIONS_SHORT_REVERSE[${option}]}"
	
	echo -e "\t\t\t${pattern})"
	
	print_functions complete_arg_${option} | awk 'FNR > 3 {print last} {last = $0}' | sed -e 's/^ \{4\}/\t/g' -e 's/^/\t\t\t/'
	echo -e "\t\t\t\texit \$?"
	
	echo -e "\t\t\t\t;;"
done

cat << EOF
		esac
		
		if ! \${CWORD_ARG_ONLY} && [[ "\${current}" =~ ^- ]] ; then
			declare -a ALL_OPTIONS=( -- $(printf -- '--%s ' ${OPTIONS_LONG[@]} ${OPTIONS_LONG_ARGS[@]}))
			
			start_reply
			compgen -W '"\${ALL_OPTIONS[@]}"' -- "\${current}"
			exit \$?
		fi

		$(declare -p COMMANDS)
		declare -a COMMAND=()
		declare -A OPTIONS=()
		declare -a VARIABLES=()
		error() { return 0; }
		print_help() { return 0; }
		source <(base64 -d <<< "$(gzip -9 -c src/utils/options.sh | base64 -w0)" | gzip -d)
		parse_options || true
		
		if [[ \${#COMMAND[@]} == 0 ]] ; then
			start_reply
			compgen -W '"\${!COMMANDS[@]}"' -- "\${current}"
			exit \$?
		fi

EOF

complete_service() {
	cd services
	
	local -i i
	local nospace=
	local -a services=($(compgen -f "${current}"))
	for((i = 0; i < ${#services[@]}; i++)); do
		if [[ ! -f "${services[$i]}/service" ]] ; then
			services[$i]="${services[$i]}/"
			nospace="nospace"
		fi
	done
	
	start_reply ${nospace}
	printf '%s\n' "${services[@]}"
}

complete_request() {
	cd "services/$1/requests"
	start_reply "mark_dirs"
	compgen -f "${current}"
}

complete_service_or_request() {
	[[ -n "$1" ]] && ((${#COMMAND[@]} - 2 >= $1)) && exit 0
	[[ "${#COMMAND[@]}" == 1 ]] && complete_service || complete_request "${COMMAND[1]}"
}

print_functions complete_service complete_request complete_service_or_request | sed -e 's/^ \{4\}/\t/g' -e 's/^/\t\t/'

complete_command_config() {
	start_reply
}

complete_command_init() {
	start_reply
}

complete_command_edit() {
	complete_service_or_request 1
}

complete_command_rm() {
	complete_service_or_request
}

complete_command_send() {
	complete_service_or_request 1
}

echo -e "\n\t\tcase \"\${COMMAND[0]}\" in"

for command in "${!COMMANDS[@]}" ; do
	echo -e "\t\t\t${command})"
	print_functions complete_command_${command} | awk 'FNR > 3 {print last} {last = $0}' | sed -e 's/^ \{4\}/\t/g' -e 's/^/\t\t\t/'
	echo -e "\t\t\t\texit \$?"
	echo -e "\t\t\t\t;;"
done

cat << EOF
		esac

		exit 1
	))
	
	local -i i index=-1
	for((i = 1; i < \${#reply[@]}; i++)); do
		case "\${reply[\$i]}" in
			--)
				index=\$i
				break
				;;
			nospace)
				compopt -o nospace
				;;
		esac
	done
	
	((index < 1)) && return 1
	
	COMPREPLY=()
	pushd -- "\${reply[0]}" > /dev/null
	
	local -i i o
	for((i = \${index} + 1; i < \${#reply[@]}; i++)); do
		local val="\${reply[\$i]}"
		for((o = 1; o < \${index}; o++)); do
			case "\${reply[\$o]}" in
				mark_dirs)
					if [[ -d "\${val}" ]] ; then
						val+="/"
						compopt -o nospace
					fi
					;;
			esac
		done
		
		COMPREPLY+=("\$(printf '%q' "\${val}")")
	done
	
	popd > /dev/null
}

complete -F "__http_rpc_complete" "http-rpc"
EOF

exec 1>&-
exec 1>&${stdout}-

(source "${TMP}")

./test-completion.sh "${TMP}"

mv "${TMP}" "${OUTPUT}"
echo "Generated ${OUTPUT} successfully."
