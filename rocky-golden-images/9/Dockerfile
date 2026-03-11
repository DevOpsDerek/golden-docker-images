# Golden image: Rocky Linux 9
# Minimal, security-patched RHEL-compatible base
ARG BASE_IMAGE=rockylinux:9
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Rocky Linux 9 Golden Image" \
      org.opencontainers.image.description="Minimal security-patched Rocky Linux 9 base" \
      org.opencontainers.image.version="9" \
      org.opencontainers.image.vendor="Golden Images"

# Apply all security and package updates
RUN dnf -y update && \
    dnf -y install ca-certificates curl && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Optional: uncomment to run as non-root
# RUN useradd -m -s /bin/bash app
# USER app
# WORKDIR /home/app

CMD ["/bin/bash"]
