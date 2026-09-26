# Build all golden Windows Server LTSC images.
# Usage: ./build.ps1 [registry[/repo]]   e.g. ./build.ps1 ghcr.io/myorg/windows-golden
# Requires: Docker with Windows containers. Run on Windows.

param([string]$Registry = 'windows-golden')

$ErrorActionPreference = 'Stop'
$Versions = @('ltsc2022', 'ltsc2025')
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

foreach ($v in $Versions) {
    Write-Host "Building $Registry${v} ..."
    docker build -t "${Registry}:${v}" -f "$ScriptDir\$v\Dockerfile" "$ScriptDir\$v"
}

Write-Host 'Done. Images:'
docker images $Registry --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'
