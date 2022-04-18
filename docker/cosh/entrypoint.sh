#!/bin/bash
# shellcheck disable=SC2086
set -$COSH_BASH_OPTS
unset COSH_BASH_OPTS
set -e

export USER=${COSH_USER:-${USER}}
unset COSH_USER
/cosh/setupuser "$USER" "$(id -u)" "$COSH_GROUP" "$(id -g)" "$HOME" </dev/null
/cosh/setupdocker "$USER" docker
unset COSH_GROUP

export PATH=$COSH_PATH:$PATH
unset COSH_PATH

# shellcheck disable=SC1091
. /cosh/cosh.env.sh

case "$1" in
    "-h"|"--help")
        cosh --help
        exit 0
        ;;
    "--version")
        cosh image
        exit 0
        ;;
esac

case "${COSH_SHELL:-bash}" in
    bash)
        COSH_SHELL_CMD="/bin/bash -l"
        ;;
    zsh)
        COSH_SHELL_CMD="/bin/zsh -l"
        ;;
    *)
        echo "! Unknown COSH_SHELL: $COSH_SHELL"
        exit 1
        ;;
esac

if [ -n "$1" ]; then
    exec "${@}"
fi

exec $COSH_SHELL_CMD
