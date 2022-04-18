#!/bin/bash
export COSH_BASH_OPTS=$-
set -e
COSH_IMAGE_DEFAULT=_COSH_IMAGE_DEFAULT_
export COSH_IMAGE=${COSH_IMAGE:-$COSH_IMAGE_DEFAULT}

IMAGE_ID=$(docker inspect --format "{{.Id}}" "$COSH_IMAGE")
COSH_LAUNCHER=~/.cache/cosh/launcher.${IMAGE_ID//:/\~}

if [ ! -f "$COSH_LAUNCHER" ]; then
    mkdir -p "$(dirname "$COSH_LAUNCHER")"
    docker run --rm "$COSH_IMAGE" cat-launcher > "$COSH_LAUNCHER"
    chmod +x "$COSH_LAUNCHER"
fi

exec "$COSH_LAUNCHER" "${@}"
