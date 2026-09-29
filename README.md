# Cosign examples

Currently the we're using traditional long-lived signing keys rather than
keyless signing.

## Example transcript

```
podman build . -t quay.io/sbaird/nvda-test:latest --no-cache --label build-timestamp=1790695157526893364
STEP 1/3: FROM docker.io/redhat/ubi9-minimal:latest
STEP 2/3: CMD echo "Hello there!"
--> e96e29a42e0f
STEP 3/3: LABEL "build-timestamp"="1790695157526893364"
COMMIT quay.io/sbaird/nvda-test:latest
--> d3edf685c10d
Successfully tagged quay.io/sbaird/nvda-test:latest
d3edf685c10d53232e804f9c421e00565e36cc574f5514517ec465104d1ff483
podman push quay.io/sbaird/nvda-test:latest
Getting image source signatures
Copying blob sha256:539971d3f22c7a125309686bb61c3c1b07f915053d84bcda0b424923563bcd4b
Copying config sha256:d3edf685c10d53232e804f9c421e00565e36cc574f5514517ec465104d1ff483
Writing manifest to image destination
╭───────╮
┝ Setup ┥
╰───────╯
Image under test:    quay.io/sbaird/nvda-test@sha256:9102954d01165404605033b07969d78f63049df67fd9ea1b7880a89ab293890e
Cosign version:      v3.1.3, built 2026-08-05T23:43:27Z

╭───────────────────────────────────────────────────╮
┝ Sign the image using a traditional signing secret ┥
╰───────────────────────────────────────────────────╯

$ COSIGN_PASSWORD=secret123 cosign sign \
    --signing-config=signing-config.json \
    --key signing-key/cosign.key \
    $TEST_IMG

Signing artifact...
Pushing signature to: quay.io/sbaird/nvda-test


╭─────────────────────────────────────────────╮
┝ Create and attest a minimal slsa provenance ┥
╰─────────────────────────────────────────────╯

$ COSIGN_PASSWORD=secret123 cosign attest \
    --signing-config=signing-config.json \
    --key signing-key/cosign.key \
    --type "https://slsa.dev/provenance/v1" \
    --predicate minimal-provenance.json \
    $TEST_IMG

Using payload from: minimal-provenance.json
Signing artifact...


╭───────────────╮
┝ oras discover ┥
╰───────────────╯

$ oras discover --format tree $TEST_IMG

quay.io/sbaird/nvda-test@sha256:9102954d01165404605033b07969d78f63049df67fd9ea1b7880a89ab293890e
└── application/vnd.dev.sigstore.bundle.v0.3+json
    ├── sha256:9b7cbdc175f63e4d28d853b290033c97b710b622e90ef65d1e50cd9a13cb0c1f
    │   └── [annotations]
    │       ├── dev.sigstore.bundle.content: dsse-envelope
    │       ├── dev.sigstore.bundle.predicateType: https://sigstore.dev/cosign/sign/v1
    │       └── org.opencontainers.image.created: "2026-09-29T15:19:22Z"
    └── sha256:4a6a2f5c59ea87864870f23d62c8fc6ac8074d55599e2a6c6371fb8326d51c59
        └── [annotations]
            ├── dev.sigstore.bundle.content: dsse-envelope
            ├── dev.sigstore.bundle.predicateType: https://slsa.dev/provenance/v1
            └── org.opencontainers.image.created: "2026-09-29T15:19:25Z"


╭─────────────╮
┝ cosign tree ┥
╰─────────────╯

$ cosign tree $TEST_IMG

📦 Supply Chain Security Related artifacts for an image: quay.io/sbaird/nvda-test@sha256:9102954d01165404605033b07969d78f63049df67fd9ea1b7880a89ab293890e
└── 🔗 https://sigstore.dev/cosign/sign/v1 artifacts via OCI referrer: quay.io/sbaird/nvda-test@sha256:9b7cbdc175f63e4d28d853b290033c97b710b622e90ef65d1e50cd9a13cb0c1f
   └── 🍒 sha256:0f683a351e4c3758f0280c18eff474308a926b7e8887ef2b84deb04d5b2cca1d
└── 🔗 https://slsa.dev/provenance/v1 artifacts via OCI referrer: quay.io/sbaird/nvda-test@sha256:4a6a2f5c59ea87864870f23d62c8fc6ac8074d55599e2a6c6371fb8326d51c59
   └── 🍒 sha256:29d04fd5067884494499e7f748286b13716d044ad0c2be4e4e604fc32ce72b7c


╭─────────────────────────────────────────────────────────────────────────────────────────────╮
┝ View attestations (notice the image sig is actually an attestation with an empty predicate) ┥
╰─────────────────────────────────────────────────────────────────────────────────────────────╯

$ cosign download attestation $TEST_IMG | jq ".dsseEnvelope.payload | @base64d | fromjson"

{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [
    {
      "digest": {
        "sha256": "9102954d01165404605033b07969d78f63049df67fd9ea1b7880a89ab293890e"
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
        "sha256": "9102954d01165404605033b07969d78f63049df67fd9ea1b7880a89ab293890e"
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


╭────────────────────────────────╮
┝ cosign verify (ignoring rekor) ┥
╰────────────────────────────────╯

$ COSIGN_PASSWORD=secret123 cosign verify --key signing-key/cosign.pub --insecure-ignore-tlog=true $TEST_IMG

WARNING: Skipping tlog verification is an insecure practice that lacks transparency and auditability verification for the signature.

Verification for quay.io/sbaird/nvda-test@sha256:9102954d01165404605033b07969d78f63049df67fd9ea1b7880a89ab293890e --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key

[{"critical":{"identity":{"docker-reference":"quay.io/sbaird/nvda-test@sha256:9102954d01165404605033b07969d78f63049df67fd9ea1b7880a89ab293890e"},"image":{"docker-manifest-digest":"sha256:9102954d01165404605033b07969d78f63049df67fd9ea1b7880a89ab293890e"},"type":"https://sigstore.dev/cosign/sign/v1"},"optional":{}},{"critical":{"identity":{"docker-reference":"quay.io/sbaird/nvda-test@sha256:9102954d01165404605033b07969d78f63049df67fd9ea1b7880a89ab293890e"},"image":{"docker-manifest-digest":"sha256:9102954d01165404605033b07969d78f63049df67fd9ea1b7880a89ab293890e"},"type":"https://slsa.dev/provenance/v1"},"optional":{}}]


╭────────────────────────────────────────────╮
┝ cosign verify attestation (ignoring rekor) ┥
╰────────────────────────────────────────────╯

$ COSIGN_PASSWORD=secret123 cosign verify-attestation --key signing-key/cosign.pub --type https://slsa.dev/provenance/v1 --insecure-ignore-tlog=true $TEST_IMG

WARNING: Skipping tlog verification is an insecure practice that lacks transparency and auditability verification for the attestation.

Verification for quay.io/sbaird/nvda-test@sha256:9102954d01165404605033b07969d78f63049df67fd9ea1b7880a89ab293890e --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key
{"payload":"eyJfdHlwZSI6Imh0dHBzOi8vaW4tdG90by5pby9TdGF0ZW1lbnQvdjAuMSIsInN1YmplY3QiOlt7Im5hbWUiOiJxdWF5LmlvL3NiYWlyZC9udmRhLXRlc3QiLCJkaWdlc3QiOnsic2hhMjU2IjoiOTEwMjk1NGQwMTE2NTQwNDYwNTAzM2IwNzk2OWQ3OGY2MzA0OWRmNjdmZDllYTFiNzg4MGE4OWFiMjkzODkwZSJ9fV0sInByZWRpY2F0ZVR5cGUiOiJodHRwczovL3Nsc2EuZGV2L3Byb3ZlbmFuY2UvdjEiLCJwcmVkaWNhdGUiOnsiYnVpbGREZWZpbml0aW9uIjp7ImJ1aWxkVHlwZSI6Imh0dHBzOi8vZXhhbXBsZS5jb20vYnVpbGQtdHlwZS92MSIsImV4dGVybmFsUGFyYW1ldGVycyI6e30sImludGVybmFsUGFyYW1ldGVycyI6e30sInJlc29sdmVkRGVwZW5kZW5jaWVzIjpbXX0sInJ1bkRldGFpbHMiOnsiYnVpbGRlciI6eyJpZCI6Imh0dHBzOi8vZXhhbXBsZS5jb20vYnVpbGRlciJ9LCJtZXRhZGF0YSI6e319fX0=","payloadType":"application/vnd.in-toto+json","signatures":[{"sig":"MEUCIDOkA36cQxb3HzYtmQ3EsrbIxK5+9rf11pFl+jCDva5bAiEAkAunNpARnJjQEIPaDFV7jnNrqUTKBXScE/gCApf986I="}]}

```

## Not fully scripted parts

Mirroring with oc-mirror:

```
make mirror-to-disk
make disk-to-mirror
```

Mirroring with oras:

```
make oras-mirror-to-disk
make oras-disk-to-mirror
```

Then uncommenting one of the `TEST_IMG=` lines in `common.sh` lets you run
`make inspect` and `make verify` against the mirror.

## Conclusion

Using `oc-mirror` doesn't preserve the artifacts linked via OCI referrers
(meaning the signatures and attestations do not get mirrored), but using `oras
cp -r` does.
