FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/dpkg/dpkg.cfg.d/excludes \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       sudo procps psmisc file adduser man-db manpages \
       less vim curl wget ca-certificates bash-completion \
       iproute2 dnsutils tmux cron \
    && dpkg-divert --remove /usr/bin/man \
    && cp -f /usr/bin/man.REAL /usr/bin/man 2>/dev/null || true \
    && apt-get install --reinstall -y --no-install-recommends \
       coreutils util-linux procps findutils gzip grep sed diffutils tar \
       gpgv mount \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash juanes \
    && echo 'juanes ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/juanes

COPY setup.sh /setup.sh
RUN chmod +x /setup.sh && /setup.sh

USER juanes
WORKDIR /home/juanes

CMD ["/bin/bash"]