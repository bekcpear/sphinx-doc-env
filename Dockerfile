FROM gentoo/stage3:latest

ARG USE_BINPKG
ARG PLATFORM

ENV USE_BINPKG=${USE_BINPKG:-true}
ENV PLATFORM=${PLATFORM:-unknown}

ADD configures/ _x_configures/
ADD scripts/00-common.sh _x_scripts/00-common.sh

ADD scripts/01-fetch.sh _x_scripts/01-fetch.sh
RUN _x_scripts/01-fetch.sh "$(pwd)"

ADD scripts/02-prepare.sh _x_scripts/02-prepare.sh
RUN _x_scripts/02-prepare.sh "$(pwd)"

ADD scripts/03-install.sh _x_scripts/03-install.sh
RUN _x_scripts/03-install.sh "$(pwd)"

ADD scripts/04-post.sh _x_scripts/04-post.sh
RUN _x_scripts/04-post.sh "$(pwd)"

ENV TERM="xterm-256color"
WORKDIR /root
CMD ["/bin/zsh", "-l"]
