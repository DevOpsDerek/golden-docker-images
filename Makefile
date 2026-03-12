# Golden Docker Images — build and test all families from repo root.
# Linux: cd <family>-golden-images && make. Windows: run on Windows with Windows containers.

.PHONY: all linux-all windows-all build-all test-all scan-all lint clean

# Default: Linux families only (Windows requires Windows host + Windows containers)
all: linux-all

# All Linux image families (Alpine, Ubuntu, Debian, Rocky)
linux-all:
	$(MAKE) -C alpine-golden-images all
	$(MAKE) -C ubuntu-golden-images all
	$(MAKE) -C debian-golden-images all
	$(MAKE) -C rocky-golden-images all

# Windows Server LTSC families (run on Windows with Docker set to Windows containers)
windows-all:
	$(MAKE) -C windows-golden-images all

# Build all images (all Linux families)
build-all:
	$(MAKE) -C alpine-golden-images build-all
	$(MAKE) -C ubuntu-golden-images build-all
	$(MAKE) -C debian-golden-images build-all
	$(MAKE) -C rocky-golden-images build-all

# Test all Linux (builds first via each family's "make test")
test-all: linux-all

# Vulnerability scan Linux (requires images already built: make build-all first)
scan-all:
	$(MAKE) -C alpine-golden-images scan
	$(MAKE) -C ubuntu-golden-images scan
	$(MAKE) -C debian-golden-images scan
	$(MAKE) -C rocky-golden-images scan

# Lint all families (Linux + Windows; uses config at repo root)
lint:
	$(MAKE) -C alpine-golden-images lint
	$(MAKE) -C ubuntu-golden-images lint
	$(MAKE) -C debian-golden-images lint
	$(MAKE) -C rocky-golden-images lint
	$(MAKE) -C windows-golden-images lint

# Remove built images from all families
clean:
	$(MAKE) -C alpine-golden-images clean
	$(MAKE) -C ubuntu-golden-images clean
	$(MAKE) -C debian-golden-images clean
	$(MAKE) -C rocky-golden-images clean
	$(MAKE) -C windows-golden-images clean
