COSH_IMAGE=cosh:1

cosh:
	docker build -f Dockerfile --build-arg COSH_IMAGE=${COSH_IMAGE} docker/ -t ${COSH_IMAGE}


check:
	cosh shellcheck docker/cosh/stub.sh
	cosh shellcheck docker/cosh/launcher.sh
	cosh shellcheck docker/cosh/entrypoint.sh
	cosh shellcheck docker/cosh/install.sh
	cosh shellcheck docker/cosh/help.sh
	cosh shellcheck docker/cosh/zfunc/cosh
