declare -a HEADERS=()

mkdir -p services/testservice/requests bodies
cat <<- EOF > services/testservice/service
		HEADERS+=("ServiceHeader: 1")
	EOF

cat <<- EOF > services/testservice/requests/testrequest
		REQUEST_PATH="/testrequest/path"
		REQUEST_METHOD="PUT"
		REQUEST_BODY="testbody"
		HEADERS+=("RequestHeader: 2")
	EOF

cat <<- EOF > bodies/testbody
		THIS IS A TEST BODY!
	EOF

declare -a server=($("${SRCDIR}/echo-server.sh"))

source <(
	cat <<- EOF
			on_exit() {
				kill ${server[@]:1} || true
				$(trap -p EXIT | sed -e 's/^trap -- '"'"'//' -e 's/'"'"' ERR$//')
			}
		EOF
)

trap 'on_exit' EXIT

run send testservice testrequest --host "http://localhost:${server[0]}"
diff bodies/testbody "${stdout}"
grep "< ServiceHeader: 1" "${stderr}" > /dev/null
grep "< RequestHeader: 2" "${stderr}" > /dev/null
