# Golden image: Windows Server 2022 (LTSC 2022) — Server Core
# Minimal, security-patched base for Windows Server 2022 LTS
# Build on Windows host only: docker build -t windows-golden:ltsc2022 .
ARG BASE_IMAGE=mcr.microsoft.com/windows/servercore:ltsc2022
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Windows Server 2022 LTSC Golden Image" \
      org.opencontainers.image.description="Minimal security-patched Windows Server 2022 Server Core base" \
      org.opencontainers.image.version="ltsc2022" \
      org.opencontainers.image.vendor="Golden Images"

# Use PowerShell for RUN; create TLS 1.2 registry keys if missing, then enable TLS 1.2
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN $base = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2'; \
    New-Item -Path ($base + '\Client') -Force | Out-Null; \
    New-Item -Path ($base + '\Server') -Force | Out-Null; \
    Set-ItemProperty -Path ($base + '\Client') -Name 'DisabledByDefault' -Value 0 -Type DWord -Force; \
    Set-ItemProperty -Path ($base + '\Client') -Name 'Enabled' -Value 1 -Type DWord -Force; \
    Set-ItemProperty -Path ($base + '\Server') -Name 'DisabledByDefault' -Value 0 -Type DWord -Force; \
    Set-ItemProperty -Path ($base + '\Server') -Name 'Enabled' -Value 1 -Type DWord -Force

CMD ["powershell"]
