export PIGEN_DOCKER_OPTS=-v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock -e SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock

clean:
	docker rm -v pigen_work

build: clean
	./build-docker.sh

dev:
	CLEAN=1 PRESERVE_CONTAINER=1 CONTINUE=1 ./build-docker.sh
