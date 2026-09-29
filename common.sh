#!/usr/bin/env bash

set -euo pipefail

source ./helpers.sh

COSIGN=cosign
#COSIGN=/usr/local/bin/cosign

TEST_REPO=quay.io/sbaird/nvda-test
UNRESOLVED_TEST_IMG=${TEST_REPO}:latest
TEST_IMG="$TEST_REPO@$(oras resolve $UNRESOLVED_TEST_IMG)"

# Likely copied/mirrored by oc-mirror
# Uncomment and run verify.sh and inspect.sh to test
#TEST_IMG=quay.io/konflux-local-test/sbaird/nvda-test:latest

# Likely copied/mirrored by oras cp -r
# Uncomment and run verify.sh and inspect.sh to test
#TEST_IMG=quay.io/sbaird/nvda-test-oras-mirror:latest

SIGNING_KEY=signing-key/cosign.key
PUBLIC_KEY=signing-key/cosign.pub
SIGNING_KEY_PASSWORD=secret123

SLSA_V1_TYPE=https://slsa.dev/provenance/v1
