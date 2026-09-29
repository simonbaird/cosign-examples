
# Change as needed
TEST_REPO=quay.io/sbaird/nvda-test

TEST_IMG=$(TEST_REPO):latest

build:
	podman build . -t $(TEST_IMG) --no-cache --label build-timestamp=$(shell date +%s%N)

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

#-----------------------------------------------------------------------------

# See also https://raw.githubusercontent.com/sigstore/root-signing/refs/heads/main/targets/signing_config.v0.2.json
# This generates an empty signing config, which I think works fine for signing with long-lived keys.
signing-config.json:
	$(COSIGN) signing-config create > $@

#-----------------------------------------------------------------------------

sign-attest:
	@./sign-attest.sh

inspect:
	@./inspect.sh

verify:
	@./verify.sh

#-----------------------------------------------------------------------------

create-transcript:
	@NO_PAUSE=1 $(MAKE) --no-print-directory build-push sign-attest inspect verify 2>&1 | tee script.out
