# Validate that something is true or false
#
# $1: value to validate
validate_true_false() {
	case "$1" in
		true|false)
			return 0
			;;
		*)
			error "$1 is not true or false"
			return 1
			;;
	esac
}
