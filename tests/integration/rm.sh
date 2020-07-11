source "${SRCDIR}/src/template.sh"

mkdir -p services/testservice/requests/dir{1,2} variables bodies
touch services/testservice/{service,requests/{request,dir1/a,dir2/b}}
touch variables/v{1,2,3}
touch bodies/b{1,2}

declare -a files=($(find -mindepth 1))
printf 'y\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\n' | run rm -t body -v v1 -v v3 -b b1 -b b2 -t variables testservice dir1 request dir2/b

declare -a removed=("variables/v1" "variables/v3" "bodies/b2" "templates/variables" services/testservice/requests/{request,dir1{,/a},dir2/b})
declare -a notremoved=($(find -mindepth 1))

declare -i i
for f in "${files[@]}" ; do
	was_removed=0
	for((i = 0; i < ${#removed[@]} && ${was_removed} == 0; i++)); do
		[[ "$f" == "./${removed[i]}" ]] && was_removed=1
	done

	was_not_removed=0
	for((i = 0; i < ${#notremoved[@]} && ${was_not_removed} == 0; i++)); do
		[[ "$f" == "${notremoved[i]}" ]] && was_not_removed=1
	done

	[[ "${was_removed}" != "${was_not_removed}" ]]
	[[ ("${was_removed}" == 1 && ! -e "$f") || ("${was_not_removed}" == 1 && -e "$f") ]]
done