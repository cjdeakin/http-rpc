#!/bin/bash
set -e -o pipefail

declare -r OUTPUT=http-rpc

cd "$(dirname "$(realpath "$0")")"

declare -r TMP="$(mktemp)"

trap "rm \"${TMP}\"" ERR

cat init.sh > "${TMP}"

IFS=$'\n'
for f in $(find src -type f) ; do
	(source "$f")
	echo "### BEGIN ${f} ###" >> "${TMP}"
	cat "${f}" >> "${TMP}"
	echo "### END ${f} ###" >> "${TMP}"
done

cat main.sh >> "${TMP}"

chmod +x "${TMP}"
./test.sh "${TMP}"

mv "${TMP}" "${OUTPUT}"
