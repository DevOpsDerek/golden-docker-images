# Golden image: Alpine Linux 3.20
# Minimal, security-patched base for recent Alpine releases
ARG BASE_IMAGE=alpine:3.20
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Alpine 3.20 Golden Image" \
      org.opencontainers.image.description="Minimal security-patched Alpine 3.20 base" \
      org.opencontainers.image.version="3.20" \
      org.opencontainers.image.vendor="Golden Images"

# Apply all security and package updates
RUN apk update && apk upgrade --no-cache \
    && apk add --no-cache ca-certificates curl

# Optional: uncomment to run as non-root
# RUN adduser -D -s /bin/sh app
# USER app
# WORKDIR /home/app

CMD ["/bin/sh"]
