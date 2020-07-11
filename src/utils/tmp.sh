# Create a temporary file.  It will be deleted on program exit.
# The absolute path of the file will be stored at TMPFILES[-1]
tmpfile() {
	local tmp="$(mktemp)"
	TMPFILES+=("${tmp}")
}

# Create a temporary directory.  It will be deleted on program exit.
# The absolute path of the directory will be stored at TMPDIRS[-1]
tmpdir() {
	local tmp="$(mktemp -d)"
	TMPDIRS+=("${tmp}")
}
