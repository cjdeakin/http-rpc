export EDITOR=cat

source "${SRCDIR}/src/template.sh"

for template in "${TEMPLATES[@]}" ; do
	run edit -t "${template}"
	diff "${stdout}" "templates/${template}"
done

validate() {
	run edit $1 "$2"
	template_generate "$3" "${TMPDIR}/template"
	diff "${stdout}" "${TMPDIR}/template"
	diff "${stdout}" "${HTTP_RPC_BASEDIR}/$4"
}

validate -v "dir/test" variables "variables/dir/test"
validate -b "dir/test" body "bodies/dir/test"
validate "" "dir/test" service "services/dir/test/service"
validate test "dir/test" request "services/test/requests/dir/test"


