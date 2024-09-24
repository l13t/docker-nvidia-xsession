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

RUN bash ${INST_SCRIPTS}/setup_script.sh && \
    groupadd -g 0 root && \
    useradd --system --create-home --uid 1001 --gid 0 -G 0,1001 ifaas

COPY src/xorg.conf /etc/X11/xorg.conf
ENV TINI_VERSION v0.19.0

ADD https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini /tini
ADD https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini.asc /tini.asc

RUN gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
    && gpg --batch --verify /tini.asc /tini && \
    chmod +x /tini

COPY src/lightdm.conf /etc/lightdm/lightdm.conf

ENV LC_ALL="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV DISPLAY=":0"
ENV CHROME_CONFIG_HOME="/opt/docker"
ENV LANG="en_US.UTF-8"
ENV AWS_REGION="us-east-1"

ENTRYPOINT ["/tini", "--"]

COPY src/entrypoint.sh /entrypoint.sh
COPY src/openbox_autostart /etc/xdg/openbox/autostart
RUN chmod +x /entrypoint.sh

RUN echo "Cache cleanup" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*

CMD ["/entrypoint.sh"]
