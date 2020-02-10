#!/bin/sh
# from https://github.com/moby/moby/pull/40493
set -e
container=docker
export container
if [ ! -t 0 ]; then
	echo >&2 'ERROR: TTY needs to be enabled (`docker run -t ...`).'
	exit 1
fi

if [ $# -gt 0 ]; then
	cat >/lib/systemd/system/docker-entrypoint.target <<EOF
[Unit]
Description=the target for docker-entrypoint.service
EOF
	cat >/lib/systemd/system/docker-entrypoint.service <<EOF
[Unit]
Description=docker-entrypoint.service ($@)
After=docker-entrypoint.target

[Service]
ExecStart=$@
ExecStopPost=systemctl exit \$EXIT_STATUS
StandardInput=tty-force
StandardOutput=inherit
StandardError=inherit

[Install]
WantedBy=docker-entrypoint.target
EOF
	systemctl enable docker-entrypoint.service
else
	echo >&2 'ERROR: No command specified.'
	echo >&2 'You probably want to run \"bash\"?'
	exit 1
fi

systemd_args="--show-status=false --unit=docker-entrypoint.target"
echo "$0: starting /sbin/init $systemd_args"
exec /sbin/init $systemd_args
