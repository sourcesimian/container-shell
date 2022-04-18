#!/bin/bash

function help() {
    cat <<EOF
# --- CoSH --------------------------------------------------------------------
# IMAGE: $(cosh image)
#
# Readme:
#   $(cat /cosh/readme.url)
# -----------------------------------------------------------------------------
Usage:
    cosh [command ...]

Options:
  -h, --help       Show this help
      --version    Show the image and tag

Commands:
  *                Any command that can be run within CoSH
  uninstall        Remove all CoSH images
  ps-list          List all CoSH running containers
  stop-all         Stop all CoSH running containers

Internal commands:
  id               Show the ID of the current container
  ip               Show th IP address of the current container
  image            Show th eimage of the current container

Environment variables:
  COSH_IMAGE      - Override the default image name
  COSH_USER       - defaults to your \$USER. Set to run as a different user in CoSH.
  COSH_SHELL      - defaults to 'bash', can be set to 'zsh' (experimental).
  COSH_PORTS      - expose and publish ports to local host, use ',' as a seperator.
                    Can be used to remote debug processes run inside CoSH.

  MYTEAM_ROOT     - defaults to ~/work/MYTEAM. Set to where you checkout the MYTEAM repos.
EOF
    exit 0
}

help
