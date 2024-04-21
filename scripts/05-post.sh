#!/bin/bash
#

set -e
source "$(dirname "$0")/00-common.sh"

trap '
#TODO
#_do rm -rf /tmp/*
_do rm -rf _x_scripts
' EXIT

##
# prepare fonts
# TODO: move to 04-sphinx-env
_do mv /tmp/tmp.*/fandol /usr/share/fonts/
_do fc-cache

##
# TODO: prepare Google noto fonts
# move to 04-sphinx-env
# Serif: https://github.com/notofonts/noto-cjk/releases/download/Serif2.002/09_NotoSerifCJKsc.zip
# Sans: https://github.com/notofonts/noto-cjk/releases/download/Sans2.004/08_NotoSansCJKsc.zip
# Monospace: https://github.com/notofonts/noto-cjk/releases/download/Sans2.004/13_NotoSansMonoCJKsc.zip

# set /bin/zsh as default shell
_do usermod -s /bin/zsh root
