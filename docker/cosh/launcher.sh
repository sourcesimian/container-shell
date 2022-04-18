#!/bin/bash
# shellcheck disable=SC2086
set -$COSH_BASH_OPTS
set -e
export COSH_IMAGE=${COSH_IMAGE:-cosh:0}

function cosh_ps_list() {
    docker ps  --format '{{.ID}} {{.Image}}' \
    | grep -F " ${COSH_IMAGE}" \
    | while read -r ID IMAGE; do
        echo "$ID $(docker inspect "$ID" --format '{{.Name}} {{.NetworkSettings.IPAddress}} {{range $k,$v:=.NetworkSettings.Ports}}{{$k}} {{end}}')"
    done
}

function cosh_stop_all() {
    # shellcheck disable=SC2034
    docker ps  --format '{{.ID}} {{.Image}} {{.Names}}' \
    | grep -F " ${COSH_IMAGE}" \
    | while read -r ID IMAGE NAMES; do
        echo "# Stoping: $NAMES"
        docker stop "$ID"
    done
}

function cosh_purge() {
    {
        set +e
        docker images --format "{{.Repository}}:{{.Tag}}" \
            | grep 'cosh:' \
            | xargs docker rmi -f
        rm -f ~/bin/cosh 2>&1
    }
}

function cosh_env() {
    # shellcheck disable=SC2207
    CMD+=($(
        {
            env | grep -e '^USER=' -e '^HOME=' -e '^MYTEAM_'
            [ -n "$HOSTNAME" ] && echo "HOSTNAME=$HOSTNAME"
            [ -n "$COSH_USER" ] && echo "COSH_USER=$COSH_USER"
            COSH_GROUP=$(id -g -n)
            echo "COSH_GROUP=${COSH_GROUP/docker/$(id -u -n)}"
            echo "COSH_PATH=$(tr ':' '\n' <<<"$PATH" | grep "^$HOME" | sort -u | xargs echo | tr ' ' ':')"
            [ -n "$COSH_SHELL" ] && echo "COSH_SHELL=$COSH_SHELL"
            echo "COSH_BASH_OPTS=$COSH_BASH_OPTS"
        } | awk '{print "--env "$1}' | tr '\n' ' '
    ))
}

function proxy_env() {
    # shellcheck disable=SC2207
    CMD+=($(
        {
            env | grep -i -e '^HTTP_PROXY=' -e '^HTTPS_PROXY=' -e '^NO_PROXY='
        } | awk '{print "--env "$1}' | tr '\n' ' '
    ))
}

function mount_user() {
    # shellcheck disable=SC2207
    CMD+=($(
        {
            echo "$(dirname "${HOME}"):$(dirname "${HOME}"):rw"
            [ -e /tmp ] && echo "/tmp:/tmp:rw"
        }  | awk '{print "--volume "$1}' | tr '\n' ' '
    ))
}

function expose_ports() {
    # shellcheck disable=SC2207
    CMD+=($(
        {
            local PORTS
            IFS=, read -ra PORTS <<< "$COSH_PORTS"
            for PORT in "${PORTS[@]}"; do
                echo "--expose $PORT --publish $PORT:$PORT"
            done
        }  | tr '\n' ' '
    ))
}

function cosh_launch() {
    CMD=(docker)
    [ -z "$COSH_ID" ] && CMD+=(run) || CMD+=(exec)
    CMD+=(-i)
    [ -t 1 ] && CMD+=(-t)
    [ -z "$COSH_ID" ] && CMD+=(--rm)
    cosh_env
    proxy_env
    CMD+=(--user "$(id -u):$(id -g)")
    [ -z "$COSH_ID" ] && CMD+=(--hostname "cosh-$(hostname)")
    [ -z "$COSH_ID" ] && CMD+=(--group-add docker)
    [ -z "$COSH_ID" ] && mount_user
    [ -z "$COSH_ID" ] && expose_ports
    [ -z "$COSH_ID" ] && CMD+=(--volume /var/run/docker.sock:/var/run/docker.sock)
    CMD+=(--workdir "$PWD")
    [ -z "$COSH_ID" ] && CMD+=(--entrypoint /cosh/entrypoint.sh)
    [ -z "$COSH_ID" ] && CMD+=("$COSH_IMAGE") || CMD+=("$COSH_ID")
    [ -z "$COSH_ID" ] || CMD+=(/cosh/entrypoint.sh)

    exec "${CMD[@]}" "${@}"
}


function main() {
    case "$1" in
        "ps-list")
            cosh_ps_list
            ;;
        "stop-all")
            cosh_stop_all
            ;;
        "uninstall")
            cosh_purge
            ;;
        *)
            cosh_launch "${@}"
            ;;
    esac
}


main "${@}"
