#!/usr/bin/env bash

set -euo pipefail

source ./common.sh

# See also Makefile
h1 "Setup"

show "Image under test" "$TEST_IMG"
show "Cosign version" "$($COSIGN version --json | jq -r .gitVersion), built $($COSIGN version --json | jq -r .buildDate)"

pause

h1 "Sign the image using a traditional signing secret"

# Choose traditional signing secret instead of keyless because we're hoping
# to be able to verify without using the transparency log. IIUC keyless
# signature verification requires the transparency log to be available.
COSIGN_PASSWORD=$SIGNING_KEY_PASSWORD $COSIGN sign \
  --key $SIGNING_KEY \
  $TEST_IMG

pause

h1 "Create and attest a minimal slsa provenance"

MINIMAL_PROVENANCE='
{
  "buildDefinition": {
    "buildType": "https://example.com/build-type/v1",
    "externalParameters": {},
    "internalParameters": {},
    "resolvedDependencies": []
  },
  "runDetails": {
    "builder": {
      "id": "https://example.com/builder"
    },
    "metadata": {}
  }
}
'

COSIGN_PASSWORD=$SIGNING_KEY_PASSWORD $COSIGN attest \
  --key $SIGNING_KEY \
  --type "https://slsa.dev/provenance/v1" \
  --predicate - \
  $TEST_IMG \
  <<< "$MINIMAL_PROVENANCE"

pause
