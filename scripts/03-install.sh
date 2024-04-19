#!/bin/bash
#

set -e
source "$(dirname "$0")/00-common.sh"

trap '
_do rm -rf /tmp/*
_do rm -rf /var/log/emerge*
_do rm -rf /var/tmp/portage/*
_do rm -rf /var/cache/distfiles/*
_do rm -rf /var/cache/binpkgs/*
#_do rm -rf /var/db/repos/gentoo
#_do rm -rf /var/db/repos/ryans
' EXIT

##
# binpkg?
BINPKG_OPTS=""
if [[ $USE_BINPKG == 1 ]]; then
	BINPKG_OPTS+=" --getbinpkg"
fi

##
# configure USE flags
append_portage_env "dev-python/sphinx latex" \
	package.use sphinx
append_portage_env "app-text/texlive cjk extra luatex png truetype xetex xml" \
	package.use texlive

##
# configure keyword for ::ryans repo
append_portage_env "dev-python/jieba::ryans" \
	package.accept_keywords jieba

##
# install packages
_do mkdir -p /run/lock
_do emerge -ntvj -l$NLOAD $BINPKG_OPTS \
	--autounmask=y \
	--autounmask-use=y \
	--autounmask-license=y \
	--autounmask-write=y \
	--autounmask-continue=y \
	--autounmask-keep-keywords=y \
	--autounmask-keep-mask=y \
	app-shells/zsh::gentoo \
	app-text/texlive::gentoo \
	dev-python/jieba::ryans \
	dev-python/sphinx::gentoo \
	dev-python/furo::gentoo

##
# clean bdeps
#_do emerge -c --with-bdeps=n
