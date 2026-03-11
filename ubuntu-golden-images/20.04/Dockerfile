# Golden image: Ubuntu 20.04 LTS (Focal Fossa)
# Minimal, security-patched base for the past 4 LTS releases
ARG BASE_IMAGE=ubuntu:20.04
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Ubuntu 20.04 LTS Golden Image" \
      org.opencontainers.image.description="Minimal security-patched Ubuntu 20.04 LTS base" \
      org.opencontainers.image.version="20.04" \
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
