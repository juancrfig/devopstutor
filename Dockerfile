FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/dpkg/dpkg.cfg.d/excludes \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       sudo procps psmisc file adduser man-db manpages \
       less vim curl wget ca-certificates bash-completion \
       iproute2 dnsutils tmux cron lsof perl git \
    && dpkg-divert --remove /usr/bin/man \
    && cp -f /usr/bin/man.REAL /usr/bin/man 2>/dev/null || true \
    && apt-get install --reinstall -y --no-install-recommends \
       coreutils util-linux procps findutils gzip grep sed diffutils tar \
       gpgv mount \
    && rm -rf /var/lib/apt/lists/*

# The package layer above is FROZEN: editing it forces a ~10 min rebuild on
# every machine. New tickets that need packages append their own small layer
# here instead, e.g.:
#   RUN apt-get update && apt-get install -y --no-install-recommends <pkg> \
#       && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash juanes \
    && echo 'juanes ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/juanes \
    && printf 'set bell-style none\n' > /home/juanes/.inputrc \
    && chown juanes:juanes /home/juanes/.inputrc

# systemd as PID 1, so services, timers and cron run for real (06-services and
# later topics). The base image ships systemd; systemd-sysv adds /sbin/init,
# and dbus lets juanes run `systemctl status` without sudo.
RUN apt-get update && apt-get install -y --no-install-recommends systemd-sysv dbus \
    && rm -rf /var/lib/apt/lists/*

# Tell systemd it runs in a container. Mask the units that would touch host
# devices or wait for a console: the lab is --privileged, so udev and module
# loading must stay off.
ENV container=docker
RUN systemctl mask \
      systemd-udevd.service systemd-udevd-kernel.socket systemd-udevd-control.socket \
      systemd-udev-trigger.service systemd-modules-load.service \
      systemd-remount-fs.service sys-kernel-config.mount sys-kernel-debug.mount \
      sys-kernel-tracing.mount sys-fs-fuse-connections.mount \
      getty.target console-getty.service systemd-firstboot.service \
      systemd-timesyncd.service systemd-networkd-wait-online.service

# Like the first user on a real Ubuntu box, juanes is in adm, so journalctl
# shows system logs without sudo.
RUN usermod -aG adm juanes

COPY setup.sh /setup.sh
RUN chmod +x /setup.sh && /setup.sh

# PID 1 is init and runs as root. run.sh opens your shell as juanes with
# `docker exec`, in /home/juanes.
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
