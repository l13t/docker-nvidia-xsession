FROM ubuntu:22.04

ARG LANG='en_US.UTF-8'
ARG LANGUAGE='en_US:en'
ARG LC_ALL='en_US.UTF-8'
ARG TZ='Etc/UTC'

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=${LANG} \
    LANGUAGE=${LANGUAGE} \
    LC_ALL=${LC_ALL} \
    TZ=${TZ} \
    INST_SCRIPTS=/opt/scripts

COPY src/setup_script.sh ${INST_SCRIPTS}/setup_script.sh

RUN useradd --system --create-home --uid 1001 --gid 0 ifaas && \
    bash ${INST_SCRIPTS}/setup_script.sh

COPY src/xorg.conf /etc/X11/xorg.conf
ENV TINI_VERSION v0.19.0

ADD https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini /tini
ADD https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini.asc /tini.asc

RUN gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
    && gpg --batch --verify /tini.asc /tini && \
    chmod +x /tini && \
    rm -rf /tini.asc

ENV LC_ALL="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV DISPLAY=":0"
ENV CHROME_CONFIG_HOME="/opt/docker"
ENV LANG="en_US.UTF-8"
ENV XDG_RUNTIME_DIR="/tmp"

COPY src/init.sh /init.sh

RUN mkdir -p /home/ifaas/.config/openbox/
COPY --chown=ifaas:ifaas src/autostart /home/ifaas/.config/openbox/autostart

RUN echo "Cache cleanup" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

USER 1001:0
WORKDIR /home/ifaas
ENTRYPOINT ["/tini", "--"]
CMD ["/init.sh"]
