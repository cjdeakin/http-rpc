#!/bin/bash

if [[ $# < 1 ]] ; then
	>&2 echo "usage: $0 [completion-script] [tests...]"
	exit 1
fi

cd "$(dirname "$0")"
source "test-util.sh"

touch "${stderr}" "${stdout}"

pretest_hook() {
	source <(sed -e 's/local -a COMMAND_LINE=()//' -e 's/local -r COMMAND_LINE CWORD_ARG_ONLY//' "${script}")

	compopt() {
		return 0
	}
}

declare -r script="$(realpath "$1")"

if [[ $# > 1 ]] ; then
	shift
	run_tests "$@"
else
	run_tests "completion-tests"
fi
