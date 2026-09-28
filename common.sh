#!/usr/bin/env bash

set -euo pipefail

source ./helpers.sh

COSIGN=/usr/local/bin/cosign

TEST_REPO=quay.io/sbaird/nvda-test
UNRESOLVED_TEST_IMG=${TEST_REPO}:latest
TEST_IMG="$TEST_REPO@$(oras resolve $UNRESOLVED_TEST_IMG)"

SIGNING_KEY=signing-key/cosign.key
PUBLIC_KEY=signing-key/cosign.pub
SIGNING_KEY_PASSWORD=secret123

SLSA_V1_TYPE=https://slsa.dev/provenance/v1
