#!/bin/sh
set -e
if [ $# -eq 0 ]; then
	echo >&2 'ERROR: No Dockerfile specified.'
	exit 1
fi
set -x
for dockerfile in $@; do
	echo "=== Testing ${dockerfile} ==="
	iid=$(docker build -q -f ${dockerfile} .)
	# NOTE: old version of systemd doesn't wait for `systemctl is-system-running --wait`, so we have `until` loop here.
	docker run -t --rm --privileged $iid sh -exc "until systemctl is-system-running --wait; do sleep 1; done; systemctl status --no-pager"
	docker image rm $iid
done
