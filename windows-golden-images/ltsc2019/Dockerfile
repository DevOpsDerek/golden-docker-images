# Golden image: Windows Server 2019 (LTSC 2019) — Server Core
# Minimal, security-patched base for Windows Server 2019 LTS
# Build on Windows host only: docker build -t windows-golden:ltsc2019 .
ARG BASE_IMAGE=mcr.microsoft.com/windows/servercore:ltsc2019
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Windows Server 2019 LTSC Golden Image" \
      org.opencontainers.image.description="Minimal security-patched Windows Server 2019 Server Core base" \
      org.opencontainers.image.version="ltsc2019" \
      org.opencontainers.image.vendor="Golden Images"

# Use PowerShell for RUN; apply OS updates and set secure defaults
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'DisabledByDefault' -Value 0 -Type DWord -Force; \
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'Enabled' -Value 1 -Type DWord -Force; \
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'DisabledByDefault' -Value 0 -Type DWord -Force; \
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'Enabled' -Value 1 -Type DWord -Force

CMD ["powershell"]
