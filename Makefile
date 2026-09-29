
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

MIRROR_DATA_DIR=mirror-data

# I happen to own this quay org:
MIRROR_TARGET=quay.io/konflux-local-test

mirror-to-disk:
	@mkdir -p mirror-data
	oc-mirror -c ./isc.yaml file://$(MIRROR_DATA_DIR) --v2

# It pushes to https://quay.io/repository/konflux-local-test/sbaird/nvda-test which is
# fine for our purposes. (Generally oc-mirror is expecting you'll push to the same path
# in a different registry, rather than a different path in the same registry.)
disk-to-mirror:
	oc-mirror -c ./isc.yaml --from file://$(MIRROR_DATA_DIR) docker://$(MIRROR_TARGET) --v2

#-----------------------------------------------------------------------------

# Unlike oc-mirror v2, "oras cp -r" follows the OCI referrers graph, so the
# image's attestations/signatures (linked via the subject field) come along too.
ORAS_LAYOUT=oras-mirror-data
ORAS_MIRROR_REPO=quay.io/sbaird/nvda-test-oras-mirror

# Export the image and its referrers to an on-disk OCI image layout.
oras-mirror-to-disk:
	oras cp -r --to-oci-layout $(TEST_IMG) $(ORAS_LAYOUT):latest

# Push from the on-disk layout to the mirror repo, referrers included, and
# note it lands at exactly $(ORAS_MIRROR_REPO) with no extra path nesting.
oras-disk-to-mirror:
	oras cp -r --from-oci-layout $(ORAS_LAYOUT):latest $(ORAS_MIRROR_REPO):latest

#-----------------------------------------------------------------------------

create-transcript:
	@NO_PAUSE=1 $(MAKE) --no-print-directory build-push sign-attest inspect verify 2>&1 | tee script.out
