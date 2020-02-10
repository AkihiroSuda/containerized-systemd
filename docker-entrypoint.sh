#!/bin/sh
# from https://github.com/moby/moby/pull/40493
set -e
container=docker
export container

if [ $# -eq 0 ]; then
	echo >&2 'ERROR: No command specified. You probably want to run \"bash\"?'
	exit 1
fi

if [ ! -t 0 ]; then
	echo >&2 'ERROR: TTY needs to be enabled (`docker run -t ...`).'
	exit 1
fi

env >/etc/docker-entrypoint-env

cat >/etc/systemd/system/docker-entrypoint.target <<EOF
[Unit]
Description=the target for docker-entrypoint.service
EOF

cat >/etc/systemd/system/docker-entrypoint.service <<EOF
[Unit]
Description=docker-entrypoint.service ($@)
After=docker-entrypoint.target

[Service]
ExecStart=/bin/sh -xec "$@"
ExecStopPost=systemctl exit \$EXIT_STATUS
StandardInput=tty-force
StandardOutput=inherit
StandardError=inherit
WorkingDirectory=$(pwd)
EnvironmentFile=/etc/docker-entrypoint-env

[Install]
WantedBy=docker-entrypoint.target
EOF
systemctl enable docker-entrypoint.service
systemctl mask systemd-firstboot.service systemd-udevd.service

systemd=
if [ -x /lib/systemd/systemd ]; then
	systemd=/lib/systemd/systemd
elif [ -x /usr/lib/systemd/systemd ]; then
	systemd=/usr/lib/systemd/systemd
elif [ -x /sbin/init ]; then
	systemd=/sbin/init
else
	echo >&2 'ERROR: systemd is not installed'
	exit 1
fi
systemd_args="--show-status=false --unit=docker-entrypoint.target"
echo "$0: starting $systemd $systemd_args"
exec $systemd $systemd_args
