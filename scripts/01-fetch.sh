#!/bin/bash
#

set -e
source "$(dirname "$0")/00-common.sh"

_do mkdir -p "$BUILD_DIR"
_do pushd "$BUILD_DIR"

TMP_GIT_VER=2.44.0

fetch() {
	local url="$2" file="$1" ret=1 tries=3
	while (( ret != 0 && tries > 0 )); do
		set +e
		_do wget --tries=5 --timeout=20 -O "$file" "$url"
		ret=$?
		set -e
		tries=$((tries - 1))
	done
	return $ret
}

##
fetch gpg.conf https://gist.github.com/bekcpear/ea30609b36c416b5c0900b73b1525d80/raw/69fb89178ed5f92473301a9cb304aa0cbd1ae14b/gpg.conf
fetch git-${TMP_GIT_VER}.tar.gz https://github.com/git/git/archive/refs/tags/v${TMP_GIT_VER}.tar.gz
fetch 1E100000FA95E6B5.pub https://github.com/bekcpear.gpg
_do cp "${ROOT_DIR}/_x_configures/checksum.txt" ./checksum.txt
_do sha256sum -c ./checksum.txt || \
	{ echo "Error: sha256sum does not match!" >&2; exit 1; }

##
# prepare git
_do tar -xf git-${TMP_GIT_VER}.tar.gz
_do pushd git-${TMP_GIT_VER}
_do make prefix="${BUILD_DIR}/_git" -j$NPROC
_do make prefix="${BUILD_DIR}/_git" install
_do popd
_GIT="$(realpath _git/bin/git)"

##
# prepare gpg
_do mkdir -m 700 -p ~/.gnupg
_do cp gpg.conf ~/.gnupg/gpg.conf
_do gpg-connect-agent 'RELOADAGENT' '/bye'
_do gpg --version
_do gpg-agent --version

##
# prepare pub keys
_do gpg --keyserver hkps://keys.gentoo.org \
	--recv-keys EF9538C9E8E64311A52CDEDFA13D0EF1914E7A72
_do gpg --import ./1E100000FA95E6B5.pub

shallow_clone() {
	local -i ret=1 tries=5
	while (( ret != 0 && tries > 0 )); do
		if (( tries < 5 )); then
			_do sleep 10
			_do rm -rf "$2"
		fi
		set +e
		_do "$_GIT" clone --depth 1 "$1" "$2"
		ret=$?
		set -e
		tries=$((tries - 1))
	done
	return $ret
}

##
# prepare repos
get_repos() {
	local name="$1" url="$2"
	_do cp "${ROOT_DIR}/_x_configures/${name}.conf" /etc/portage/repos.conf/
	shallow_clone "$url" "/var/db/repos/${name}"
	_do pushd "/var/db/repos/${name}"
	REPO_HEAD_COMMIT="$(_do "$_GIT" rev-list -n1 HEAD)"
	if ! _do "$_GIT" verify-commit --raw "$REPO_HEAD_COMMIT"; then
		_do "$_GIT" --no-pager log -1 --pretty=fuller "$REPO_HEAD_COMMIT" >&2
		echo "Error: verify ::${name} repo failed!" >&2
		exit 1
	fi
	_do popd
}
_do mkdir -p /etc/portage/repos.conf
get_repos gentoo "https://github.com/gentoo-mirror/gentoo"
get_repos ryans "https://github.com/bekcpear/ryans-repos"

_do popd
