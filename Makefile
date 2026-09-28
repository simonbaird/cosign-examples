
# Change as needed
TEST_REPO=quay.io/sbaird/nvda-test

TEST_IMG=$(TEST_REPO):latest

build:
	podman build . -t $(TEST_IMG) --no-cache

push:
	podman push $(TEST_IMG)

run:
	podman run --rm $(TEST_IMG)

build-push: build push
