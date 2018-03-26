#!/usr/bin/env bash

SECRETS="${SECRETS_FILE:-/run/secrets/secrets}"
if [ -f ${SECRETS} ]; then
    if [ ! -x ${SECRETS} ]; then
        chmod +x ${SECRETS}
    fi
    . ${SECRETS}
fi

exec catalina.sh run
