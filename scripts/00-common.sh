#!/bin/bash
#

if [[ $PLATFORM == unknown ]]; then
	echo "unknown platform!" >&2
	exit 1
fi

ROOT_DIR="$(realpath "$(dirname "$0")/../")"
ROOT_DIR="${ROOT_DIR%/}"

NPROC="$(nproc)"
NLOAD=$(( NPROC - 1 ))
if (( NPROC < 2 )); then
	NLOAD=2
fi

USE_BINPKG="${USE_BINPKG:-0}"
if [[ ! $USE_BINPKG =~ ^0|[fF][aA][lL][sS][eE]$ ]]; then
	USE_BINPKG=1
fi

# force to check the signature
BINPKGS_SIGNATURE=1

exec {ANOTHER_STDERR}>&2
_do() {
	set -- "$@"
	echo -e "\x1b[1;32m>>>\x1b[0m" "$@" >&$ANOTHER_STDERR || true
	"$@"
}

append_portage_env() {
	local line="$1" file="/etc/portage/${2}" new_file_name="$3"
	if [[ ! -f "$file" ]]; then
		_do mkdir -p "$file"
		file="${file%/}/${new_file_name##*/}"
	fi
	if [[ "$line" =~ ^/ ]]; then
		if [[ -f "$line" ]]; then
			_do echo $'\n'"# ${line}" >>"$file"
			_do cat "${line}" >>"$file"
		else
			echo "Error: missing file '$line'." >&2
			return 1
		fi
	else
		_do echo "${line}" >>"$file"
	fi
}

fetch() {
	local url="$2" file="$1" ret=1 tries=3
	while (( ret != 0 && tries > 0 )); do
		set +e
		_do curl --retry 5 --connect-timeout 20 -o "$file" -Lf "$url"
		ret=$?
		set -e
		tries=$((tries - 1))
	done
	return $ret
}
