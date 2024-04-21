#!/bin/bash
#

set -e
source "$(dirname "$0")/00-common.sh"

_WORK_DIR="$(mktemp -d)"
_do pushd "$_WORK_DIR"

trap '
_do popd
#TODO:
#_do rm -rf "$_WORK_DIR"
' EXIT

# TODO
# move to 00-common
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

##
# fandol fonts
#TODO: switch to fetch fandol.zip https://github.com/bekcpear/ctan-misc/releases/download/20240421/fandol-v0.3.zip
fetch fandol.zip https://cit.ume.ink/cwittlut/ctan-misc/releases/download/20240421/fandol-v0.3.zip

##
# checksum
# TODO:
# write to a seperate file
echo "9278f01b417ded5766d98c3937192a1a6a2c73a5e94a3493fdfc932b2a55005a fandol.zip" >checksum.txt
_do sha256sum -c checksum.txt

##
# install fonts
_do unzip fandol.zip
