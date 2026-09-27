param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('ltsc2022', 'ltsc2025')]
    [string]$Version
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
docker build --pull -t "windows-golden:$Version" (Join-Path $root $Version)
if ($LASTEXITCODE -ne 0) {
    throw "Docker build failed for $Version (exit code $LASTEXITCODE)."
}
