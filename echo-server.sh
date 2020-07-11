#!/bin/bash
#
# For testing, use netcat to echo http requests
# The port to connect to will be output to stdout, followed by pids to kill when done
set -e -E -u
export IFS=$'\n'

which nc > /dev/null || {
	echo "Netcat is not installed, exiting..."
	exit 1
}

# Find an open port
declare -a -i ports=($(awk 'FNR > 1 {split($4, arr, ":"); if(arr[2] >= 10000)print arr[2]}' <(ss -tnl) <(ss -tn) | sort -u))
declare -i port=10000 i=0
if [[ ${#ports[@]} > 0 ]] ; then
	for((; port < 20000; port++)); do
		while((ports[i] < port)); do
			i+=1
		done

		((ports[i] != port)) && break
	done
fi

tmpdir="$(mktemp -d)"
trap 'rm -r "${tmpdir}"' EXIT

in="${tmpdir}/in"
out="${tmpdir}/out"

mkfifo "${in}" "${out}"

cat <(printf '%s\n' "HTTP/1.1 200") "${out}" | cat > "${in}" &
declare -a pid=($!)
disown

echo "${port}"
nc -l -p "${port}" > "${out}" < "${in}" &
pid+=($!)
disown

printf '%s\n' "${pid[@]}"

