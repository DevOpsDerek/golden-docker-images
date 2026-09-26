# Golden image: Debian 11 (Bullseye)
# Minimal, security-patched base
ARG BASE_IMAGE=debian/eol:bullseye-slim
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Debian 11 (Bullseye) Golden Image" \
      org.opencontainers.image.description="Minimal security-patched Debian 11 base" \
      org.opencontainers.image.version="bullseye" \
      org.opencontainers.image.vendor="Golden Images"

ENV DEBIAN_FRONTEND=noninteractive

# Apply all security and package updates
RUN printf '%s\n' \
        'deb https://snapshot.debian.org/archive/debian/20250420T000000Z bullseye main' \
        'deb https://snapshot.debian.org/archive/debian-security/20250420T000000Z bullseye-security main' \
        'deb https://snapshot.debian.org/archive/debian/20250420T000000Z bullseye-updates main' \
        > /etc/apt/sources.list \
    && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99snapshot \
    && apt-get update \
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
