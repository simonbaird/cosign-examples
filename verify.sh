#!/usr/bin/env bash

set -euo pipefail

source ./common.sh

h1 "cosign verify"
COSIGN_PASSWORD=$SIGNING_KEY_PASSWORD $COSIGN verify \
  --key $PUBLIC_KEY \
  $TEST_IMG

pause

h1 "cosign verify attestation"
COSIGN_PASSWORD=$SIGNING_KEY_PASSWORD $COSIGN verify-attestation \
  --key $PUBLIC_KEY \
  --type $SLSA_V1_TYPE \
  $TEST_IMG

pause

h1 "cosign verify (ignoring rekor)"
COSIGN_PASSWORD=$SIGNING_KEY_PASSWORD $COSIGN verify \
  --key $PUBLIC_KEY \
  --insecure-ignore-tlog=true \
  $TEST_IMG

pause

h1 "cosign verify attestation (ignoring rekor)"
COSIGN_PASSWORD=$SIGNING_KEY_PASSWORD $COSIGN verify-attestation \
  --key $PUBLIC_KEY \
  --type $SLSA_V1_TYPE \
  --insecure-ignore-tlog=true \
  $TEST_IMG

pause
