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

COPY src/supervisord.conf /etc/supervisor.conf
COPY src/setup_script.sh ${INST_SCRIPTS}/setup_script.sh

RUN bash ${INST_SCRIPTS}/setup_script.sh && \
    useradd --system --create-home --uid 1001 --gid 0 ifaas

COPY src/xorg.conf /etc/X11/xorg.conf

CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]
