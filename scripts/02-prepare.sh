#!/bin/bash
#

set -e
source "$(dirname "$0")/00-common.sh"

_do pushd "$BUILD_DIR"

trap '
_do rm -rf "${BUILD_DIR}"
_do rm -rf _x_configures
' EXIT

##
# prepare env
STABLE_ACCEPT_KEYWORD=""
declare -a ACCEPT_KEYWORDS_A
read -r -a ACCEPT_KEYWORDS_A < <(_do portageq envvar ACCEPT_KEYWORDS)
for ACCEPT_KEYWORD in "${ACCEPT_KEYWORDS_A[@]}"; do
	if [[ $ACCEPT_KEYWORD =~ ^~ ]]; then
		TESTING_ACCEPT_KEYWORDS="${ACCEPT_KEYWORD}"
	fi
	STABLE_ACCEPT_KEYWORD="${ACCEPT_KEYWORD#'~'}"
done
if [[ -n $TESTING_ACCEPT_KEYWORDS ]]; then
	append_portage_env "ACCEPT_KEYWORDS=\"-* $STABLE_ACCEPT_KEYWORD\"" \
		make.conf 0999-sphinx-doc-env.conf
fi
append_portage_env "MAKEOPTS=\"-j${NPROC}\"" \
	make.conf 0999-sphinx-doc-env.conf
append_portage_env "L10N=\"en zh\"" \
	make.conf 0999-sphinx-doc-env.conf

##
# prepare the base packages that should be removed
_do mkdir -p /etc/portage/profile
_do cp "${ROOT_DIR}/_x_configures/base-packages" /etc/portage/profile/packages

##
# prepare binpkgs releated
if [[ $USE_BINPKG == 1 ]]; then
	if [[ $BINPKGS_SIGNATURE == 1 ]]; then
		append_portage_env "FEATURES=\"\${FEATURES} binpkg-request-signature\"" \
			make.conf 0999-sphinx-doc-env.conf
		_do rm -rf /etc/portage/gnupg
		_do getuto
	fi
	_do sed -Ei '/sync-uri = /s@https?://[^/]+/@https://distfiles.gentoo.org/@' \
		/etc/portage/binrepos.conf/*.conf
fi

##
# prepare zsh
_do cp "${ROOT_DIR}/_x_configures/dot-zshrc" ~/.zshrc

_do popd
