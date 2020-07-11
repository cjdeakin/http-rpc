# Log something
log() {
	>&2 printf '%s\n' "$@"
}

# Log something with <<- EOF syntax
log2() {
	>&2 cat
}

# Log something and throw error
error() {
	>&2 echo "ERROR: $@"
	return 1
}

# Log a not yet implemented error
not_yet_implemented() {
	error "${FUNCNAME[1]}: not yet implemented"
}
