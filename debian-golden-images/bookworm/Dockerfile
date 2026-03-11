# Golden image: Debian 12 (Bookworm)
# Minimal, security-patched base
ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Debian 12 (Bookworm) Golden Image" \
      org.opencontainers.image.description="Minimal security-patched Debian 12 base" \
      org.opencontainers.image.version="bookworm" \
      org.opencontainers.image.vendor="Golden Images"

ENV DEBIAN_FRONTEND=noninteractive

# Apply all security and package updates
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Optional: uncomment to run as non-root
# RUN useradd -m -s /bin/bash app
# USER app
# WORKDIR /home/app

CMD ["/bin/bash"]
