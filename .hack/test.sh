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
	docker run -t --rm --privileged $iid systemctl status --no-pager
	docker image rm $iid
done
