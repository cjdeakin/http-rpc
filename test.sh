#!/bin/bash
set -E -e -o pipefail

if [[ $# < 1 ]] ; then
	>&2 echo "usage: $0 [http-rpc-script] [tests...]"
	exit 1
fi

cd "$(dirname "$0")"
source "test-util.sh"

pretest_hook() {
	run init
}

declare -r script="$(realpath "$1")"

run() {
	${script} "$@" > "${stdout}" 2> "${stderr}"
}

run
head -n 1 "${stderr}" | grep "^http-rpc has not been initialized" > /dev/null

run init
[[ $(cat "${stderr}" | wc -l) == 0 ]]
[[ $(cat "${stdout}" | wc -l) == 0 ]]
[[ -f "${HTTP_RPC_BASEDIR}/config" ]]

(
	source "src/template.sh"
	for template in "${TEMPLATES[@]}" ; do
		[[ -f "${HTTP_RPC_BASEDIR}/templates/${template}" ]]
	done
)

if [[ $# > 1 ]] ; then
	shift
	run_tests "$@"
else
	run_tests "tests"
fi
