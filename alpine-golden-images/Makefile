# Golden Alpine images — build and push
# Set REGISTRY (e.g. ghcr.io/myorg) and optionally VERSION

REGISTRY ?= alpine-golden
VERSION  ?=

VERSIONS := 3.17 3.18 3.19 3.20

.PHONY: all build build-all push push-all test scan lint pre-commit clean

# Default: build and test all images (single command for local CI)
all: test

build-all: $(addprefix build-,$(VERSIONS))
build-%:
	docker build -t $(REGISTRY):$*$(if $(VERSION),-$(VERSION),) ./$*

build: build-all

push-all: $(addprefix push-,$(VERSIONS))
push-%: build-%
	docker push $(REGISTRY):$*$(if $(VERSION),-$(VERSION),)

push: push-all

test: build-all
	./tests/test.sh $(REGISTRY)

# Vulnerability scan (requires built images). Fails on CRITICAL/HIGH with fixes.
scan:
	@for v in $(VERSIONS); do \
	  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
	    aquasec/trivy:latest image --exit-code 1 --severity CRITICAL,HIGH --ignore-unfixed $(REGISTRY):$$v; \
	done

lint:
	./scripts/lint.sh

pre-commit:
	pre-commit run --all-files

clean:
	-docker images '$(REGISTRY):*' -q | xargs -r docker rmi -f 2>/dev/null || true

# Single-version targets: make build-3.18, make push-3.20
