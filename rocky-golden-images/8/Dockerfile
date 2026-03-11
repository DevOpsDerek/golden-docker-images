# Golden image: Rocky Linux 8
# Minimal, security-patched RHEL-compatible base
ARG BASE_IMAGE=rockylinux:8
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Rocky Linux 8 Golden Image" \
      org.opencontainers.image.description="Minimal security-patched Rocky Linux 8 base" \
      org.opencontainers.image.version="8" \
      org.opencontainers.image.vendor="Golden Images"

# Install packages (dnf update can cause read-only FS in containers; base is used as-is)
RUN dnf -y install ca-certificates curl && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# Optional: uncomment to run as non-root
# RUN useradd -m -s /bin/bash app
# USER app
# WORKDIR /home/app

CMD ["/bin/bash"]
