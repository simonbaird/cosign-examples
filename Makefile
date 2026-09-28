
# Change as needed
TEST_REPO=quay.io/sbaird/nvda-test

TEST_IMG=$(TEST_REPO):latest

build:
	podman build . -t $(TEST_IMG) --no-cache

push:
	podman push $(TEST_IMG)

run:
	podman run --rm $(TEST_IMG)

build-push: build push

#-----------------------------------------------------------------------------

COSIGN=/usr/local/bin/cosign
SIGNING_KEY_PASSWORD=secret123

signing-key:
	mkdir -p signing-key
	cd signing-key && COSIGN_PASSWORD=$(SIGNING_KEY_PASSWORD) $(COSIGN) generate-key-pair

clear-signing-key:
	rm -rf signing-key
