FROM debian:10
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  systemd systemd-sysv dbus dbus-user-session
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
