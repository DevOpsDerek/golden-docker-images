param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('ltsc2022', 'ltsc2025')]
    [string]$Version,
    [string]$ImageBase = 'windows-golden'
)

$ErrorActionPreference = 'Stop'
$image = "${ImageBase}:$Version"
$expectedBuild = @{ ltsc2022 = 20348; ltsc2025 = 26100 }[$Version]

$inspect = docker image inspect $image
if ($LASTEXITCODE -ne 0) {
    throw "Image $image is missing or cannot be inspected."
}
$details = @($inspect | ConvertFrom-Json)
if ($details.Count -ne 1) {
    throw "Expected one Docker image inspection result for $image."
}
if ($details[0].Os -ne 'windows') {
    throw "Image $image must target Windows."
}
$labels = $details[0].Config.Labels
if ($labels.'org.opencontainers.image.version' -ne $Version -or
    -not $labels.'org.opencontainers.image.title' -or
    -not $labels.'org.opencontainers.image.description' -or
    -not $labels.'org.opencontainers.image.vendor') {
    throw "Image $image has missing or incorrect OCI labels."
}

$build = docker run --rm --isolation=process $image powershell.exe -NoProfile -NonInteractive -Command '[Environment]::OSVersion.Version.Build'
if ($LASTEXITCODE -ne 0) {
    throw "Container $image did not run successfully (exit code $LASTEXITCODE)."
}
if ("$build".Trim() -ne "$expectedBuild") {
    throw "Container $image has OS build '$build'; expected $expectedBuild."
}
Write-Host "OK: $image runs on Windows build $expectedBuild with the expected OCI labels."
