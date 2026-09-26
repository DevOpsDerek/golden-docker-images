# Test golden Windows Server LTSC images: version, PowerShell, and labels.
# Usage: ./test.ps1 [image_base]   e.g. ./test.ps1 windows-golden  or  ./test.ps1 ghcr.io/myorg/windows-golden
# Requires: Docker (Windows containers). Run on Windows or with Docker Desktop Windows containers.

param(
    [string]$ImageBase = 'windows-golden',
    [string[]]$Versions = @('ltsc2019', 'ltsc2022', 'ltsc2025')
)

$ErrorActionPreference = 'Stop'
$Failed = 0

function Run-Test {
    param([string]$Image, [string]$Version, [string]$Command, [string]$Description)
    $out = docker run --rm $Image powershell -NoProfile -Command $Command 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAIL: $Image — $Description"
        return 1
    }
    Write-Host "OK: $Image — $Description"
    return 0
}

foreach ($v in $Versions) {
    $image = "${ImageBase}:${v}"
    Write-Host "--- Testing $image ---"

    # Image must exist
    docker image inspect $image 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAIL: $image — image not found (build it first)"
        $Failed = 1
        continue
    }

    # Container runs and PowerShell works
    $exit = Run-Test -Image $image -Version $v -Description 'container runs' -Command 'exit 0'
    if ($exit -ne 0) { $Failed = 1; continue }

    # OS / registry present
    $exit = Run-Test -Image $image -Version $v -Description 'PowerShell and OS' -Command 'if (-not (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -ErrorAction SilentlyContinue)) { exit 1 }; exit 0'
    if ($exit -ne 0) { $Failed = 1; continue }

    # TLS 1.2 client enabled (we set it in Dockerfile)
    $exit = Run-Test -Image $image -Version $v -Description 'TLS 1.2 registry keys' -Command '$c = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -ErrorAction SilentlyContinue; if (-not $c -or $c.DisabledByDefault -ne 0 -or $c.Enabled -ne 1) { exit 1 }; exit 0'
    if ($exit -ne 0) { $Failed = 1; continue }
}

# OCI labels (host-side)
foreach ($v in $Versions) {
    $image = "${ImageBase}:${v}"
    docker image inspect $image 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { continue }

    $labelVersion = (docker image inspect $image --format '{{index .Config.Labels "org.opencontainers.image.version"}}' 2>$null)
    $labelTitle   = (docker image inspect $image --format '{{index .Config.Labels "org.opencontainers.image.title"}}' 2>$null)
    $labelDesc    = (docker image inspect $image --format '{{index .Config.Labels "org.opencontainers.image.description"}}' 2>$null)
    $labelVendor  = (docker image inspect $image --format '{{index .Config.Labels "org.opencontainers.image.vendor"}}' 2>$null)

    if ($labelVersion -ne $v) {
        Write-Host "FAIL: $image — OCI version label expected '$v', got '$labelVersion'"
        $Failed = 1
    } else {
        Write-Host "OK: $image — OCI version label set"
    }
    if ([string]::IsNullOrEmpty($labelTitle)) {
        Write-Host "FAIL: $image — OCI title label missing"
        $Failed = 1
    } else {
        Write-Host "OK: $image — OCI title label set"
    }
    if ([string]::IsNullOrEmpty($labelDesc)) {
        Write-Host "FAIL: $image — OCI description label missing"
        $Failed = 1
    } else {
        Write-Host "OK: $image — OCI description label set"
    }
    if ([string]::IsNullOrEmpty($labelVendor)) {
        Write-Host "FAIL: $image — OCI vendor label missing"
        $Failed = 1
    } else {
        Write-Host "OK: $image — OCI vendor label set"
    }
}

if ($Failed -ne 0) {
    Write-Host 'Some tests failed.'
    exit 1
}
Write-Host 'All tests passed.'
