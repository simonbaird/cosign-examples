#!/usr/bin/env bash

set -euo pipefail

source ./common.sh

# See also Makefile
h1 "Setup"

show "Image under test" "$TEST_IMG"
show "Cosign version" "$($COSIGN version --json | jq -r .gitVersion), built $($COSIGN version --json | jq -r .buildDate)"

# IIUC it will use the default rekor.sigstore.dev if we don't disable
# rekor and don't specify a custom rekor instance with --rekor-url
if [[ ${USE_REKOR:-""} == "1" ]]; then
  REKOR_OPTS=""
else
  # Previously you could use --tlog-upload=false but now you need to
  # use a signing-config.json that does not specify a rekor/tlog service.
  REKOR_OPTS="--signing-config=signing-config.json"
fi

pause

h1 "Sign the image using a traditional signing secret"

# Choose traditional signing secret instead of keyless because we're hoping
# to be able to verify without using the transparency log. IIUC keyless
# signature verification requires the transparency log to be available.
pause-then-run 'COSIGN_PASSWORD='$SIGNING_KEY_PASSWORD' '$COSIGN' sign \
    '$REKOR_OPTS' \
    --key '$SIGNING_KEY' \
    $TEST_IMG
'

pause

h1 "Create and attest a minimal slsa provenance"

pause-then-run 'COSIGN_PASSWORD='$SIGNING_KEY_PASSWORD' '$COSIGN' attest \
    '$REKOR_OPTS' \
    --key '$SIGNING_KEY' \
    --type "https://slsa.dev/provenance/v1" \
    --predicate minimal-provenance.json \
    $TEST_IMG
'

pause
