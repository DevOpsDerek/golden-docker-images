# Golden Windows Server LTSC images — build and push (run on Windows with Windows containers).
# Set REGISTRY (e.g. ghcr.io/myorg) and optionally VERSION

REGISTRY ?= windows-golden
VERSION  ?=

VERSIONS := ltsc2022 ltsc2025

.PHONY: all build build-all push push-all test scan lint pre-commit clean

# Default: build and test all images
all: test

build-all: $(addprefix build-,$(VERSIONS))
build-%:
	docker build -t $(REGISTRY):$*$(if $(VERSION),-$(VERSION),) ./$*

build: build-all

push-all: $(addprefix push-,$(VERSIONS))
push-%: build-%
	docker push $(REGISTRY):$*$(if $(VERSION),-$(VERSION),)

push: push-all

# Test requires PowerShell and Windows containers (run on Windows)
test: build-all
	@if command -v pwsh >/dev/null 2>&1; then pwsh -NoProfile -File tests/test.ps1 $(REGISTRY); \
	elif command -v powershell >/dev/null 2>&1; then powershell -NoProfile -File tests/test.ps1 $(REGISTRY); \
	else echo "PowerShell required for tests. Run: pwsh tests/test.ps1 $(REGISTRY)"; exit 1; fi

# Trivy scan (Windows images; run where Docker has them, e.g. Windows runner or after build on Windows)
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

# Single-version targets: make build-ltsc2022, make push-ltsc2025
