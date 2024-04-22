FROM gentoo/stage3:latest

ARG USE_BINPKG
ARG PLATFORM

ENV USE_BINPKG=${USE_BINPKG:-true}
ENV PLATFORM=${PLATFORM:-linux/amd64}

ADD configures_pre/ _x_configures_pre/
ADD scripts/00-common.sh _x_scripts/00-common.sh

ADD scripts/01-prepare.sh _x_scripts/01-prepare.sh
RUN _x_scripts/01-prepare.sh "$(pwd)"

ADD scripts/02-install.sh _x_scripts/02-install.sh
RUN _x_scripts/02-install.sh "$(pwd)"

#ADD configures_post/ _x_configures_post/
#ADD scripts/03-sphinx-env.sh _x_scripts/03-sphinx-env.sh
#RUN _x_scripts/03-sphinx-env.sh "$(pwd)"

#ADD scripts/04-post.sh _x_scripts/04-post.sh
#RUN _x_scripts/04-post.sh "$(pwd)"

ENV TERM="xterm-256color"
WORKDIR /root
CMD ["/bin/zsh", "-l"]
