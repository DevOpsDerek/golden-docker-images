# Golden Docker Images — build and test all families from repo root.
# Per-family: cd alpine-golden-images && make (or ubuntu-golden-images)

.PHONY: all build-all test-all scan-all lint clean

# Default: build and test Alpine, then build and test Ubuntu
all:
	$(MAKE) -C alpine-golden-images all
	$(MAKE) -C ubuntu-golden-images all

# Build all images (both families)
build-all:
	$(MAKE) -C alpine-golden-images build-all
	$(MAKE) -C ubuntu-golden-images build-all

# Test all (builds first via each family's "make test")
test-all: all

# Vulnerability scan (requires images already built: make build-all first)
scan-all:
	$(MAKE) -C alpine-golden-images scan
	$(MAKE) -C ubuntu-golden-images scan

# Lint both families (uses config at repo root)
lint:
	$(MAKE) -C alpine-golden-images lint
	$(MAKE) -C ubuntu-golden-images lint

# Remove built images from both families
clean:
	$(MAKE) -C alpine-golden-images clean
	$(MAKE) -C ubuntu-golden-images clean
