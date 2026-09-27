# escape=`
# Golden image: Windows Server Core LTSC 2022
ARG BASE_IMAGE=mcr.microsoft.com/windows/servercore:ltsc2022
FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="Windows Server Core LTSC 2022 Golden Image" org.opencontainers.image.description="Minimal security-patched Windows Server Core LTSC 2022 base" org.opencontainers.image.version="ltsc2022" org.opencontainers.image.vendor="Golden Images"

RUN powershell -NoLogo -NoProfile -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; Write-Host 'Windows Server Core LTSC 2022 golden image baseline ready.'"

CMD ["powershell.exe", "-NoLogo"]
