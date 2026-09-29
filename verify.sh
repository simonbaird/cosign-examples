#!/usr/bin/env bash

set -euo pipefail

source ./common.sh

show 'TEST_IMG' $TEST_IMG
show 'Digest' $(oras resolve $TEST_IMG)

if [[ ${USE_REKOR:-""} == "1" ]]; then

h1 "cosign verify"
pause-then-run "COSIGN_PASSWORD=$SIGNING_KEY_PASSWORD $COSIGN verify \
--key $PUBLIC_KEY \
"'$TEST_IMG'

pause

h1 "cosign verify attestation"
pause-then-run "COSIGN_PASSWORD=$SIGNING_KEY_PASSWORD $COSIGN verify-attestation \
--key $PUBLIC_KEY \
--type $SLSA_V1_TYPE \
"'$TEST_IMG'

pause

fi

h1 "cosign verify (ignoring rekor)"
pause-then-run "COSIGN_PASSWORD=$SIGNING_KEY_PASSWORD $COSIGN verify \
--key $PUBLIC_KEY \
--insecure-ignore-tlog=true \
"'$TEST_IMG'

pause

h1 "cosign verify attestation (ignoring rekor)"
pause-then-run "COSIGN_PASSWORD=$SIGNING_KEY_PASSWORD $COSIGN verify-attestation \
--key $PUBLIC_KEY \
--type $SLSA_V1_TYPE \
--insecure-ignore-tlog=true \
"'$TEST_IMG'

pause
