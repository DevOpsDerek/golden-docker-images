# Golden image: Debian 11 (Bullseye)
# Minimal, security-patched base
ARG BASE_IMAGE=debian/eol:bullseye-slim
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Debian 11 (Bullseye) Golden Image" \
      org.opencontainers.image.description="Minimal security-patched Debian 11 base" \
      org.opencontainers.image.version="bullseye" \
      org.opencontainers.image.vendor="Golden Images"

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i \
      -e 's|^# deb http://snapshot.debian.org/archive/debian-archive/|deb http://snapshot.debian.org/archive/debian-archive/|' \
      -e 's|^# deb http://snapshot.debian.org/archive/debian-security/|deb http://snapshot.debian.org/archive/debian-security/|' \
      -e 's|^deb http://archive.debian.org/|# deb http://archive.debian.org/|' \
      -e 's|^deb http://deb.debian.org/debian-security|# deb http://deb.debian.org/debian-security|' \
      /etc/apt/sources.list \
    && printf '%s\n' 'Acquire::Check-Valid-Until "false";' \
      > /etc/apt/apt.conf.d/99snapshot-valid-until

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
