declare -r TESTDIR="$(mktemp -d)"

trap 'rm -r -- "${TESTDIR}" || printf "Failed to remove %s\n" "${TESTDIR}"' EXIT

declare -x -r HTTP_RPC_BASEDIR="${TESTDIR}/basedir"
declare -x -r SRCDIR="$(realpath "$(dirname "$0")")"
declare -x -r TMPDIR="${TESTDIR}/tmp"

declare -r stdout="${TESTDIR}/stdout"
declare -r stderr="${TESTDIR}/stderr"

# Hook to run before test execution
pretest_hook() {
	return 0
}

# Run a test, should only be called from a subshell.
# Prefer run_tests method.
#
# $1: Test to run
run_test() {
	set -e -E

	error_handler() {
		cat "${stderr}" "${stdout}"

		local -i i=0
		local line subroutine file
		while read -r line subroutine file < <(caller $i) ; do
			i+=1
			printf '%s:%s @ %s()\n' "${file}" "${line}" "${subroutine}"
		done
	}

	trap 'error_handler' ERR

	cd "${HTTP_RPC_BASEDIR}"
	pretest_hook
	source "${SRCDIR}/$1"
}

# Run specified tests.
# If a directory is specified, all tests within will be run
#
# $@: tests to run
run_tests() {
	local file passed
	local -a files=("$@")
	local -i i failed=0 total=0
	for((i = 0; i < ${#files[@]}; i++)); do
		file="${files[i]}"
		if [[ -d "${file}" ]] ; then
			files+=("${file}"/*)
		elif [[ -f "${file}" ]] ; then
			total+=1

			[[ -e "${TMPDIR}" ]] && rm -r "${TMPDIR}"
			mkdir "${TMPDIR}"

			[[ -e "${HTTP_RPC_BASEDIR}" ]] && rm -r "${HTTP_RPC_BASEDIR}"
			mkdir "${HTTP_RPC_BASEDIR}"

			set +e +E
			(run_test "${file}")
			passed=$?
			set -e -E

			if [[ ${passed} == 0 ]] ; then
				echo "Test ${file} passed"
			else
				failed+=1
				echo "Test ${file} failed"
			fi
		fi
	done

	((failed > 0)) && echo "${failed} / ${total} tests failed." && exit 1

	echo "${total} tests completed successfully."
}
