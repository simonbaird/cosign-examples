# Cosign examples

Currently the we're using traditional long-lived signing keys rather than
keyless signing.

## Creating the test image

```
$ make build run push
podman build . -t quay.io/sbaird/nvda-test:latest --no-cache --label build-timestamp=1790626121221933176
STEP 1/3: FROM docker.io/redhat/ubi9-minimal:latest
STEP 2/3: CMD echo "Hello there!"
--> 7c5b533f924b
STEP 3/3: LABEL "build-timestamp"="1790626121221933176"
COMMIT quay.io/sbaird/nvda-test:latest
--> 60d35d5d0f07
Successfully tagged quay.io/sbaird/nvda-test:latest
60d35d5d0f07a811fed6773ebbbff7bc1c71bb9e9e6906ec85593b770e6f62d7
podman run --rm quay.io/sbaird/nvda-test:latest
Hello there!
podman push quay.io/sbaird/nvda-test:latest
Getting image source signatures
Copying blob 24153d7cac0e skipped: already exists
Copying config 60d35d5d0f done   |
Writing manifest to image destination
```

## Signing and attesting

```
$ make sign-attest
╭───────╮
┝ Setup ┥
╰───────╯
Image under test:    quay.io/sbaird/nvda-test@sha256:d429dc4ab09cf5e6c101ceaed1468b7bf67f5e2ceafd5ec4935b751e324095af
Cosign version:      v3.1.3, built 2026-08-05T23:43:27Z

╭───────────────────────────────────────────────────╮
┝ Sign the image using a traditional signing secret ┥
╰───────────────────────────────────────────────────╯
Pushing signature to: quay.io/sbaird/nvda-test

╭─────────────────────────────────────────────╮
┝ Create and attest a minimal slsa provenance ┥
╰─────────────────────────────────────────────╯
Using payload from: standard input
```

## Inspect image and related metadata

```
$ make inspect
╭───────────────╮
┝ oras discover ┥
╰───────────────╯
quay.io/sbaird/nvda-test@sha256:d429dc4ab09cf5e6c101ceaed1468b7bf67f5e2ceafd5ec4935b751e324095af
└── application/vnd.dev.sigstore.bundle.v0.3+json
    ├── sha256:62d4351958ac4eb4aa11ce9b01e48be4ce55328f2f7acc298b0ff9ccf8abf489
    │   └── [annotations]
    │       ├── dev.sigstore.bundle.content: dsse-envelope
    │       ├── dev.sigstore.bundle.predicateType: https://sigstore.dev/cosign/sign/v1
    │       └── org.opencontainers.image.created: "2026-09-28T20:08:56Z"
    └── sha256:774b6ab0e19b7c7bf73ec2b0bd10dddec942f4c6b92e6452df24fd3d0492e07b
        └── [annotations]
            ├── dev.sigstore.bundle.content: dsse-envelope
            ├── dev.sigstore.bundle.predicateType: https://slsa.dev/provenance/v1
            └── org.opencontainers.image.created: "2026-09-28T20:09:00Z"


╭─────────────╮
┝ cosign tree ┥
╰─────────────╯
📦 Supply Chain Security Related artifacts for an image: quay.io/sbaird/nvda-test@sha256:d429dc4ab09cf5e6c101ceaed1468b7bf67f5e2ceafd5ec4935b751e324095af
└── 🔗 https://sigstore.dev/cosign/sign/v1 artifacts via OCI referrer: quay.io/sbaird/nvda-test@sha256:62d4351958ac4eb4aa11ce9b01e48be4ce55328f2f7acc298b0ff9ccf8abf489
   └── 🍒 sha256:786c167671c5f4e7fd3ca342675ef3e08a289986e105e160492aa96420472f32
└── 🔗 https://slsa.dev/provenance/v1 artifacts via OCI referrer: quay.io/sbaird/nvda-test@sha256:774b6ab0e19b7c7bf73ec2b0bd10dddec942f4c6b92e6452df24fd3d0492e07b
   └── 🍒 sha256:1ada556016b7f0b5295ebf39df222d999e52bfbbacf3c50762940b4012d5c203


╭───────────────────────────────────────────────────────────────────────────────────────╮
┝ View attestations (notice the image sig is actually an attestation with no predicate) ┥
╰───────────────────────────────────────────────────────────────────────────────────────╯
{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [
    {
      "digest": {
        "sha256": "d429dc4ab09cf5e6c101ceaed1468b7bf67f5e2ceafd5ec4935b751e324095af"
      },
      "annotations": {}
    }
  ],
  "predicateType": "https://sigstore.dev/cosign/sign/v1",
  "predicate": {}
}
{
  "_type": "https://in-toto.io/Statement/v0.1",
  "subject": [
    {
      "name": "quay.io/sbaird/nvda-test",
      "digest": {
        "sha256": "d429dc4ab09cf5e6c101ceaed1468b7bf67f5e2ceafd5ec4935b751e324095af"
      }
    }
  ],
  "predicateType": "https://slsa.dev/provenance/v1",
  "predicate": {
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
}
```

## Verifying the image and attestation

```
$ make verify
╭────────────────────────────────╮
┝ cosign verify (ignoring rekor) ┥
╰────────────────────────────────╯
WARNING: Skipping tlog verification is an insecure practice that lacks transparency and auditability verification for the signature.

Verification for quay.io/sbaird/nvda-test@sha256:d429dc4ab09cf5e6c101ceaed1468b7bf67f5e2ceafd5ec4935b751e324095af --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key

[{"critical":{"identity":{"docker-reference":"quay.io/sbaird/nvda-test@sha256:d429dc4ab09cf5e6c101ceaed1468b7bf67f5e2ceafd5ec4935b751e324095af"},"image":{"docker-manifest-digest":"sha256:d429dc4ab09cf5e6c101ceaed1468b7bf67f5e2ceafd5ec4935b751e324095af"},"type":"https://sigstore.dev/cosign/sign/v1"},"optional":{}},{"critical":{"identity":{"docker-reference":"quay.io/sbaird/nvda-test@sha256:d429dc4ab09cf5e6c101ceaed1468b7bf67f5e2ceafd5ec4935b751e324095af"},"image":{"docker-manifest-digest":"sha256:d429dc4ab09cf5e6c101ceaed1468b7bf67f5e2ceafd5ec4935b751e324095af"},"type":"https://slsa.dev/provenance/v1"},"optional":{}}]

╭────────────────────────────────────────────╮
┝ cosign verify attestation (ignoring rekor) ┥
╰────────────────────────────────────────────╯
WARNING: Skipping tlog verification is an insecure practice that lacks transparency and auditability verification for the attestation.

Verification for quay.io/sbaird/nvda-test@sha256:d429dc4ab09cf5e6c101ceaed1468b7bf67f5e2ceafd5ec4935b751e324095af --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key
{"payload":"eyJfdHlwZSI6Imh0dHBzOi8vaW4tdG90by5pby9TdGF0ZW1lbnQvdjAuMSIsInN1YmplY3QiOlt7Im5hbWUiOiJxdWF5LmlvL3NiYWlyZC9udmRhLXRlc3QiLCJkaWdlc3QiOnsic2hhMjU2IjoiZDQyOWRjNGFiMDljZjVlNmMxMDFjZWFlZDE0NjhiN2JmNjdmNWUyY2VhZmQ1ZWM0OTM1Yjc1MWUzMjQwOTVhZiJ9fV0sInByZWRpY2F0ZVR5cGUiOiJodHRwczovL3Nsc2EuZGV2L3Byb3ZlbmFuY2UvdjEiLCJwcmVkaWNhdGUiOnsiYnVpbGREZWZpbml0aW9uIjp7ImJ1aWxkVHlwZSI6Imh0dHBzOi8vZXhhbXBsZS5jb20vYnVpbGQtdHlwZS92MSIsImV4dGVybmFsUGFyYW1ldGVycyI6e30sImludGVybmFsUGFyYW1ldGVycyI6e30sInJlc29sdmVkRGVwZW5kZW5jaWVzIjpbXX0sInJ1bkRldGFpbHMiOnsiYnVpbGRlciI6eyJpZCI6Imh0dHBzOi8vZXhhbXBsZS5jb20vYnVpbGRlciJ9LCJtZXRhZGF0YSI6e319fX0=","payloadType":"application/vnd.in-toto+json","signatures":[{"sig":"MEYCIQC6YfG3OYuW9cpAwNGRXeR77fhmNxfAKJxZS13zJ3ihagIhAONegFaes8oF0tDP90OIjFhU1bVsOgtyeZq6zX7HddJx"}]}
```
