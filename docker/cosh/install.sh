#!/bin/bash
set -e

function cat_install_help() {
    cat << EOF
# --- CoSH ---------------------------------------------------------------------
# Readme:
#   $(cat /cosh/readme.url)
#
# Install the CoSH laucher by running:
bash <(docker run --rm "$COSH_IMAGE" cat-setup); ~/bin/cosh --help
# -----------------------------------------------------------------------------
EOF
}

function cat_setup() {
    cat << EOF
mkdir -p ~/bin
docker run --rm "$COSH_IMAGE" cat-stub > ~/bin/cosh
chmod +x ~/bin/cosh
EOF
}


case "$1" in
    "cat-setup")
        cat_setup
        ;;
    "cat-stub")
        sed -e "s|_COSH_IMAGE_DEFAULT_|$COSH_IMAGE|" /cosh/stub.sh 
        ;;
    "cat-launcher")
        cat /cosh/launcher.sh
        ;;
    *)
        cat_install_help
        ;;
esac
