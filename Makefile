export PIGEN_DOCKER_OPTS=-v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock -e SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock

clean: clean_skips
	docker rm -v pigen_work || true

skip_stages:
	mkdir -p stage3 stage4 stage5
	touch stage3/SKIP stage4/SKIP stage5/SKIP
	touch stage2/SKIP_IMAGES stage4/SKIP_IMAGES stage5/SKIP_IMAGES

clean_skips:
	rm -f stage1/SKIP stage2/SKIP

skip_pre:
	mkdir -p stage1 stage2
	touch stage1/SKIP stage2/SKIP

build: clean skip_stages
	./build-docker.sh

dev: skip_stages
	CLEAN=1 PRESERVE_CONTAINER=1 CONTINUE=1 ./build-docker.sh && \
	$(MAKE) skip_pre
