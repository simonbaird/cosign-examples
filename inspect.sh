#!/usr/bin/env bash

set -euo pipefail

source ./common.sh

show 'TEST_IMG' $TEST_IMG
show 'Digest' $(oras resolve $TEST_IMG)

h1 "oras discover"
pause-then-run 'oras discover --format tree $TEST_IMG'

pause

h1 "cosign tree"
pause-then-run $COSIGN' tree $TEST_IMG'

pause

h1 "View attestations (notice the image sig is actually an attestation with an empty predicate)"

pause-then-run $COSIGN' download attestation $TEST_IMG | jq ".dsseEnvelope.payload | @base64d | fromjson"'

pause
