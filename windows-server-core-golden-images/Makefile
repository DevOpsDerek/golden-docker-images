# Golden Windows Server Core images — LTSC 2022 and LTSC 2025

REGISTRY ?= windows-server-core-golden
VERSION  ?=
TARGET_VERSION ?=

VERSIONS := ltsc2022 ltsc2025

.PHONY: all build build-all test lint scan push push-all clean

all: test

build-all: $(addprefix build-,$(VERSIONS))
build-%:
	docker build -t $(REGISTRY):$*$(if $(VERSION),-$(VERSION),) ./$*

build: build-all

# Focused tests: static checks always; container runtime checks when TARGET_VERSION is set
# Example: make test TARGET_VERSION=ltsc2022
# Runtime checks require a compatible Windows Docker host.
test:
	./tests/test.sh $(REGISTRY) $(TARGET_VERSION)

lint:
	./scripts/lint.sh

scan:
	@if [ -z "$(TARGET_VERSION)" ]; then \
	  echo "Set TARGET_VERSION (ltsc2022|ltsc2025) for focused scan."; \
	  exit 1; \
	fi
	trivy image --exit-code 1 --severity CRITICAL,HIGH --ignore-unfixed $(REGISTRY):$(TARGET_VERSION)

push-%: build-%
	docker push $(REGISTRY):$*$(if $(VERSION),-$(VERSION),)

push-all: $(addprefix push-,$(VERSIONS))
push: push-all

clean:
	-docker images '$(REGISTRY):*' -q | xargs -r docker rmi -f 2>/dev/null || true
