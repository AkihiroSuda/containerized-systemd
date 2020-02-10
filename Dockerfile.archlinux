FROM archlinux:latest
RUN pacman -Sy --noconfirm systemd systemd-sysvcompat
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
