#!/bin/bash
#

set -e
source "$(dirname "$0")/00-common.sh"

_WD="$(mktemp -d)"
_do pushd "$_WD"

trap '
_do popd
_do rm -rf "$_WD"
_do rm -rf _x_configures_post
' EXIT

##
# fetch resources
fetch fandol.zip https://github.com/bekcpear/ctan-misc/releases/download/20240421/fandol-v0.3.zip
fetch 08_NotoSansCJKsc.zip https://github.com/notofonts/noto-cjk/releases/download/Sans2.004/08_NotoSansCJKsc.zip
fetch 09_NotoSerifCJKsc.zip https://github.com/notofonts/noto-cjk/releases/download/Serif2.002/09_NotoSerifCJKsc.zip
fetch 13_NotoSansMonoCJKsc.zip https://github.com/notofonts/noto-cjk/releases/download/Sans2.004/13_NotoSansMonoCJKsc.zip

_do cp "${ROOT_DIR}/_x_configures_post/checksum.txt" ./checksum.txt
_do sha256sum -c ./checksum.txt || \
	{ echo "Error: sha256sum does not match!" >&2; exit 1; }

##
# prepare fonts
_do unzip fandol.zip
_do cp -a fandol /usr/share/fonts/
for fdir in 08_NotoSansCJKsc 09_NotoSerifCJKsc 13_NotoSansMonoCJKsc; do
	_do mkdir -p "$fdir"
	_do pushd "$fdir"
	_do unzip ../"$fdir".zip
	_do popd
	_do cp -a "$fdir" /usr/share/fonts/
done
_do fc-cache
