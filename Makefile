# Golden Docker Images — build and test all families from repo root.
# Per-family: cd <family>-golden-images && make

.PHONY: all build-all test-all scan-all lint validate-docs clean

# Default: build and test all families
all:
	$(MAKE) -C alpine-golden-images all
	$(MAKE) -C ubuntu-golden-images all
	$(MAKE) -C debian-golden-images all
	$(MAKE) -C rocky-golden-images all

# Build all images (all families)
build-all:
	$(MAKE) -C alpine-golden-images build-all
	$(MAKE) -C ubuntu-golden-images build-all
	$(MAKE) -C debian-golden-images build-all
	$(MAKE) -C rocky-golden-images build-all

# Test all (builds first via each family's "make test")
test-all: all

# Vulnerability scan (requires images already built: make build-all first)
scan-all:
	$(MAKE) -C alpine-golden-images scan
	$(MAKE) -C ubuntu-golden-images scan
	$(MAKE) -C debian-golden-images scan
	$(MAKE) -C rocky-golden-images scan

# Lint all families (uses config at repo root)
lint:
	$(MAKE) -C alpine-golden-images lint
	$(MAKE) -C ubuntu-golden-images lint
	$(MAKE) -C debian-golden-images lint
	$(MAKE) -C rocky-golden-images lint

# Validate repository supply-chain policy docs
validate-docs:
	./scripts/validate-supply-chain-docs.sh

# Remove built images from all families
clean:
	$(MAKE) -C alpine-golden-images clean
	$(MAKE) -C ubuntu-golden-images clean
	$(MAKE) -C debian-golden-images clean
	$(MAKE) -C rocky-golden-images clean
