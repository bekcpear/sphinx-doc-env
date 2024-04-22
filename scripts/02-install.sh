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
_do rm -rf /var/db/repos/gentoo
_do rm -rf /var/db/repos/ryans
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
append_portage_env "app-text/texlive-core cjk xetex" \
	package.use texlive
append_portage_env "media-libs/harfbuzz icu" \
	package.use texlive

##
# configure keyword for ::ryans repo
append_portage_env "dev-python/jieba::ryans" \
	package.accept_keywords jieba

##
# use ~ keyword for texlive pkgs
# this list may change in the future
append_portage_env "app-text/texlive::gentoo
app-text/ttf2pk2::gentoo
dev-texlive/texlive-fontsrecommended::gentoo
dev-perl/Sort-Key::gentoo
dev-texlive/texlive-formatsextra::gentoo
dev-texlive/texlive-latexextra::gentoo
dev-texlive/texlive-plaingeneric::gentoo
dev-perl/Data-Compare::gentoo
dev-perl/XML-LibXML-Simple::gentoo
dev-perl/DateTime-Calendar-Julian::gentoo
dev-texlive/texlive-binextra::gentoo
dev-texlive/texlive-fontsextra::gentoo
dev-texlive/texlive-langcjk::gentoo
dev-perl/List-SomeUtils::gentoo
dev-perl/Business-ISBN::gentoo
dev-texlive/texlive-langchinese::gentoo
dev-tex/biber::gentoo
dev-tex/bibtexu::gentoo
dev-perl/List-AllUtils::gentoo
dev-tex/latex-beamer::gentoo
dev-perl/Lingua-Translit::gentoo
dev-perl/ExtUtils-LibBuilder::gentoo
dev-tex/biblatex::gentoo
dev-tex/minted::gentoo
dev-libs/kpathsea::gentoo
dev-tex/latexmk::gentoo
dev-perl/Data-Uniqid::gentoo
dev-texlive/texlive-fontutils::gentoo
dev-texlive/texlive-latex::gentoo
dev-perl/Encode-JIS2K::gentoo
dev-perl/Business-ISMN::gentoo
dev-perl/autovivification::gentoo
dev-perl/Text-BibTeX::gentoo
dev-texlive/texlive-basic::gentoo
dev-texlive/texlive-xetex::gentoo
dev-texlive/texlive-pictures::gentoo
app-text/dvisvgm::gentoo
dev-perl/List-SomeUtils-XS::gentoo
dev-perl/Business-ISBN-Data::gentoo
dev-tex/pgf::gentoo
dev-texlive/texlive-latexrecommended::gentoo
app-text/dvipsk::gentoo
dev-texlive/texlive-luatex::gentoo
app-text/ps2pkm::gentoo
dev-libs/ptexenc::gentoo
dev-perl/Text-Roman::gentoo
dev-perl/Business-ISSN::gentoo
dev-perl/List-UtilsBy::gentoo
dev-texlive/texlive-bibtexextra::gentoo
dev-perl/Tie-Cycle::gentoo
app-text/texlive-core::gentoo
dev-tex/glossaries::gentoo
dev-texlive/texlive-langenglish::gentoo
media-libs/harfbuzz::gentoo
" package.accept_keywords texlive

##
# install packages
_do mkdir -p /run/lock
_do emerge -ntvj -l$NLOAD $BINPKG_OPTS \
	--autounmask=y \
	--autounmask-use=y \
	--autounmask-license=y \
	--autounmask-write=y \
	--autounmask-continue=y \
	--autounmask-keep-keywords=n \
	--autounmask-keep-mask=y \
	app-shells/zsh::gentoo \
	app-text/texlive::gentoo \
	dev-python/jieba::ryans \
	dev-python/sphinx::gentoo \
	dev-python/furo::gentoo

##
# clean bdeps
_do emerge -c --with-bdeps=n