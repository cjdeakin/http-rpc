#!/bin/bash
set -E -e -o pipefail

[[ -v "DEBUG" ]] && set -x

[[ -v "HTTP_RPC_BASEDIR" ]] || declare -r HTTP_RPC_BASEDIR="${XDG_CONFIG_HOME:-${HOME}/.config}/http-rpc"
declare -r HTTP_RPC_VERSION="0.1.1"

declare -r EDITOR="${EDITOR:-vim}"

declare -A COMMANDS=()

declare -a COMMAND_LINE=() # Stores the command line
declare -a COMMAND=() # Stores the command to be run, with arguments
declare -A OPTIONS=() # Stores options
declare -a PARAMS=() # Stores extra parameters, after --
declare -a VARIABLES=() # Stores variables to load

declare -A BEAUTIFIERS=() # Stores beautifiers by mimetype

declare -a HEADERS=() # Stores request headers

declare -a TMPFILES=() # Stores tmpfiles to delete on exit
declare -a TMPDIRS=() # Stores tmpdirs to delete on exit

if [[ ! -v "HTTP_RPC_VARS_ONLY" ]] ; then
	while [[ $# > 0 ]] ; do
		COMMAND_LINE+=("$1")
		shift
	done

	if [[ -e "${HTTP_RPC_BASEDIR}" && ! -d "${HTTP_RPC_BASEDIR}" ]] ; then
		>&2 echo "ERROR: ${HTTP_RPC_BASEDIR} is not a directory."
		exit 1
	elif [[ ! -e "${HTTP_RPC_BASEDIR}" ]] ; then
		mkdir -p "${HTTP_RPC_BASEDIR}"
	fi

	cd "${HTTP_RPC_BASEDIR}"
fi

declare -r COMMAND_LINE
