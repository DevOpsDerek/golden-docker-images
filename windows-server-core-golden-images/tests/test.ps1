param(
  [string]$ImageBase = "windows-server-core-golden",
  [Parameter(Mandatory = $true)]
  [ValidateSet("ltsc2022", "ltsc2025")]
  [string]$TargetVersion
)

$ErrorActionPreference = "Stop"

$image = "$ImageBase`:$TargetVersion"
Write-Host "--- Runtime checks for $image ---"

$null = docker image inspect $image 2>$null
if ($LASTEXITCODE -ne 0) {
  throw "FAIL: $image not found (build it first)"
}

$runOutput = docker run --rm $image powershell -NoLogo -NoProfile -Command "Write-Output 'container-runs'"
if ($LASTEXITCODE -ne 0 -or $runOutput.Trim() -ne "container-runs") {
  throw "FAIL: $image container failed runtime command. Output: $runOutput"
}
Write-Host "OK: $image container starts"

$versionLabel = docker image inspect $image --format '{{index .Config.Labels "org.opencontainers.image.version"}}'
if ($LASTEXITCODE -ne 0) {
  throw "FAIL: $image image inspect label check failed"
}

if ($versionLabel.Trim() -ne $TargetVersion) {
  throw "FAIL: $image OCI version label expected '$TargetVersion', got '$versionLabel'"
}

Write-Host "OK: $image OCI version label matches $TargetVersion"
Write-Host "All runtime tests passed."
