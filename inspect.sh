#!/usr/bin/env bash

set -euo pipefail

source ./common.sh

h1 "oras discover"
oras discover --format tree $TEST_IMG

pause

h1 "cosign tree"
$COSIGN tree $TEST_IMG

pause

h1 "View attestations (notice the image sig is actually an attestation with no predicate)"

$COSIGN download attestation $TEST_IMG | jq '.dsseEnvelope.payload|@base64d|fromjson'

pause
