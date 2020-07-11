source "${SRCDIR}/src/utils/log.sh"
source "${SRCDIR}/src/template.sh"

for template in "${TEMPLATES[@]}" ; do
	is_template "${template}"
done

if is_template ; then
	exit 1
fi

if is_template a ; then
	exit 1
fi

if template_generate "bod" "${TMPDIR}/template" 2> "${stderr}" ; then
	exit 1
fi

if template_generate "body" "" 2> "${stderr}" ; then
	exit 1
fi

mkdir -p "templates"
cat <<- EOF > "templates/body"
		\${DOLLAR}
		\${Var1}
		\${Var2}
		\${TEMPLATES[@]}
	EOF

template_generate "body" "${TMPDIR}/template"
diff "${TMPDIR}/template" <(
		cat <<- EOF
				\$


				\${TEMPLATES[@]}
			EOF
	)

Var1="ONE"
Var2="two"

template_generate "body" "${TMPDIR}/template"
diff "${TMPDIR}/template" <(
		cat <<- EOF
				\$
				${Var1}
				${Var2}
				\${TEMPLATES[@]}
			EOF
	)

echo "body" > "templates/body"
template_generate "body" "${TMPDIR}/template"
diff "${TMPDIR}/template" <(echo "body")
